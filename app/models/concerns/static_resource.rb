module StaticResource
	extend ActiveSupport::Concern

	class_methods do
		def as_map
			if Rails.env.production?
				@@as_map ||= HashWithIndifferentAccess[all.map {|i| [i.id, i]}]
			else
				HashWithIndifferentAccess[all.map {|i| [i.id, i]}]
			end
		end

		def grouped_by(column, instantiate=true)
			query = collection.aggregate([{"$group" => {"_id" => "$#{column}", "members" => {"$push"=> "$$ROOT"}}}])

			Hash[query.map {|col| [col[:_id], instantiate ? col[:members].map { |m| new(m) } : col[:members] ]}]
		end
	end
end
