module Disease
  CHLAMYDIA = DiseaseEnum.new({name: :Chlamydia, readable: "Chlamydia", gestation_min: 1, gestation_max: 4, barriers_effective: true, category: ["Curable"], risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :toys, risk_level: 1},
    {user_instrument: :genitals, partner_instrument: :hand, risk_level: 1},
    {user_instrument: :mouth, partner_instrument: :genitals, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :mouth, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}
  ]
  })
  GONORRHEA = DiseaseEnum.new({name: :Gonorrhea, readable: "Gonorrhea",gestation_min: 1, gestation_max: 3, category: ["Curable"],barriers_effective: true, risky_contacts: [
    {user_instrument: :mouth, partner_instrument: :genitals, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :mouth, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}
  ] })
  SYPHILLIS = DiseaseEnum.new({name: :Syphillis, readable: "Syphillis", gestation_min: 1, gestation_max: 12, barriers_effective: true, category: ["Curable"], risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :hand, risk_level: 1},
    {user_instrument: :mouth, partner_instrument: :genitals, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :mouth, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}
    ] })
  HIV = DiseaseEnum.new({name: :HIV, readable: "HIV", gestation_min: 4, gestation_max: 12, barriers_effective: true, risky_contacts: [
    {user_instrument: :mouth, partner_instrument: :genitals, risk_level: 1},
    {user_instrument: :genitals, partner_instrument: :mouth, risk_level: 1}] })
  HEPC = DiseaseEnum.new({name: :Hepatitis_C, readable: "Hepatitis C", gestation_min: 6, gestation_max: 12, barriers_effective: true, risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}] })
  HEPB = DiseaseEnum.new({name: :Hepatitis_B, readable: "Hepatitis B", gestation_min: 6, gestation_max: 12, barriers_effective: true, risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}] })
  HEPA = DiseaseEnum.new({name: :Hepatitis_A, readable: "Hepatitis A", gestation_min: 2, gestation_max: 7, barriers_effective: true, risky_contacts: [] })
  HERPES = DiseaseEnum.new({name: :Herpes, readable: "Herpes", gestation_min: 3, gestation_max: 12, barriers_effective: false, risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :toys, risk_level: 1},
    {user_instrument: :anus, partner_instrument: :toys, risk_level: 1},
    {user_instrument: :genitals, partner_instrument: :hand, risk_level: 1},
    {user_instrument: :mouth, partner_instrument: :genitals, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :mouth, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}] })
  HPV = DiseaseEnum.new({name: :HPV, readable: "HPV", gestation_min: 8, gestation_max: 80,  barriers_effective: false,risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :toys, risk_level: 1},
    {user_instrument: :anus, partner_instrument: :toys, risk_level: 1},
    {user_instrument: :genitals, partner_instrument: :hand, risk_level: 1},
    {user_instrument: :genitals, partner_instrument: :mouth, risk_level: 2},
    {user_instrument: :mouth, partner_instrument: :genitals, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}] })
  TRICH = DiseaseEnum.new({name: :Trichomoniasis, readable: "Trichomoniasis", gestation_max: 4, gestation_min: 1, barriers_effective: true, risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}] })
  CMV = DiseaseEnum.new({name: :Cytomegalovirus, readable: "Cytomegalovirus", gestation_max: 12, gestation_min: 3, barriers_effective: true, risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :mouth, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}] })
  MOLLUSCUM = DiseaseEnum.new({name: :Molluscum_Contagiosum, readable: "Molluscum Contagiosum", gestation_min: 2, gestation_max: 24, barriers_effective: true, risky_contacts: [] })
  BV = DiseaseEnum.new({name: :Bacterial_Vaginosis, readable: "Bacterial Vaginosis", gestation_min: 0, gestation_max: 1, barriers_effective: true, risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :hand, risk_level: 1},
    {user_instrument: :genitals, partner_instrument: :toys, risk_level: 1}
    ] })
  def self.all
    ObjectSpace.each_object(DiseaseEnum).to_a.sort { |a, b| a.readable <=> b.readable }
  end
  def self.find_by_name(name)
    all.find{|disease| disease.name == name}
  end
  def self.find_by_readable(readable)
    all.find{|disease| disease.readable == readable}
  end
  def self.find_by_category(category)
    all.select{|disease| disease.category.include?(category)}
  end
  def self.find_by_contact(user_inst, partner_inst)
    all.select{|disease| disease.risky_contacts.find{|contact| contact[:user_instrument] == user_inst && contact[:partner_instrument] == partner_inst}}
  end
end
