namespace 'admin' do
	def ask_for(question)
		print question + ': '
		STDIN.gets.chomp
	end

	task :send_beta_invite, [:email, :name] => :environment do |_t, args|
		email = args[:email] || ask_for('email address')
		name = args[:name] || ask_for('name')

		if BetaMailer.beta_invite(email, name).deliver_now
			puts "successfully sent beta invitation to #{name} at #{email}."
		else
			puts "somehow that didn't work"
		end
	end
end
