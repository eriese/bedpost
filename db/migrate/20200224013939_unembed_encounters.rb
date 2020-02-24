class UnembedEncounters < Mongoid::Migration
	def self.up
		UserProfile.each do |user|
			next unless user.partnerships.any?
			user.partnerships.each do |ship|
				next if ship.attributes['encounters'].blank?
				ship.attributes['encounters'].each do |enc|
					enc['partnership_id'] = ship['_id']
					user.encounters << Encounter.new(enc)
				end
			end
		end
	end

	def self.down
		UserProfile.each do |user|
			user.encounters.destroy_all
		end
	end
end
