require 'intercom'
require 'dotenv/load'

class Contact
	attr_accessor :external_id, :hb_user_id, :first_name, :last_name, :email, :custom_fields
	def initialize(c)
		name = c.name.split
		self.first_name = name.first
		self.last_name = name.drop(1).join(' ').strip
		self.external_id = c.id
		self.email = c.email
		self.custom_fields = c.custom_attributes

		self.hb_user_id = c.custom_attributes['HB User ID']
	end
end

intercom = Intercom::Client.new token: ENV['INTERCOM_KEY']

hb_contacts = Array.new
users = intercom.users.all.each do |u|
	hb_contacts.push(Contact.new(u))
end

hb_contacts.each do |hb|
	puts "\ncontact object #{hb.external_id}: #{hb.first_name} #{hb.last_name} - #{hb.email}\nCustomfields:"
	puts hb.custom_fields.each { |k,v| puts "#{k}: #{v}" }
end



