class DiseaseEnum
  attr_reader :name, :readable, :gestation_min, :gestation_max, :barriers_effective, :risky_contacts, :category
  def initialize(hsh)
    @name = hsh[:name]
    @readable = hsh[:readable]
    @gestation_min = hsh[:gestation_min]
    @gestation_max = hsh[:gestation_max]
    @barriers_effective = hsh[:barriers_effective]
    @risky_contacts = hsh[:risky_contacts]
    @category = hsh[:category]
  end
end
