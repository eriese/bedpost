DISEASES = [
  {name: :Chlamydia, readable: "Chlamydia", gestation_min: 1, gestation_max: 4, risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :toys, risk_level: 1},
    {user_instrument: :genitals, partner_instrument: :hand, risk_level: 1},
    {user_instrument: :mouth, partner_instrument: :genitals, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :mouth, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}] },
  {name: :Gonorrhea, readable: "Gonorrhea",gestation_min: 1, gestation_max: 3, risky_contacts: [
    {user_instrument: :mouth, partner_instrument: :genitals, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :mouth, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}] },
  {name: :Syphillis, readable: "Syphillis", gestation_min: 1, gestation_max: 12, risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :hand, risk_level: 1},
    {user_instrument: :mouth, partner_instrument: :genitals, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :mouth, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}] },
  {name: :HIV, readable: "HIV", gestation_min: 4, gestation_max: 12, risky_contacts: [
    {user_instrument: :mouth, partner_instrument: :genitals, risk_level: 1},
    {user_instrument: :genitals, partner_instrument: :mouth, risk_level: 1}] },
  {name: :Hepatitis_C, readable: "Hepatitis C", gestation_min: 6, gestation_max: 12, risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}] },
  {name: :Hepatitis_B, readable: "Hepatitis B", gestation_min: 6, gestation_max: 12, risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}] },
  {name: :Herpes, readable: "Herpes", gestation_min: 3, gestation_max: 12, risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :toys, risk_level: 1},
    {user_instrument: :anus, partner_instrument: :toys, risk_level: 1},
    {user_instrument: :genitals, partner_instrument: :hand, risk_level: 1},
    {user_instrument: :mouth, partner_instrument: :genitals, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :mouth, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}] },
  {name: :Hepatitis_A, readable: "Hepatitis A", gestation_min: 2, gestation_max: 7, risky_contacts: [] },
  {name: :HPV, readable: "HPV", gestation_min: 8, gestation_max: 80, risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :toys, risk_level: 1},
    {user_instrument: :anus, partner_instrument: :toys, risk_level: 1},
    {user_instrument: :genitals, partner_instrument: :hand, risk_level: 1},
    {user_instrument: :genitals, partner_instrument: :mouth, risk_level: 2},
    {user_instrument: :mouth, partner_instrument: :genitals, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}] },
  {name: :Trichomoniasis, readable: "Trichomoniasis", gestation_max: 4, gestation_min: 1, risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}] },
  {name: :Cytomegalovirus, readable: "Cytomegalovirus", gestation_max: 12, gestation_min: 3, risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :mouth, risk_level: 2},
    {user_instrument: :genitals, partner_instrument: :genitals, risk_level: 3},
    {user_instrument: :genitals, partner_instrument: :anus, risk_level: 3},
    {user_instrument: :anus, partner_instrument: :genitals, risk_level: 3}] },
  {name: :Molluscum_Contagiosum, readable: "Molluscum Contagiosum", gestation_min: 2, gestation_max: 24, risky_contacts: [] },
  {name: :Bacterial_Vaginosis, readable: "Bacterial Vaginosis", gestation_min: 0, gestation_max: 1, risky_contacts: [
    {user_instrument: :genitals, partner_instrument: :hand, risk_level: 1},
    {user_instrument: :genitals, partner_instrument: :toys, risk_level: 1}] }]
DISEASE_CATEGORIES = {
  "Curable" => {description: "These infections are very common and easily treatable, but can be dangerous if left untreated", diseases: [:Gonorrhea, :Chlamydia, :Syphillis]},
  "Uncommon" => {description: "These infections are less well-known than others, but can still happen.", diseases: [:Cytomegalovirus, :Molluscum_Contagiosum]},
  "Genital-specific" => {description: "These infections only occur for people with internal genitalia", diseases: [:Bacterial_Vaginosis, :Trichomoniasis]},
  "Hepatitis" => {description: "Hepatitis attacks the liver and stays in your system forever, even after it is cured", diseases:[:Hepatitis_A, :Hepatitis_B, :Hepatitis_C]},
  "Skin-to-skin" => {description: "These infections are passed from skin-to-skin contact with affected areas, and are therefore harder to protect against using condoms", diseases: [:Herpes, :HPV]},
  "HIV" => {description: "HIV is currently uncurable, but can be treated if detected early and well-managed", diseases: [:HIV]}}
INSTRUMENTS = [:hand, :genitals, :anus, :mouth, :toys]
PRONOUNS = [
  {subject: "ze", object: "hir", possessive: "hir" , obj_possessive: "hirs", reflexive: "hirself"},
  {subject: "she", object: "her", possessive: "her", obj_possessive: "hers", reflexive: "herself"},
  {subject: "he", object: "him", possessive: "his", obj_possessive: "his", reflexive: "himself"},
  {subject: "they", object: "them", possessive: "their", obj_possessive: "theirs", reflexive: "themself"}]
