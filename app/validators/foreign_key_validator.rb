class ForeignKeyValidator < ActiveModel::EachValidator
	def validate_each(record, attribute, value)
		return true if value.blank?

		associated = if options[:query]
			options[:query].call(value, record)
		else
			key_class = options[:key_class]
			key_name = options[:key_name] || attribute
			key_class.find_by({ key_name => value })
		end

		error(record, attribute) if associated.nil?
	rescue Mongoid::Errors::DocumentNotFound
		error(record, attribute)
	end

	def error(record, attribute)
		record.errors.add(attribute, :bad_key, attribute: attribute)
	end
end
