class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  rescue_from ActionView::MissingTemplate, :with => :template_not_found
  
  require 'nokogiri'
  require 'open-uri'
  require 'rake'

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
    begin
      data = Nokogiri::HTML(open(@person.url))
    rescue ActiveRecord::RecordNotFound
    # handle not found error
    rescue ActiveRecord::ActiveRecordError
    # handle other ActiveRecord errors
    rescue # StandardError
    # handle most other errors
    rescue Exception
    # handle everything else
    end
    
    if data.blank?
      redirect_to people_path, error: "Oops!"
    else
    @name = data.css(".full-name").text
    data.css('header').each_with_index do |per, i|
      per.css('h4').each do |h4|
        if i == 0
          @headline = "#{h4.text} at #{h4.next_element.text}"
        end
      end
    end
    @person.update(name: @name, headline: @headline)
    @person.save
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
      params.require(:person).permit(:name, :url)
    end
    
    def template_not_found
      redirect_to root_path
    end
end
