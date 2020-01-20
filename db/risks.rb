NO_DATA = Diagnosis.TransmissionRisk::NO_DATA
NO_RISK = Diagnosis::TransmissionRisk::NO_RISK
NEGLIGIBLE = Diagnosis::TransmissionRisk::NEGLIGIBLE
LOW = Diagnosis::TransmissionRisk::LOW
MODERATE = Diagnosis::TransmissionRisk::MODERATE
HIGH = Diagnosis::TransmissionRisk::HIGH

all_contacts = [
	########################### KISSED
	{
		contact_type: :kissed,
		subject_instrument_id: :mouth,
		object_instrument_id: :anus,
		self_possible: false,
		transmission_risks: [
			{
				diagnoses: %i[hpv hsv syphillis],
				risk_to_subject: HIGH,
				risk_to_object: HIGH
			},
			{
				diagnoses: %i[gonorrhea chlamydia],
				risk_to_subject: LOW,
				risk_to_object: LOW
			},
			{
				diagnoses: %i[hiv],
				risk_to_subject: NO_DATA,
				risk_to_object: NO_DATA
			}
		]
	},
	{
		contact_type: :kissed,
		subject_instrument_id: :mouth,
		object_instrument_id: :mouth,
		self_possible: false,
		transmission_risks: [
			{
				diagnoses: %i[herpes],
				risk_to_subject: HIGH,
				risk_to_object: HIGH
			}
		]
	},
	{
		contact_type: :kissed,
		subject_instrument_id: :mouth,
		object_instrument_id: :toy,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :kissed,
		subject_instrument_id: :mouth,
		object_instrument_id: :tongue,
		self_possible: false,
		transmission_risks: [
			{
				diagnoses: %i[herpes],
				risk_to_subject: HIGH,
				risk_to_object: HIGH
			}
		]
	},
	{
		contact_type: :kissed,
		subject_instrument_id: :mouth,
		object_instrument_id: :hand,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :kissed,
		subject_instrument_id: :mouth,
		object_instrument_id: :external_genitals,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[hiv],
				risk_to_subject: NEGLIGIBLE
			},
			# these are the risks for kissing a vulva
			{
				diagnoses: %i[gonorrhea chlamydia],
				risk_to_subject: NEGLIGIBLE,
				risk_to_object: NEGLIGIBLE,
				object_conditions: [:has_internal?]
			},
			{
				diagnoses: %i[hpv herpes syphillis],
				risk_to_subject: LOW,
				risk_to_object: LOW,
				object_conditions: [:has_internal?]
			},
			# these are the risks for kissing a penis
			{
				diagnoses: %[gonorrhea hsv chlamydia syphillis hpv],
				risk_to_subject: LOW,
				risk_to_object: LOW,
				object_conditions: [:can_penetrate]
			}
		]
	},
	########################### TOUCHED
	{
		contact_type: :touched,
		subject_instrument_id: :hand,
		object_instrument_id: :external_genitals,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[gonorrhea chlamydia],
				risk_to_subject: NEGLIGIBLE,
				risk_to_object: NEGLIGIBLE
			},
			{
				diagnoses: %i[hpv hsv syphillis],
				risk_to_subject: LOW,
				risk_to_object: LOW
			},
			{
				diagnoses: %i[bv],
				risk_to_object: LOW,
				risk_to_self: LOW
			}
		]
	},
	{
		contact_type: :touched,
		subject_instrument_id: :hand,
		object_instrument_id: :anus,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[hpv chlamydia hsv syphillis],
				risk_to_subject: NEGLIGIBLE,
				risk_to_object: LOW
			}
		]
	},
	{
		contact_type: :touched,
		subject_instrument_id: :hand,
		object_instrument_id: :mouth,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :touched,
		subject_instrument_id: :hand,
		object_instrument_id: :hand,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :touched,
		subject_instrument_id: :hand,
		object_instrument_id: :toy,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :touched,
		subject_instrument_id: :hand,
		object_instrument_id: :tongue,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :touched,
		subject_instrument_id: :external_genitals,
		object_instrument_id: :anus,
		self_possible: false,
		transmission_risks: [
			{
				diagnoses: %i[syphillis hsv hpv],
				risk_to_subject: MODERATE,
				risk_to_object: MODERATE,
				caveats: [:increased_by_fluids]
			},
			{
				diagnoses: %i[gonorrhea chlamydia hiv],
				risk_to_subject: LOW,
				risk_to_object: LOW,
				caveats: [:increased_by_fluids]
			}
		]
	},
	{
		contact_type: :touched,
		subject_instrument_id: :external_genitals,
		object_instrument_id: :mouth,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[hiv],
				risk_to_object: NEGLIGIBLE
			},
			# these are the risks for touching with a vulva
			{
				diagnoses: %i[gonorrhea chlamydia],
				risk_to_subject: NEGLIGIBLE,
				risk_to_object: NEGLIGIBLE,
				subject_conditions: [:has_internal?]
			},
			{
				diagnoses: %i[hpv herpes syphillis],
				risk_to_subject: LOW,
				risk_to_object: LOW,
				subject_conditions: [:has_internal?]
			},
			# these are the risks for touching with a penis
			{
				diagnoses: %[gonorrhea hsv chlamydia syphillis hpv],
				risk_to_subject: LOW,
				risk_to_object: LOW,
				subject_conditions: [:can_penetrate]
			}
		]
	},
	{
		contact_type: :touched,
		subject_instrument_id: :external_genitals,
		object_instrument_id: :toy,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :touched,
		subject_instrument_id: :external_genitals,
		object_instrument_id: :external_genitals,
		self_possible: false,
		transmission_risks: [
			{
				diagnoses: %i[hpv hsv syphillis],
				risk_to_subject: MODERATE,
				risk_to_object: MODERATE,
				caveats: [:increased_by_fluids]
			},
			{
				diagnoses: %i[gonorrhea hiv],
				risk_to_subject: LOW,
				risk_to_object: LOW,
				caveats: [:increased_by_fluids]
			}
		]
	},
	{
		contact_type: :touched,
		subject_instrument_id: :external_genitals,
		object_instrument_id: :tongue,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[hiv],
				risk_to_subject: NEGLIGIBLE,
				risk_to_object: NEGLIGIBLE
			},
			# these are the risks for touching with a vulva
			{
				diagnoses: %i[hpv hsv syphillis],
				risk_to_subject: HIGH,
				risk_to_object: HIGH,
				subject_conditions: [:has_internal?]
			},
			{
				diagnoses: %i[gonorrhea chlamydia],
				risk_to_subject: LOW,
				risk_to_object: LOW,
				subject_conditions: [:has_internal?]
			},
			# these are the risks for touching with a penis
			{
				diagnoses: %i[gonorrhea hsv hpv chlamydia syphillis],
				risk_to_subject: MODERATE,
				risk_to_object: HIGH,
				subject_conditions: [:can_penetrate]
			}
		]
	},
	{
		contact_type: :touched,
		subject_instrument_id: :toy,
		object_instrument_id: :anus,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :touched,
		subject_instrument_id: :toy,
		object_instrument_id: :toy,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :touched,
		subject_instrument_id: :toy,
		object_instrument_id: :tongue,
		self_possible: true,
		transmission_risks: []
	},
	######################### Licked
	{
		contact_type: :licked,
		subject_instrument_id: :tongue,
		object_instrument_id: :hand,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :licked,
		subject_instrument_id: :tongue,
		object_instrument_id: :external_genitals,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[hiv],
				risk_to_subject: NEGLIGIBLE,
				risk_to_object: NEGLIGIBLE
			},
			# these are the risks for licking a vulva
			{
				diagnoses: %i[hpv hsv syphillis],
				risk_to_subject: HIGH,
				risk_to_object: HIGH,
				object_conditions: [:has_internal?]
			},
			{
				diagnoses: %i[gonorrhea chlamydia],
				risk_to_subject: LOW,
				risk_to_object: LOW,
				object_conditions: [:has_internal?]
			},
			# these are the risks for licking a penis
			{
				diagnoses: %i[gonorrhea hsv hpv chlamydia syphillis],
				risk_to_subject: HIGH,
				risk_to_object: MODERATE,
				object_conditions: [:can_penetrate]
			}
		]
	},
	{
		contact_type: :licked,
		subject_instrument_id: :tongue,
		object_instrument_id: :mouth,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[herpes],
				risk_to_subject: HIGH,
				risk_to_object: HIGH
			}
		]
	},
	{
		contact_type: :licked,
		subject_instrument_id: :tongue,
		object_instrument_id: :toy,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :licked,
		subject_instrument_id: :tongue,
		object_instrument_id: :tongue,
		self_possible: false,
		transmission_risks: [
			{
				diagnoses: %i[herpes],
				risk_to_subject: HIGH,
				risk_to_object: HIGH
			}
		]
	},
	{
		contact_type: :licked,
		subject_instrument_id: :tongue,
		object_instrument_id: :anus,
		self_possible: false,
		transmission_risks: [
			{
				diagnoses: %i[hpv herpes syphillis],
				risk_to_subject: HIGH,
				risk_to_object: HIGH
			},
			{
				diagnoses: %i[gonorrhea chlamydia],
				risk_to_subject: LOW,
				risk_to_object: LOW
			}
		]
	},
	######################### PENETRATED
	{
		contact_type: :penetrated,
		subject_instrument_id: :fingers,
		object_instrument_id: :internal_genitals,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[hpv hsv syphillis],
				risk_to_subject: NEGLIGIBLE,
				risk_to_object: LOW
			},
			{
				diagnoses: %i[gonorrhea chlamydia],
				risk_to_subject: NEGLIGIBLE,
				risk_to_object: NEGLIGIBLE
			},
			{
				diagnoses: %i[bv],
				risk_to_object: LOW,
				risk_to_self: LOW
			}
		]
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :fingers,
		object_instrument_id: :anus,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[hpv hsv syphillis],
				risk_to_subject: NEGLIGIBLE,
				risk_to_object: LOW
			},
			{
				diagnoses: %i[gonorrhea chlamydia],
				risk_to_subject: NEGLIGIBLE,
				risk_to_object: NEGLIGIBLE
			}
		]
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :fingers,
		object_instrument_id: :mouth,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :fingers,
		object_instrument_id: :toy,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :external_genitals,
		object_instrument_id: :internal_genitals,
		self_possible: false,
		transmission_risks: [
			{
				diagnoses: %i[gonorrhea chlamydia hpv hsv hiv syphillis],
				risk_to_subject: MODERATE,
				risk_to_object: HIGH
			}
		]
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :external_genitals,
		object_instrument_id: :anus,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[gonorrhea chlamydia hpv hsv hiv syphillis],
				risk_to_subject: MODERATE,
				risk_to_object: HIGH
			}
		]
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :external_genitals,
		object_instrument_id: :mouth,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[hiv],
				risk_to_subject: NEGLIGIBLE,
				risk_to_object: NEGLIGIBLE
			},
			# these are the risks for penetrating with a penis
			{
				diagnoses: %i[gonorrhea hsv hpv chlamydia syphillis],
				risk_to_subject: MODERATE,
				risk_to_object: HIGH
			}
		]
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :external_genitals,
		object_instrument_id: :toy,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :toy,
		object_instrument_id: :external_genitals,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :toy,
		object_instrument_id: :internal_genitals,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[hsv hpv],
				risk_to_subject: LOW,
				risk_to_object: LOW,
				caveats: [:if_strapon]
			}
		]
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :toy,
		object_instrument_id: :anus,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[hsv hpv],
				risk_to_subject: LOW,
				risk_to_object: LOW,
				caveats: [:if_strapon]
			}
		]
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :toy,
		object_instrument_id: :mouth,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[hsv hpv],
				risk_to_subject: LOW,
				risk_to_object: LOW,
				caveats: [:if_strapon]
			}
		]
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :toy,
		object_instrument_id: :toy,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :tongue,
		object_instrument_id: :external_genitals,
		self_possible: false,
		transmission_risks: [
			{
				diagnoses: %i[hiv],
				risk_to_subject: NEGLIGIBLE,
				risk_to_object: NEGLIGIBLE
			},
			{
				diagnoses: %i[gonorrhea hsv hpv chlamydia syphillis],
				risk_to_subject: HIGH,
				risk_to_object: MODERATE
			}
		]
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :tongue,
		object_instrument_id: :internal_genitals,
		self_possible: false,
		transmission_risks: [
			{
				diagnoses: %i[hiv],
				risk_to_subject: NEGLIGIBLE,
				risk_to_object: NEGLIGIBLE
			},
			{
				diagnoses: %i[hpv hsv syphillis],
				risk_to_subject: HIGH,
				risk_to_object: HIGH
			},
			{
				diagnoses: %i[gonorrhea chlamydia],
				risk_to_subject: LOW,
				risk_to_object: LOW
			}
		]
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :tongue,
		object_instrument_id: :anus,
		self_possible: false,
		transmission_risks: [
			{
				diagnoses: %i[hpv hsv syphillis],
				risk_to_subject: HIGH,
				risk_to_object: HIGH
			},
			{
				diagnoses: %i[gonorrhea chlamydia],
				risk_to_subject: LOW,
				risk_to_object: LOW
			}
		]
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :tongue,
		object_instrument_id: :mouth,
		self_possible: false,
		transmission_risks: [
			{
				diagnoses: %i[hsv],
				risk_to_subject: HIGH,
				risk_to_object: HIGH
			}
		]
	},
	{
		contact_type: :penetrated,
		subject_instrument_id: :tongue,
		object_instrument_id: :toy,
		self_possible: false,
		transmission_risks: []
	},

	########################## SUCKED
	{
		contact_type: :sucked,
		subject_instrument_id: :mouth,
		object_instrument_id: :fingers,
		self_possible: true,
		transmission_risks: []
	},
	{
		contact_type: :sucked,
		subject_instrument_id: :mouth,
		object_instrument_id: :external_genitals,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[hiv],
				risk_to_subject: NEGLIGIBLE,
				risk_to_object: NEGLIGIBLE
			},
			# these are the risks for sucking a vulva
			{
				diagnoses: %i[hpv hsv syphillis],
				risk_to_subject: HIGH,
				risk_to_object: HIGH,
				object_conditions: [:has_internal?]
			},
			{
				diagnoses: %i[gonorrhea chlamydia],
				risk_to_subject: LOW,
				risk_to_object: LOW,
				object_conditions: [:has_internal?]
			},
			# these are the risks for sucking a penis
			{
				diagnoses: %i[gonorrhea hsv hpv chlamydia syphillis],
				risk_to_subject: HIGH,
				risk_to_object: MODERATE,
				object_conditions: [:can_penetrate]
			}
		]
	},
	{
		contact_type: :sucked,
		subject_instrument_id: :mouth,
		object_instrument_id: :anus,
		self_possible: false,
		transmission_risks: [
			{
				diagnoses: %i[hpv herpes syphillis],
				risk_to_subject: HIGH,
				risk_to_object: HIGH
			},
			{
				diagnoses: %i[gonorrhea chlamydia],
				risk_to_subject: LOW,
				risk_to_object: LOW
			}
		]
	},
	{
		contact_type: :sucked,
		subject_instrument_id: :mouth,
		object_instrument_id: :mouth,
		self_possible: false,
		transmission_risks: [
			{
				diagnoses: %i[hsv],
				risk_to_subject: HIGH,
				risk_to_object: HIGH
			}
		]
	},
	{
		contact_type: :sucked,
		subject_instrument_id: :mouth,
		object_instrument_id: :toy,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[hsv hpv],
				risk_to_subject: LOW,
				risk_to_object: LOW,
				caveats: [:if_strapon]
			}
		]
	},
	{
		contact_type: :sucked,
		subject_instrument_id: :mouth,
		object_instrument_id: :tongue,
		self_possible: false,
		transmission_risks: [
			{
				diagnoses: %i[hsv],
				risk_to_subject: HIGH,
				risk_to_object: HIGH
			}
		]
	},

	######################### FISTED
	{
		contact_type: :fisted,
		subject_instrument_id: :hand,
		object_instrument_id: :internal_genitals,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[hpv chlamydia hsv syphillis],
				risk_to_subject: LOW,
				risk_to_object: LOW
			},
			{
				diagnoses: %i[bv],
				risk_to_subject: LOW,
				risk_to_object: LOW,
				risk_to_self: LOW
			},
			{
				diagnoses: %i[hiv],
				risk_to_subject: NO_DATA,
				risk_to_object: NO_DATA
			}
		]
	},
	{
		contact_type: :fisted,
		subject_instrument_id: :hand,
		object_instrument_id: :anus,
		self_possible: true,
		transmission_risks: [
			{
				diagnoses: %i[hpv chlamydia hsv syphillis],
				risk_to_subject: LOW,
				risk_to_object: LOW
			},
			{
				diagnoses: %i[hep_c],
				risk_to_subject: MODERATE,
				risk_to_object: MODERATE
			},
			{
				diagnoses: %i[hiv],
				risk_to_subject: NO_DATA,
				risk_to_object: NO_DATA
			}
		]
	},
	{
		contact_type: :fisted,
		subject_instrument_id: :hand,
		object_instrument_id: :mouth,
		self_possible: true,
		transmission_risks: []
	}
]
