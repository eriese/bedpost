require "rails_helper"

RSpec.describe EncountersController, type: :routing do
  describe "routing" do
    context "it is a resource nested under 'partners'" do
      it "routes to #index" do
        expect(:get => "partners/1/encounters").to route_to("encounters#index", :partnership_id => "1")
      end

      it "routes to #show" do
        expect(:get => "partners/1/encounters/1").to route_to("encounters#show", :partnership_id => "1", id: "1")
      end

      it "routes to #edit" do
        expect(:get => "partners/1/encounters/1/edit").to route_to("encounters#edit", :partnership_id => "1", id: "1")
      end

      it "routes to #update via PUT" do
        expect(:put => "partners/1/encounters/1").to route_to("encounters#update", :partnership_id => "1", id: "1")
      end

      it "routes to #update via PATCH" do
        expect(:patch => "partners/1/encounters/1").to route_to("encounters#update", :partnership_id => "1", id: "1")
      end

      it "routes to #destroy" do
        expect(:delete => "partners/1/encounters/1").to route_to("encounters#destroy", :partnership_id => "1", id: "1")
      end

      it "routes to #new" do
        expect(:get => "partners/1/encounters/new").to route_to("encounters#new", :partnership_id => "1")
      end

      it "routes to #create" do
        expect(:post => "partners/1/encounters").to route_to("encounters#create", :partnership_id => "1")
      end
    end

    context "it is a non-nested resource" do
      context "only" do
        it "routes to #index" do
          expect(:get => "encounters").to route_to("encounters#index")
        end
      end
    end
  end
end
