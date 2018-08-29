require 'intercom'
require './hatchbuck'
require './intercom'
require 'dotenv/load'

intercom = Intercom::Client.new token: ENV['INTERCOM_KEY']

intercom_users = Array.new
intercom.users.all.each do |u|
	intercom_users.push u
end

intercom_users.each do |u|
	puts "id: #{u.custom_attributes['HB User ID']} | email: #{u.email}"
end

bo = BizOps.new
bo.get_users

# user.custom_attributes["average_monthly_spend"] = 1234.56




