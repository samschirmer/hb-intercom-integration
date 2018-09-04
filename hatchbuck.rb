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
  attr_accessor :signed_date, :name, :is_partner, :sales_rep, :account_company_id, :plan, :original_hbc, :transition_date, :qs_program, :onboarding_stage, :onboarding_sessions, :international
  def initialize(c)
    self.signed_date = c['SignedDT']
    self.name = c['AccountCompanyName']
    self.is_partner = ['PartnerInd'] 
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
  attr_accessor :imported_csv, :added_contact, :webpage_tracking, :online_forms, :email_templates, :event_campaigns, :regular_campaigns, :tag_rules, :tasks, :deals, :tags, :account_settings
  def initialize(f)
    self.imported_csv = f['ImportedCSV']
    self.added_contact = f['AddedContact']
    self.webpage_tracking = f['WebpageTracking']
    self.online_forms = f['OnlineForms']
    self.email_templates = f['EmailTemplates']
    self.event_campaigns = f['EventCampaigns']
    self.regular_campaigns = f['RegularCampaigns']
    self.tag_rules = f['TagRules']
    self.tasks = f['Tasks']
    self.deals = f['Deals']
    self.tags = f['Tags']
    self.account_settings = f['AccountSettings']
	end
end

class BizOps
  def initialize
    @client = TinyTds::Client.new username: ENV['USERNAME'], password: ENV['PASSWORD'], host: ENV['HOST'], database: ENV['DATABASE']
  end

  def get_users
    hb = Array.new
    sql = "SELECT * from v_Pendo_Users AS u LEFT JOIN v_Pendo_AccountCompanies AS ac ON ac.AccountCompanyID = u.AccountCompanyID"
    results = @client.execute(sql)
    results.each do |r|
      hb.push({ user: User.new(r), account: AccountCompany.new(r) })
    end

    hb.each do |hb|
      puts "#{hb[:account].account_company_id}: #{hb[:account].name} - #{hb[:user].first_name} #{hb[:user].last_name} | #{hb[:user].email}"
    end

  end
end
