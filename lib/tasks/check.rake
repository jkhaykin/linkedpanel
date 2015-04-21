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
        end
      end
    end
      if person.headline != @headline
        message = {  
          :subject=> "#{person.name} Has An Updated Linkedin Headline",  
          :from_name=> "Headlinked | Linkedin Headline Checker",  
          :text=>"#{person.name}'s updated Linkedin headline is: #{@headline}",  
          :to=>[  
          {  
          	:email=> "#{User.find(person.user_id).email}"
          }  
          	], 
          :from_email=>"jon@jonkhaykin.com",
          :html=>"#{person.name}'s updated Linkedin healine is: <h3><a href='#{person.url}'>#{@headline}.</a></h3>"
          } 
          person.update(headline: @headline)
          person.save
          sending = m.messages.send message  
          puts "#{sending} #{person.name} sent to #{User.find(person.user_id).email}"
      else
      end
    end
end