class IntercomPayload
  attr_accessor :contact_data, :company_data
  def initialize(data)
    @contact_data = self.contact(data[:user])
    @company_data = self.company({ meta: data[:account], features: data[:features] })
  end
  def contact(c)
    puts "#{c.first_name} #{c.last_name}"
=begin
    "type": "user",
    "id": "530370b477ad7120001d",
    "user_id": "25",
    "email": "wash@serenity.io",
    "phone": "+1123456789",
    "name": "Hoban Washburne",
    "updated_at": 1392734388,
    "last_seen_ip" : "1.2.3.4",
    "unsubscribed_from_emails": false,
    "last_request_at": 1397574667,
    "signed_up_at": 1392731331,
    "created_at": 1392734388,
    "session_count": 179,
    "user_agent_data": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9",
    "pseudonym": null,
    "anonymous": false,
    "custom_attributes": {
      "paid_subscriber" : true,
      "monthly_spend": 155.5,
      "team_mates": 1
    }
=end
  end

  def company(c)
    # https://api.intercom.io/companies
    puts "#{c[:meta].name} - is #{c[:features].num_contacts} enough? #{c[:features].enough_contacts}"

=begin
  "name": "Blue Sun",
  "plan": "Paid",
  "company_id": "6",
  "remote_created_at": 1394531169,
  "size": 750,
  "website": "http://www.example.com",
  "industry": "Manufacturing",
  "custom_attributes": {
    "paid_subscriber" : true,
    "team_mates": 0,
    "monthly_spend": 155.98
  }
=end
  end

=begin
  'Name'
  'Email'
  'Phone'
  'Company name'
  'Company size'
  'Company website'
  'Company industry'
  'Lead category'
  'Conversation rating'
  'Last contacted'
  'Last heard from'
  'Last opened email'
  'Last clicked on link in email'
  'Browser language'
  'Language override'
  'Browser'
  'Browser version'
  'Os'
  'Twitter followers'
  'Unsubscribed from emails'
  'Marked email as spam'
  'Has hard bounced'
  'Utm campaign'
  'Utm content'
  'Utm medium'
  'Utm source'
  'Utm term'
  'Referral url'
  'Contact status'
  'Tags'
  'Hb user id'
=end
end
