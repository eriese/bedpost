module StaticResource
	extend ActiveSupport::Concern

	class_methods do
		def as_map
			unless Rails.env.development?
				@as_map ||= hash_all
			else
				hash_all
			end
		end

		def grouped_by(column, instantiate=true)
			@grouped_queries ||= {}

			query = collection.aggregate([{"$group" => {"_id" => "$#{column}", "members" => {"$push"=> "$$ROOT"}}}])

			if Rails.env.development?
				hash_query(query, instantiate)
			else
				@grouped_queries["#{column}_#{instantiate}"] ||= hash_query(query, instantiate)
			end
		end

		private
		def hash_query(query, instantiate)
			HashWithIndifferentAccess[query.map {|col| [col[:_id], instantiate ? col[:members].map { |m| new(m) } : col[:members] ]}]
		end

		def hash_all
			HashWithIndifferentAccess[all.map {|i| [i.id, i]}]
		end
	end
end
