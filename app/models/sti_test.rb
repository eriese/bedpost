class StiTest
	include Mongoid::Document
	field :tested_for, type: Symbol
	field :tested_on, type: DateTime

	index(tested_on: -1, tested_for: 1)
end
