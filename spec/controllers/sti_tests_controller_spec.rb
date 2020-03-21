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
		context 'with valid parameters' do
			it 'adds the tests to the user' do
				tsts = {
					0 => attributes_for(:sti_test, tested_for_id: :hiv),
					1 => attributes_for(:sti_test, tested_for_id: :hpv)
				}
				expect {
					post :create, params: { sti_tests: { tests_for: tsts } }
				}.to(change { @user.reload.sti_tests.size }.by(2))
			end

			it 'quietly drops empty tests' do
				tsts = {
					0 => attributes_for(:sti_test, tested_for_id: :hiv),
					1 => attributes_for(:sti_test, tested_for_id: :hpv),
					2 => attributes_for(:sti_test, tested_for_id: nil)
				}
				expect {
					post :create, params: { sti_tests: { tests_for: tsts } }
				}.to(change { @user.reload.sti_tests.size }.by(2))
			end

			it 'redirects to the show page for all tests on the inputted date' do
				dt = DateTime.current
				tsts = {
					0 => attributes_for(:sti_test, tested_for_id: :hiv, tested_on: dt)
				}
				post :create, params: { sti_tests: { tests_for: tsts } }
				expect(response).to redirect_to sti_test_path(StiTest.date_to_param(dt))
			end
		end

		context 'with no tests filled out' do
			it 'gives an incomplete form error' do
				allow(controller).to receive :respond_with_submission_error
				tsts = {
					0 => attributes_for(:sti_test, tested_for_id: nil)
				}
				post :create, params: { sti_tests: { tests_for: tsts } }
				expected_message = I18n.t(:incomplete, scope: 'errors.messages')
				expect(controller).to have_received(:respond_with_submission_error).with({
				 form_error: expected_message
				}, new_sti_test_path)
			end
		end

		context 'with invalid parameters' do
			it 'does not save any tests on the user' do
				tsts = {
					0 => attributes_for(:sti_test, tested_for_id: :hsv),
					1 => attributes_for(:sti_test, tested_for_id: :hpv)
				}
				expect {
					post :create, params: { sti_tests: { tests_for: tsts } }
				}.not_to(change { @user.reload.sti_tests.size })
			end

			it 'gives a vague form error message' do
				allow(controller).to receive :respond_with_submission_error
				tsts = {
					0 => attributes_for(:sti_test, tested_for_id: :hsv),
					1 => attributes_for(:sti_test, tested_for_id: :hpv)
				}

				post :create, params: { sti_tests: { tests_for: tsts } }

				expected_message = I18n.t(:vague, scope: 'errors.messages')
				expect(controller).to have_received(:respond_with_submission_error).with({
					form_error: expected_message
				}, new_sti_test_path)
			end
		end
	end

	describe 'GET #show' do
		context 'with a valid date' do
			before do
				date = DateTime.current
				@test1 = build(:sti_test, tested_for_id: :hiv, tested_on: date)
				@test2 = build(:sti_test, tested_for_id: :hpv, tested_on: date)
				@test3 = build(:sti_test, tested_for_id: :hiv, tested_on: (date + 1.day))

				@user.sti_tests = [@test1, @test2, @test3]
				@user.save
			end

			it 'shows a list of all tests from that date' do
				get :show, params: { tested_on: @test1.to_param }
				expect(assigns[:sti_tests]).to eq [@test1, @test2]
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
