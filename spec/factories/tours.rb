FactoryBot.define do
  factory :tour do
    sequence(:page_name) {|n| "page#{n}" }

    transient do
    	node_count {2}
    end

    after(:build) do |tour, options|
    	options.node_count.times do
    		tour.tour_nodes.build(FactoryBot.attributes_for(:tour_node))
    	end
  	end
  end
end
