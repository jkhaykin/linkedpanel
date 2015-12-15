class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  rescue_from ActionView::MissingTemplate, :with => :template_not_found

  require 'open-uri'
  require 'rake'
  require 'httparty'
  require 'json'
  require 'nokogiri'

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
    if @person.url.include?("linkedin") and @person.url.include?("https")
      @search = HTTParty.get("https://www.google.com/search?q=#{@person.url}", :verify => false)
      @my_data = @search.parsed_response
      @page = Nokogiri::HTML(@my_data)
      @name = @page.css("h3 a")[0].children.text.split(" |")[0]
      @headline = @page.css(".f")[0].children.text.split("-")[1][1..-1]
      @person.update_attributes(name: @name, headline: @headline)
      @person.save
    else
      redirect_to people_path, error: "Oops!"
    end
  end

  def destroy
    @person.destroy
    respond_with(@person)
  end

  def down
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
