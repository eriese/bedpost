require 'rails_helper'

RSpec.describe UserToken, type: :model do
	before :each do
		@token = nil
	end

	after :each do
		@token.destroy unless @token.nil?
	end

  describe 'self#with_user' do
  	it 'finds a token with the given token_id that has a user_profile_id that matches a BSON user id' do
  		@token = UserToken.reset_token!(dummy_user.id)

  		found = UserToken.with_user(@token.id, dummy_user.id)
  		expect(found).to eq @token
  	end

  	it 'finds a token with the given token_id that has a user_profile_id matches a string user id' do
  		@token = UserToken.reset_token!(dummy_user.id)

  		found = UserToken.with_user(@token.id, dummy_user.id.to_s)
  		expect(found).to eq @token
  	end

  	it 'returns nil if there is no token with the given token_id' do
  		found = UserToken.with_user("not in database", dummy_user.id)
  		expect(found).to be_nil
  	end

  	it 'returns nil if the token exists but does not match the user' do
  		@token = UserToken.reset_token!(dummy_user.id)
  		found = UserToken.with_user(@token.id, "different user ID")
  		expect(found).to be_nil
  	end
  end
end
