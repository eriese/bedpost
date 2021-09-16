class Profile
	include Mongoid::Document
	include Mongoid::Timestamps::Short
		#to allow for serialization for jobs
	include GlobalID::Identification
	include NormalizeBlankValues
	include DeAliasFields
	include HasStaticRelations

	field :name, type: String
	field :a_n, as: :anus_name, type: String
	field :e_n, as: :external_name, type: String
	field :i_n, as: :internal_name, type: String
	field :c_p, as: :can_penetrate, type: Boolean, default: false

	has_static_relation :pronoun, optional: true

	validates_presence_of :name
	#only run this validation on the base class
	validates_presence_of :pronoun, :anus_name, :external_name, :if => :is_base?

	def has_internal?
		internal_name.present?
	end

	def is_base?
		instance_of?(Profile)
	end

	def as_json_private
		as_json({only: [:name, :pronoun_id], methods: [:anus_name, :external_name, :internal_name, :can_penetrate]})
	end

	def name_possessive
		I18n.t(:name_possessive, name: name)
	end
end
