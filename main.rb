require 'faraday'
require 'typhoeus'
require 'typhoeus/adapters/faraday'

require 'httparty'
require 'json'
require 'intercom'
require './hatchbuck'
require './intercom'
require 'dotenv/load'

script_start_time = Time.now

bo = BizOps.new
# hb_records = [{ :user, :account, :features }, { ... }]
hb_records = bo.pull_active_data
		
intercom_payloads = Array.new
hb_records.each do |hb|
	intercom_payloads.push(IntercomPayload.new(hb))
end

conn = Faraday.new(url: "https://api.intercom.io/users" , ssl: {verify: false} ) do |faraday|
	faraday.request  :retry, max:5, interval: 1, interval_randomness: 0.5 
	faraday.adapter  :typhoeus
	faraday.headers['Content-Type'] = 'application/json'
	faraday.headers['Accept'] = 'application/json'
	faraday.headers['Authorization'] = "Bearer #{ ENV['INTERCOM_KEY'] }"
end 

# max rate limit is 83 per 10 seconds (498 /min)
# any more workers breaks that threshold -- keep at 2
api_loop_start = Time.now
api_responses = Array.new
manager = Typhoeus::Hydra.new(max_concurrency: 2)
conn.in_parallel(manager) do
  intercom_payloads.each do |p|
    api_responses << conn.post do |req|
			req.body = p.package
		end
	end
end
puts "API call loop runtime: #{ (Time.now - api_loop_start).round } seconds"

api_responses.each do |r|
	body = JSON.parse r.body
	bo.reconcile_queue({ status: r.status, data: body })
end

puts "Script runtime: #{ (Time.now - script_start_time).round } seconds"