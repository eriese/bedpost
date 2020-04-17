require 'rails_helper'

RSpec.describe StiTestsController, type: :controller do
	before :all do
		create(:diagnosis, name: :hpv)
		create(:diagnosis, name: :hiv)
		create(:diagnosis, name: :hcv)
	end

	after :all do
		Diagnosis.destroy_all
	end

	before do
		@user = create(:user_profile)
		sign_in @user
	end

	after do
		cleanup @user
	end

	def params_for(sti_test, delete_id = false)
		json = sti_test.as_json(include: [:results])
		json[:results_attributes] = {}
		json.delete('results').each_with_index do |r, i|
			r.delete('_id') if delete_id
			json[:results_attributes][i] = r
		end
		json
	end

	describe 'POST #create' do
		def test_attributes(*arguments)
			tst = build(:sti_test, *arguments)
			params_for(tst, true)
		end

		context 'with valid parameters' do
			it 'adds the tests to the user' do
				tst = test_attributes(tested_for: [:hpv, :hiv])
				expect {
					post :create, params: { sti_test: tst }
				}.to(change { @user.reload.sti_tests.size }.by(1))
				expect(@user.sti_tests.last.results.size).to be 2
			end

			it 'quietly drops empty tests' do
				tst = test_attributes(tested_for: [:hpv, :hiv, nil])
				expect {
					post :create, params: { sti_test: tst }
				}.to(change { @user.reload.sti_tests.size }.by(1))
				expect(@user.sti_tests.last.results.size).to be 2
			end

			it 'redirects to the show page for all tests on the inputted date' do
				dt = DateTime.current - 1.day
				tst = test_attributes(tested_on: dt, tested_for: [:hpv, :hiv])
				post :create, params: { sti_test: tst }
				expect(response).to redirect_to sti_test_path(StiTest.date_to_param(dt))
			end
		end

		context 'with no tests filled out' do
			it 'gives an incomplete form error' do
				allow(controller).to receive :respond_with_submission_error
				tst = test_attributes(tested_for: [nil])
				post :create, params: { sti_test: tst }
				expected_message = I18n.t(:incomplete, scope: 'errors.messages')
				expect(controller).to have_received(:respond_with_submission_error).with({
				 form_error: expected_message
				}, new_sti_test_path)
			end
		end

		context 'with invalid parameters' do
			it 'does not save any tests on the user' do
				tst = test_attributes(tested_for: [:hsv, :hpv])
				expect {
					post :create, params: {sti_test: tst}
				}.not_to(change { @user.reload.sti_tests.size })
			end

			it 'gives all the test error messages as a form error' do
				allow(controller).to receive :respond_with_submission_error
				tst = test_attributes(tested_for: [:hsv, :hpv])
				post :create, params: { sti_test: tst }

				expected_message = {
					results: [{
						tested_for: [I18n.t(:blank, scope: 'errors.messages')]
					},
					{}]
				}

				expect(controller).to have_received(:respond_with_submission_error).with(expected_message, new_sti_test_path)
			end
		end
	end

	describe 'GET #show' do
		context 'with a valid date' do
			before do
				date = Date.current
				@test1 = create(:sti_test, user_profile: @user, tested_on: date, tested_for: [:hiv, :hpv])
				@test2 = create(:sti_test, user_profile: @user, tested_on: date - 1.day, tested_for: [:hiv])

				@user.save
			end

			it 'shows a the test results for that date' do
				get :show, params: { tested_on: @test1.to_param }
				expect(assigns[:sti_test]).to eq @test1
			end
		end

		context 'with an invalid date' do
			it 'redirects to the index page if the parameter is not a date' do
				get :show, params: { tested_on: 'day' }
				expect(response).to redirect_to sti_tests_path
			end

			it 'redirects to the index page if the parameter is a date for which the user has no tests' do
				get :show, params: { tested_on: StiTest.date_to_param(DateTime.current) }
				expect(response).to redirect_to sti_tests_path
			end

			it 'adds a flash notice for the redirec' do
				get :show, params: { tested_on: StiTest.date_to_param(DateTime.current) }
				expect(flash[:notice]).to eq I18n.t(:no_sti_tests_with_date, scope: 'helpers.flash')
			end
		end
	end

	describe 'PATCH #update' do
		context 'with valid changes' do
			before do
				@user.sti_tests << build(:sti_test, tested_for: [:hiv, :hpv])
			end

			it 'updates the status of existing test results' do
				tst = @user.sti_tests.last
				last_result = tst.results.last
				last_result.positive = true
				pms = params_for(tst)

				patch :update, params: { tested_on: tst.to_param, sti_test: pms }
				expect(tst.reload.results.last.positive).to be true
			end

			it 'adds new test results' do
				tst = @user.sti_tests.last
				pms = params_for(tst)

				pms[:results_attributes][2] = StiTestResult.new(tested_for_id: :hcv).as_json(except: [:_id])

				expect { patch :update, params: { tested_on: tst.to_param, sti_test: pms} }.to change {tst.reload.results.count}.by 1
			end

			it 'removes removed test results' do
				tst = @user.sti_tests.last
				pms = params_for(tst)

				pms[:results_attributes][1]['_destroy'] = true

				expect { patch :update, params: { tested_on: tst.to_param, sti_test: pms} }.to change {tst.reload.results.count}.by -1
			end

			it 'can change the date of the test' do
				tst = @user.sti_tests.last
				pms = params_for(tst)
				new_tested_on = tst.tested_on + 1.day
				pms['tested_on'] = new_tested_on

				patch :update, params: { tested_on: tst.to_param, sti_test: pms}

				expect(tst.reload.tested_on).to eq new_tested_on
			end
		end

		context 'with invalid changes' do
			it 'responds with errors for each invalid result'
		end
	end

	describe 'DELETE #destroy' do
		before do
			@user.sti_tests << build(:sti_test, tested_for: [:hiv, :hpv])
		end

		it 'destroys the given sti_test' do
			expect{ delete :destroy, params: { tested_on: @user.sti_tests.last.to_param } }.to change { @user.reload.sti_tests.count }.by -1
		end

		it 'gives a flash success notice' do
			delete :destroy, params: { tested_on: @user.sti_tests.last.to_param }
			expect(flash[:notice]).to eq I18n.t('sti_tests.destroy.success')
		end

		it 'redirects back to the index page' do
			delete :destroy, params: { tested_on: @user.sti_tests.last.to_param }
			expect(response).to redirect_to sti_tests_path
		end

		it 'gives an error notice if it cannot destroy' do
			allow_any_instance_of(StiTest).to receive(:destroy) { false }
			delete :destroy, params: { tested_on: @user.sti_tests.last.to_param }

			expect(flash[:error]).to eq I18n.t('sti_tests.destroy.error_html')
		end
	end

	describe 'GET #unique' do
		context 'from the new test form' do
			it 'returns true if a new test with the given date would be unique' do
				get :unique, params: { tested_on: Date.current }
				expect(response.body).to eq 'true'
			end

			it 'returns an error message if a new test with the given date would not be unique' do
				current_date = Date.current
				@user.sti_tests << build(:sti_test, tested_on: current_date, tested_for: [:hiv])
				get :unique, params: { tested_on: current_date}
				expect(response.body).to include('You already gave us results for this date')
			end
		end

		context 'from the edit test form' do
			before do
				@user.sti_tests << build(:sti_test, tested_for: [:hiv, :hpv])
			end

			it 'returns true if an existing test with the given date would be still unique' do
				current_date = @user.sti_tests.last.tested_on
				get :unique, params: { current_tested_on: current_date, tested_on: current_date - 1.day }
				expect(response.body).to eq 'true'
			end

			it 'returns true for an existing test on its saved date' do
				current_date = @user.sti_tests.last.tested_on
				get :unique, params: { current_tested_on: current_date, tested_on: current_date }
				expect(response.body).to eq 'true'
			end

			it 'returns an error message if a new test with the given date would not be unique' do
				original_date = @user.sti_tests.last.tested_on
				current_date = original_date - 1.day
				@user.sti_tests << build(:sti_test, tested_on: current_date, tested_for: [:hiv])
				get :unique, params: { current_tested_on: original_date, tested_on: current_date}
				expect(response.body).to include('You already gave us results for this date')
			end
		end
	end
end
