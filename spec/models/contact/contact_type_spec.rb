require 'rails_helper'

RSpec.describe Contact::ContactType, type: :model do
	context 'class methods' do
		describe '.const_missing' do
			it 'calls .get' do
				expect(Contact::ContactType).to_not respond_to(:PENETRATED)
				allow(Contact::ContactType).to receive(:get).and_call_original
				result = Contact::ContactType::PENETRATED
				expect(Contact::ContactType).to have_received(:get).with(:PENETRATED)
				expect(result).to eq Contact::ContactType.get(:penetrated)
			end
		end

		describe '.get' do
			it 'checks the TYPES hash for a ContactType of that name' do
				result = Contact::ContactType.get(:penetrated)
				expect(result).to eq Contact::ContactType::TYPES[:penetrated]
			end
		end

		describe '.all' do
			it 'gets an array of all the types' do
				expect(Contact::ContactType.all).to eq Contact::ContactType::TYPES.values
			end
		end
	end

	context 'mongoid' do
		class ContactTypeTestModel
			include Mongoid::Document
			field :contact_type, type: Contact::ContactType
		end

  	after :each do
  		cleanup(@model)
  	end

  	it 'sets properly' do
  		@model = ContactTypeTestModel.new(contact_type: :penetrated)
  		expect(@model.contact_type).to eq Contact::ContactType.get(:penetrated)
  	end

  	it 'saves properly with a key' do
  		@model = ContactTypeTestModel.create(contact_type: :penetrated)
  		@model.reload
  		expect(@model.contact_type).to eq Contact::ContactType.get(:penetrated)
  	end

  	it 'saves properly with an instance' do
  		c_type = Contact::ContactType.get(:penetrated)
  		@model = ContactTypeTestModel.create(contact_type: c_type)
  		@model.reload
  		expect(@model.contact_type).to eq c_type
  	end
	end

	context 'constants' do
		describe '.TYPES' do
			it 'is a hash of all the types by key' do
				types = Contact::ContactType::TYPES
				expect(types).to be_a Hash
				expect(types[:penetrated]).to be_a Contact::ContactType
			end
		end
	end
end
