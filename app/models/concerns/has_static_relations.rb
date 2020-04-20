module HasStaticRelations
	extend ActiveSupport::Concern

	# a belongs-to referrential relationship where the "owner" is a static resource and should be validated with caching rather than database searches
	class HasStaticRelation < Mongoid::Association::Referenced::BelongsTo
		def execute_query(object, type)
			model = type ? type.constantize : relation_class
			model.as_map[object]
		end
	end

	class_methods do
		def has_static_relation(name, options = {}, &block)
			HasStaticRelation.new(self, name, options, &block).tap do |assoc|
				assoc.setup!
				self.relations = self.relations.merge(name => assoc)
			end
		end
	end
end
