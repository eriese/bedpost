require 'rails_helper'

RSpec.describe "profiles/index", type: :view do
  before(:each) do
    assign(:profiles, [
      Profile.create!(),
      Profile.create!()
    ])
  end

  pending "renders a list of profiles" do
    render
  end
end
