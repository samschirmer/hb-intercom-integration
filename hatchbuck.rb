require 'tiny_tds'
require 'dotenv/load'

class User
	attr_accessor :user_id, :first_name, :last_name, :email, :owner_ind, :admin_ind, :first_login, :activated, :status
  def initialize(c)
		self.first_name = c['FirstName']
		self.last_name = c['LastName']
		self.user_id = c['UserID']
    self.email = c['EmailAddress']
    self.owner_ind = c['OwnerInd']
    self.admin_ind = c['AdminInd']
    self.first_login = c['CreatedDT']
    self.activated = c['UserStatus']
    self.status = c['ContactStatus']
  end
end

class AccountCompany
  attr_accessor(
    :signed_date, :name, :num_contacts, :is_partner, :sales_rep, 
    :account_company_id, :plan, :original_hbc, :transition_date, 
    :qs_program, :onboarding_stage, :onboarding_sessions, :international
  )
  def initialize(c)
    self.signed_date = c['SignedDT']
    self.name = c['AccountCompanyName']
    self.num_contacts = c['Contacts'] 
    self.is_partner = c['PartnerInd'] 
    self.sales_rep = c['SalesRepName']
    self.account_company_id = c['AccountCompanyID']
    self.plan = c['Name']
    self.original_hbc = c['OriginalHBC'] # cf 80
    self.transition_date = c['TransitionDate'] # cf 30172
    self.qs_program = c['QSProgram'] # cf 26290
    self.onboarding_stage = c['OnboardingStage'] # cf 6960
    self.onboarding_sessions = c['OnboardingSessions'] # cf 9416
    self.international = c['International'] # cf 16440
  end
end
    
class FeatureUsage
  attr_accessor(
    :account_company_id, :num_contacts, :enough_contacts, :has_imported, :unused_users, 
    :tracked_webpage, :has_forms, :submissions, :form_automations, :has_templates, 
    :template_automations, :custom_statuses, :custom_stages, :has_custom_fields, 
    :has_deals, :has_tags, :has_tag_rules, :contacts_triggered_tag_rules, :event_campaigns, 
    :contacts_on_event_campaigns, :reg_campaigns, :contacts_on_reg_campaigns, :email_integration
  )
  def initialize(f)
    self.account_company_id	= f['account_company_id']
    self.num_contacts	= f['num_contacts']
    self.enough_contacts = f['enough_contacts']
    self.has_imported = f['has_imported']
    self.unused_users = f['unused_users']
    self.tracked_webpage = f['tracked_webpage']
    self.has_forms = f['has_forms']
    self.submissions = f['submissions']
    self.form_automations	= f['form_automations']
    self.has_templates = f['has_templates']
    self.template_automations = f['template_automations']
    self.custom_statuses = f['custom_statuses']
    self.custom_stages = f['custom_stages']
    self.has_custom_fields = f['has_custom_fields']
    self.has_deals = f['has_deals']
    self.has_tags = f['has_tags']
    self.has_tag_rules = f['has_tag_rules']
    self.contacts_triggered_tag_rules = f['contacts_triggered_tag_rules']
    self.event_campaigns = f['event_campaigns']
    self.contacts_on_event_campaigns = f['contacts_on_event_campaigns']
    self.reg_campaigns = f['reg_campaigns']
    self.contacts_on_reg_campaigns = f['contacts_on_reg_campaigns']
    self.email_integration = f['email_integration']
	end
end

class BizOps
  def initialize
    @client = TinyTds::Client.new username: ENV['USERNAME'], password: ENV['PASSWORD'], host: ENV['HOST'], database: ENV['DATABASE'], timeout: 30
  end

  def get_users
    hb = Array.new
    sql = " SELECT * from v_Pendo_Users AS u 
            LEFT JOIN v_Pendo_AccountCompanies AS ac ON ac.AccountCompanyID = u.AccountCompanyID 
            LEFT JOIN v_Intercom_2_full as f on f.account_company_id = ac.accountcompanyid"
    results = @client.execute(sql)
    results.each do |r|
      hb.push({ user: User.new(r), account: AccountCompany.new(r), features: FeatureUsage.new(r) })
    end

    hb.each do |hb|
#      puts "#{hb[:account].account_company_id}: #{hb[:account].name} - #{hb[:user].first_name} #{hb[:user].last_name} | #{hb[:user].email}\n
#      #{hb[:features].num_contacts} contacts - enough contacts: #{hb[:features].enough_contacts} - has imported: #{hb[:features].has_imported}"
      puts hb
    end
  end
end
