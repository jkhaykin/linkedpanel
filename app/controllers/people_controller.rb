class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  rescue_from ActionView::MissingTemplate, :with => :template_not_found

  require 'open-uri'
  require 'rake'
  require 'linkedin-scraper'

  respond_to :html

  def index
    @people = Person.where(:user_id => current_user)
    @person = Person.new
    respond_with(@people)
  end

  def new
    @person = Person.new
    respond_with(@person)
  end

  def edit
  end

  def create
    @person = Person.new(person_params)
    @person.user = current_user
    @headline = []
    @duration = []
    if @person.url.include?("linkedin") and @person.url.include?("https")
      profile = Linkedin::Profile.get_profile("#{@person.url}")
      @name = profile.name
      profile.current_companies.each do |position|
        @headline += ["#{position[:title]} at #{position[:company]}"]
        @duration += ["#{position[:start_date]} - Present"]
      end
      @person.update_attributes(name: @name, headline: @headline, duration: @duration)
      @person.save
    else
      redirect_to people_path, error: "Oops!"
    end
  end

  def destroy
    @person.destroy
    respond_with(@person)
  end

  private
    def set_person
      @person = Person.find(params[:id])
    end

    def person_params
      params.require(:person).permit(:name, :url, :duration)
    end
    
    def template_not_found
      redirect_to root_path
    end
end
