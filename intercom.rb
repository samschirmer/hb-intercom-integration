class IntercomUser
	attr_accessor :external_id, :hb_user_id, :first_name, :last_name, :email, :custom_fields
	def initialize(c)
		name = c.name.split
		self.first_name = name.first
		self.last_name = name.drop(1).join(' ').strip
    self.external_id = c.id
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
