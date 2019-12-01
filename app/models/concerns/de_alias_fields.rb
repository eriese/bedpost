module DeAliasFields
	extend ActiveSupport::Concern

	class_methods do
		def dont_strip_booleans
			self.dont_strip = true
		end
	end

	included do
		class_attribute :dont_strip
	end

	def as_json(options = {})
		original_hash = super(options)
		alias_invert = aliased_fields.invert
		strip_qs = options.key?(:strip_qs) ? options[:strip_qs] : !dont_strip

		Hash[original_hash.map do |k, v|
			key = alias_invert.include?(k) && !k.include?('_id') ? alias_invert[k] : k
			key = key.chomp('?') if strip_qs
			[key, v]
		end]
	end
end
