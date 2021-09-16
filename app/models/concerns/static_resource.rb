module StaticResource
	extend ActiveSupport::Concern

	included do
		after_save :clear_all_caches if respond_to? :after_save
		after_destroy :clear_all_caches if respond_to? :after_destroy
	end

	def clear_all_caches
		if Rails.env.development?
			Rails.cache.delete_matched(self.class.name)
		else
			Rails.cache.delete_matched('*', namespace: self.class.name)
		end
	rescue RuntimeError
		Rails.logger.debug 'no cache to clear'
	end

	class_methods do
		def list
			cached('list') { all.to_a }
		end

		def as_map
			cached('as_map') { HashWithIndifferentAccess[all.map { |i| [i.id, i] }] }
		end

		def newest(**args)
			return cached('newest') { order(updated_at: :asc).last(id_sort: :none) } unless args.any?

			key = args.to_json
			return cached("newest#{key}") { where(args).order(updated_at: :asc).last(id_sort: :none) }
		end

		def grouped_by(column, instantiate = true)
			cached("#{column}_#{instantiate}") do
				query = collection.aggregate([{
																																		'$group' => {
																																			'_id' => "$#{column}",
																																			'members' => { '$push' => '$$ROOT' }
																																		}
																																	}])

				HashWithIndifferentAccess[query.map do |col|
					members = col[:members]
					[col[:_id], instantiate ? members.map { |m| new(m) } : members]
				end
				]
			end
		end

		def cached(key)
			Rails.cache.fetch(key, namespace: name) do
				yield
			end
		rescue RuntimeError
			yield
		end
	end
end
