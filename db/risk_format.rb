########## format
{
	contact_type: (:penetrated, :sucked, :touched, :fisted),
	subject_instrument_id: (:hand, :external_genitals, :internal_genitals, :anus, :mouth, :tongue, :toy), #the top
	object_instrument_id: (:hand, :external_genitals, :internal_genitals, :anus, :mouth, :tongue, :toy), #the bottom
	transmissions_risks: [
		diagnosis_id: (:chlamydia, :gonorrhea, :syphillis, :hiv, :hep_a, :hep_b, :hep_c, :hsv, :hpv, :trich, :cmv, :molluscum, :bv, :pubic_lice, :scabies,),
		risk_to_subject: (NO_RISK, NEGLIGIBLE, LOW, MODERATE, HIGH) #risk to the top
		risk_to_object: #risk to the bottom
		risk_to_self: #risk if doing it to yourself
	]
}

########## example
{
	contact_type: :touched,
	subject_instrument_id: :hand,
	object_instrument_id: :external_genitals,
	transmissions_risks: [
		{
			diagnosis_id: [:hpv, :chlamydia, :hsv, :syphillis],
			risk_to_subject: NEGLIGIBLE,
			risk_to_object: NEGLIGIBLE
		},
		{
			diagnosis_id: [:bv],
			risk_to_object: LOW,
			risk_to_self: LOW
		}
	]
}

########## data
