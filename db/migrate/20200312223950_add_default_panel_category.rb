class AddDefaultPanelCategory < Mongoid::Migration
	def self.up
		Diagnosis.find(:hiv, :chlamydia, :gonorrhea, :syphillis).each do |d|
			next if d.category.include? :default

			d.category.push(:default)
			d.save
		end
	end

	def self.down
	end
end
