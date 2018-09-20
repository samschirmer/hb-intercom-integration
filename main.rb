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
# hb_records = [{ :user, :account, :features }, { ... }]
hb_records = bo.pull_active_data
		
intercom_payloads = Array.new
hb_records.each do |hb|
	intercom_payloads.push(IntercomPayload.new(hb))
#  puts hb
end

# push active data to intercom
# example: user.custom_attributes["average_monthly_spend"] = 1234.56

# get inactive data from bizops (u.userstatus != 'Active')
hb_records = bo.pull_inactive_users
# delete user from intercom

# ensure we dont have orphaned companies with zero active users