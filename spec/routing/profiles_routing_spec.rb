require "rails_helper"

RSpec.describe ProfilesController, type: :routing do
  describe "routing" do
    context "it is a singular resource nested under 'partners'" do
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

      context "except" do
        it "does not routes to #new" do
          expect(:get => "partners/1/profile/new").to_not route_to("profiles#new", :partnership_id => "1")
        end

        it "does not route to #create" do
          expect(:post => "partners/1/profile").to_not route_to("profiles#create", :partnership_id => "1")
        end

        it "does not route to #index" do
        expect(:get => "partners/1/profile").to_not route_to("profiles#index", :partnership_id => "1")
      end
      end
    end

    context "it is a singular resource scoped to '/partners'" do
      context "only" do
        it "routes to #new without a partnership id" do
          expect(:get => "partners/profile/new").to route_to("profiles#new")
        end

        it "routes to #create without a partnership id" do
          expect(:post => "partners/profile").to route_to("profiles#create")
        end
      end
    end
  end
end
