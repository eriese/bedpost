class StiTestsController < ApplicationController
	def new
		gon_sti_test_data
	end

	def gon_sti_test_data
		gon.diagnoses = Diagnosis.list
		gon.dummy = StiTest.new
	end
end
