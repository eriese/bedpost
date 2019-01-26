require "rails_helper"

RSpec.describe ProfilesController, type: :routing do
  describe "routing" do
    context "it is a singular resource nested under 'partners'" do
      it "does not route to #index" do
        expect(:get => "partners/1/profile").to_not route_to("profiles#index")
      end

      it "routes to #new" do
        expect(:get => "partners/profile/new").to route_to("profiles#new")
      end

      it "routes to #create" do
        expect(:post => "partners/profile").to route_to("profiles#create")
      end

      it "routes to #show" do
        expect(:get => "partners/1/profile").to route_to("profiles#show", :partnership_id => "1")
      end

      it "routes to #edit" do
        expect(:get => "partners/1/profile/edit").to route_to("profiles#edit", :partnership_id => "1")
      end

      it "routes to #update via PUT" do
        expect(:put => "partners/1/profile").to route_to("profiles#update", :partnership_id => "1")
      end

      it "routes to #update via PATCH" do
        expect(:patch => "partners/1/profile").to route_to("profiles#update", :partnership_id => "1")
      end

      it "routes to #destroy" do
        expect(:delete => "partners/1/profile").to route_to("profiles#destroy", :partnership_id => "1")
      end
    end
  end
end
