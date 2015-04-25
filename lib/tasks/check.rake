desc "import Linkedin current job"
  task :checker => :environment do
    require 'mandrill'
    require 'nokogiri'
	require 'open-uri'
    
    m = Mandrill::API.new('No69LvpEhHWKdVAhdQE_fQ')
    Person.all.each do |person|
      @headline = []
      @duration = []
      profile = Linkedin::Profile.get_profile("#{person.url}")
      @name = profile.name
      profile.current_companies.each do |position|
        @headline += ["#{position[:title]} at #{position[:company]}"]
        @duration += ["#{position[:start_date]} - Present"]
      end
      
      if @headline == person.headline or @duration != person.duration
        message = {  
          :subject=> "LinkedPanel: #{person.name} has an updated job",  
          :from_name=> "LinkedPanel | Linkedin Job Notifier",  
          :text=>"#{person.name}'s updated job profile is: #{@headline} | #{@duration}",  
          :to=>[  
          {  
          	:email=> "jkaykin@gmail.com"
          }  
          	], 
          :from_email=>"jon@linkedpanel.com",
          :html=>"#{person.name}'s updated job profile is: <h3><a href='#{person.url}'>#{@headline.each {|job| puts job }} | #{@duration.each {|date| puts date}}</a></h3>"
          } 
          person.update_attributes(name: @name, headline: @headline, duration: @duration)
          person.save
          sending = m.messages.send message
          puts "#{sending} #{person.name} sent to #{User.find(person.user_id).email}"
      end
    end
end