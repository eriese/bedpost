require 'rails_helper'

class ApplicationControllerModel
	include Mongoid::Document

	field :field1
	field :field2

	validates_presence_of :field1, :field2
end

RSpec.describe ApplicationController do
	controller do
		skip_before_action :store_user_location!
		skip_before_action :authenticate_user_profile!
		skip_before_action :check_first_time, only: [:index, :new]

		def index
			@obj = ApplicationControllerModel.new
			@obj.valid?
			respond_with_submission_error(@obj.errors.messages, login_path)
		end

		def new
			if params[:as_hash]
				@obj = {field1: 1, field2: 2}
			else
				@obj = ApplicationControllerModel.new
			end
			s_opts = params[:s_opts] || {}
			gon_client_validators(@obj, serialize_opts: s_opts)
			head :ok
		end

		def show
			head :ok
		end
	end

	describe '#gon_client_validators' do
		include_context :gon

		it 'puts the validators for the object on the page as gon.validators' do
			get :new
			expected = {
				"application_controller_model" => {
					"field1" => [[:presence, {}]],
					"field2" => [[:presence, {}]]
				}
			}
			expect(gon['validators']).to eq expected
		end

		it 'puts the json of the object on the page as gon.form_obj' do
			get :new
			obj = assigns(:obj)
			expected = {obj.model_name.element => obj.serializable_hash}
			expect(gon['form_obj']).to eq expected
		end

		it 'puts only the requested json fields on the page' do
			s_opts = {only: [:field1]}
			get :new, params: {s_opts: s_opts}
			obj = assigns(:obj)
			m_name = obj.model_name.element
			expected = {m_name => obj.serializable_hash(s_opts)}
			expect(gon['form_obj']).to eq expected
			expect(gon['form_obj'][m_name]).to_not include("field2")
		end

		it 'puts validators for only the requested fields on the page' do
			s_opts = {only: [:field1]}
			get :new, params: {s_opts: s_opts}
			g_vals = gon['validators'][assigns(:obj).model_name.element]
			expect(g_vals).to_not include("field2")
			expect(g_vals).to include("field1")
		end

		it 'works with a hash' do
			get :new, params: {as_hash: true}
			expected = {
				:field1 => [[:presence, {}]],
				:field2 => [[:presence, {}]]
			}
			expect(gon['validators']).to eq expected
		end
	end

	context 'before actions' do
		describe '#check_first_time' do
			it 'redirects to the edit_user_profile_registration_path if the user is not fully set up' do
				user = UserProfile.new
				allow(controller).to receive(:current_user_profile) {user}
				get :show, params: {id: "id"}
				expect(user).to_not be_set_up
				expect(user).to be_first_time
				expect(response).to redirect_to edit_user_profile_registration_path
			end

			it 'redirects to first_time_index_path if the user is fully set up but has taken no actions' do
				user = build_stubbed(:user_profile)
				allow(controller).to receive(:current_user_profile) {user}
				get :show, params: {id: "id"}
				expect(user).to be_set_up
				expect(user).to be_first_time
				expect(response).to redirect_to first_time_index_path
			end

			it 'does not redirect if the user if fully set up and has taken any actions' do
				user = double("UserProfile", set_up?: true, first_time?: false)
				allow(controller).to receive(:current_user_profile) {user}
				get :show, params: {id: "id"}
				expect(response).to have_http_status(200)
			end
		end
	end
end
