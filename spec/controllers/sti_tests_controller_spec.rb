require 'rails_helper'

RSpec.describe StiTestsController, type: :controller do
	before :all do
		create(:diagnosis, name: :hpv)
		create(:diagnosis, name: :hiv)
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

	describe 'POST #create' do
		def test_attributes(*arguments)
			tst = build(:sti_test, *arguments)
			json = tst.as_json(include: [:results])
			json[:results_attributes] = {}
			json.delete('results').each_with_index { |r, i| json[:results_attributes][i] = r }
			json
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
				@test1 = build(:sti_test, tested_on: date, tested_for: [:hiv, :hpv])
				@test2 = build(:sti_test, tested_on: date - 1.day, tested_for: [:hiv])

				@user.sti_tests = [@test1, @test2]
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
end
