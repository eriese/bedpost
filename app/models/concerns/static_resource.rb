module StaticResource
	extend ActiveSupport::Concern

	class_methods do
		def as_map
			def self.as_map
				if Rails.env.production?
					@@as_map ||= HashWithIndifferentAccess[all.map {|i| [i.id, i]}]
				else
					HashWithIndifferentAccess[all.map {|i| [i.id, i]}]
				end
			end
		end

		def grouped_by(column)
			query = collection.aggregate([{"$group" => {"_id" => "$#{column}", "members" => {"$push"=> "$$ROOT"}}}])

			Hash[query.map {|col| [col[:_id], col[:members]]}]
		end
	end
end
