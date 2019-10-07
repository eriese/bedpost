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
