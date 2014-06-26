class StiTestsController < ApplicationController
  before_filter :get_diseases
  before_filter :check_sti_test, :except => [:index, :new, :create]
  def index
    @sti_tests = StiTest.where(user_id: session[:user_id]).order("date_taken DESC")
    @diseases = DISEASES
    @categories = DISEASE_CATEGORIES
    @overdue_list = @user.overdue_tests
  end
  def new
    @sti_test = StiTest.new
    @infection = @sti_test.infections.new
  end
  def create
    @sti_test = StiTest.new(params[:sti_test])
    @sti_test.user_id = session[:user_id]
    if @sti_test.save
      redirect_to sti_test_path(@sti_test)
    else
      redirect_to new_sti_test_path
    end
  end
  def show
    @infections = @sti_test.infections
  end
  def edit
    @sti_test.prep_for_update
    @infections = @sti_test.infections
  end
  def update
    if @sti_test.update_attributes(params[:sti_test])
      params[:sti_test][:infections_attributes].each do |key, value|
        if value[:positive] == "_destroy" && value[:id]
          Infection.find(value[:id]).destroy
        end
      end
      redirect_to sti_test_path(@sti_test)
    else
      redirect_to edit_sti_test_path
    end
  end
  def destroy
    @sti_test = StiTest.find(params[:id])
    @sti_test.destroy
  end
  private
  def check_sti_test
    @sti_test = StiTest.find(params[:id])
    if @sti_test.user != @user
      redirect_to sti_tests_path
    end
  end
  def get_diseases
    @diseases = DISEASES
  end
end
