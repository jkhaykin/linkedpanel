class Person < ActiveRecord::Base

belongs_to :user

validates_presence_of :headline

end
