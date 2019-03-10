require 'rails_helper'

class ApplicationControllerModel
	include Mongoid::Document

	field :field1
	field :field2

	validates_presence_of :field1, :field2
end

RSpec.describe ApplicationController do
	controller do
		skip_before_action :require_user
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
end
