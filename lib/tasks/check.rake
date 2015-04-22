desc "import Linkedin current job"
  task :checker => :environment do
    require 'mandrill'
    require 'nokogiri'
	require 'open-uri'
    
    m = Mandrill::API.new('No69LvpEhHWKdVAhdQE_fQ')
    Person.all.each do |person|
    data = Nokogiri::HTML(open(person.url))
    data.css('header').each_with_index do |per, i|
      per.css('h4').each do |h4|
        if i == 0
          @headline = "#{h4.text} at #{h4.next_element.text}"
          @duration = "#{data.at_css('.experience-date-locale').text[/[^(]+/]}"
        end
      end
    end
      if person.headline != @headline or person.duration != @duration
        message = {  
          :subject=> "LinkedPanel: #{person.name} Has An Updated Job on Linkedin",  
          :from_name=> "LinkedPanel | Linkedin Job Notifier",  
          :text=>"#{person.name}'s updated job is: #{@headline} | #{@duration}",  
          :to=>[  
          {  
          	:email=> "#{User.find(person.user_id).email}"
          }  
          	], 
          :from_email=>"jon@linkedpanel.com",
          :html=>"#{person.name}'s updated job is: <h3><a href='#{person.url}'>#{@headline} | #{@duration}</a></h3>"
          } 
          person.update(headline: @headline, duration: @duration)
          person.save
          sending = m.messages.send message  
          puts "#{sending} #{person.name} sent to #{User.find(person.user_id).email}"
      else
      end
    end
end