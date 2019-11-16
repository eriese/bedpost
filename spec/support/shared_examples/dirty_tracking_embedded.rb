require 'rails_helper'

shared_examples_for 'an object that dirty-tracks its embedded relations' do |clazz, class_obj, opts, skip_destroy_after, &block|

	before :all do
		if block
			@obj = block.call
		elsif class_obj != true
			@obj = class_obj.is_a?(Symbol) ? create(class_obj, opts || {}) : class_obj
		end
	end

	after :all do
		@obj.destroy unless skip_destroy_after
	end

	clazz.new.embedded_relations.each do |rel_name, rel|
		it "should have a method clear_unsaved_#{rel_name} that clears unpersisted #{rel_name}" do
			expect(@obj).to respond_to "clear_unsaved_#{rel_name}"

			orig = @obj.send(rel_name)
			if rel.is_a? Mongoid::Association::Embedded::EmbedsMany
				orig_num = orig.select(&:persisted?).length
				@obj.send(rel_name).new
				@obj.send("clear_unsaved_#{rel_name}")
				expect(@obj.send(rel_name).length).to eq orig_num
			else
				expected = orig.present? && orig.persisted? ? orig : nil
				@obj.send("#{rel_name}=", rel.klass.new)
				@obj.send("clear_unsaved_#{rel_name}")
				expect(@obj.send(rel_name)).to eq expected
			end
		end
	end

	it 'responds to #embeds_many' do
		expect(@obj.class).to respond_to :embeds_many
	end
end
