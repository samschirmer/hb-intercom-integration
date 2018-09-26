require 'httparty'
require 'json'
require 'intercom'
require './hatchbuck'
require './intercom'
require 'dotenv/load'

intercom = Intercom::Client.new token: ENV['INTERCOM_KEY']

intercom_users = Array.new
intercom.users.all.each do |u|
	intercom_users.push u
end

# pulling users from intercom (debug)
#intercom_users.each do |u|
#	puts "id: #{u.custom_attributes['HB User ID']} | email: #{u.email} is a #{u.type}"
#end

bo = BizOps.new
# hb_records = [{ :user, :account, :features }, { ... }]
hb_records = bo.pull_active_data
#puts hb_records
		
intercom_payloads = Array.new
hb_records.each do |hb|
	intercom_payloads.push(IntercomPayload.new(hb))
end

# push active data to intercom
# max rate limit is 83 per 10 seconds (498 /min)
# using blocking calls to break up db transactions, so it's running slower than that
remaining_calls = 83
intercom_payloads.each do |p|
	response = HTTParty.post(
		'https://api.intercom.io/users', 
		headers: {'Content-Type' => 'application/json', 'Accept' => 'application/json', 'Authorization' => "Bearer #{ENV['INTERCOM_KEY']}" },
		body: p.package
	)
	res = JSON.parse response.body
	bo.reconcile_queue({ status: response.code, data: res })
	remaining_calls -= 1
	puts res
	puts "Remaining calls: #{remaining_calls}..."
	if remaining_calls <= 1
		sleep 2
		remaining_calls = 83
	end
end