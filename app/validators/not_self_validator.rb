class NotSelfValidator < ActiveModel::EachValidator
	def validate_each(record, attribute, value)
		parent_method = options[:method]
		parent_val = parent_method.present? ? record._parent.send(parent_method) : record._parent
		if parent_val == value
			record.errors.add(attribute, :self_key, attribute: attribute)
		end
	end
end
