require "rails_helper"

RSpec.describe PartnershipWhosController, type: :routing do
  describe "routing" do
  	context "scoped under '/partners'" do
  		 it "routes to #new" do
        expect(:get => "partners/who").to route_to("partnership_whos#new")
      end

      it "routes to #create" do
        expect(:post => "partners/who").to route_to("partnership_whos#create")
      end
  	end

  	context "nested under partners resource" do
  		 it "routes to #new" do
        expect(:get => "partners/1/who").to route_to("partnership_whos#new", :partnership_id => "1")
      end

      it "routes to #update via PATCH" do
        expect(:patch => "partners/1/who").to route_to("partnership_whos#update", :partnership_id => "1")
      end

      it "routes to #update via PATCH" do
        expect(:put => "partners/1/who").to route_to("partnership_whos#update", :partnership_id => "1")
      end

  	end
  end
end
