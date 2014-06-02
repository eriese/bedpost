DISEASES = [
  {name: :Chlamydia, gestation_min: 1, gestation_max: 4 },
  {name: :Gonorrhea, gestation_min: 1, gestation_max: 3 },
  {name: :Syphillis, gestation_min: 1, gestation_max: 12},
  {name: :HIV, gestation_min: 4, gestation_max: 12},
  {name: :Hepatitis_C, gestation_min: 6, gestation_max: 12},
  {name: :Hepatitis_B, gestation_min: 6, gestation_max: 12},
  {name: :Herpes, gestation_min: 3, gestation_max: 12},
  {name: :Hepatitis_A, gestation_min: 2, gestation_max: 7},
  {name: :HPV, gestation_min: 8, gestation_max: 80},
  {name: :Trichomoniasis, gestation_max: 4, gestation_min: 1},
  {name: :Cytomegalovirus, gestation_max: 12, gestation_min: 3},
  {name: :Molluscum_Contagiosum, gestation_min: 2, gestation_max: 24},
  {name: :Bacterial_Vaginosis, gestation_min: 0, gestation_max: 1}]
DISEASE_CATEGORIES = {
  curable: [:Gonorrhea, :Chlamydia, :Syphillis],
  uncommon: [:Cytomegalovirus, :Molluscum_Contagiosum],
  genital_specific: [:Bacterial_Vaginosis, :Trichomoniasis],
  heps: [:Hepatitis_A, :Hepatitis_B, :Hepatitis_C],
  skin: [:Herpes, :HPV],
  hiv: [:HIV]}
INSTRUMENTS = [:hand, :genitals, :anus, :mouth, :toys]
PRONOUNS = [
  {subject: "ze", object: "hir", possessive: "hir" , obj_possessive: "hirs", reflexive: "hirself"},
  {subject: "she", object: "her", possessive: "her", obj_possessive: "hers", reflexive: "herself"},
  {subject: "he", object: "him", possessive: "his", obj_possessive: "his", reflexive: "himself"},
  {subject: "they", object: "them", possessive: "their", obj_possessive: "theirs", reflexive: "themself"}]
