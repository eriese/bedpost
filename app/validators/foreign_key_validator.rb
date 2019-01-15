class ForeignKeyValidator < ActiveModel::EachValidator
	def validate_each(record, attribute, value)
		key_class = options[:key_class]
		key_name = options[:key_name] || attribute
		key_class.find_by({key_name => value})
	rescue Mongoid::Errors::DocumentNotFound
		record.errors.add(attribute, :bad_key, {attribute: attribute})
	end
end
