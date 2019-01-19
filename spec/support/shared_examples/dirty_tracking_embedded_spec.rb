require 'rails_helper'

shared_examples_for 'an object that dirty-tracks its embedded relations' do |class_obj|

	class_obj.embedded_relations.each do |name, rel|
		it "should have a method clear_unsaved_#{name} that clears unpersisted #{name}" do
			expect(class_obj).to respond_to "clear_unsaved_#{name}"

			orig = class_obj.send(name)
			if rel.is_a? Mongoid::Association::Embedded::EmbedsMany
				orig_num = orig.select(&:persisted?).length
				class_obj.send(name).new
				class_obj.send("clear_unsaved_#{name}")
				expect(class_obj.send(name).length).to eq orig_num
			else
				expected = orig.present? && orig.persisted? ? orig : nil
				class_obj.send("#{name}=", rel.klass.new)
				class_obj.send("clear_unsaved_#{name}")
				expect(class_obj.send(name)).to eq expected
			end
		end
	end
end
