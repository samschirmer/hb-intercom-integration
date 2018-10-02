require 'tiny_tds'
require 'dotenv/load'

# using exotically named views and tables with all manners of column naming
# correcting for activerecord would be about as much work as just defining the classes here
class User
	attr_accessor :user_id, :first_name, :last_name, :email, :owner_ind, :admin_ind, :created_date, :activated, :status
  def initialize(c)
		self.first_name = c['FirstName']
		self.last_name = c['LastName']
		self.user_id = c['UserID']
    self.email = c['EmailAddress']
    self.owner_ind = c['OwnerInd']
    self.admin_ind = c['AdminInd']
    self.created_date = c['CreatedDT']
    self.activated = c['UserStatus']
    self.status = c['ContactStatus']
  end
end

class AccountCompany
  attr_accessor(
    :signed_date, :name, :num_contacts, :is_partner, :sales_rep, 
    :account_company_id, :plan, :original_hbc, :transition_date, 
    :qs_program, :onboarding_stage, :onboarding_sessions, :international,
    :industry, :num_users, :mrr, :partner_status
  )
  def initialize(c)
    self.signed_date = c['SignedDT']
    self.name = c['AccountCompanyName']
    self.num_contacts = c['Contacts'] 
    self.industry = c['Industry'] 
    self.is_partner = c['PartnerInd'] 
    self.sales_rep = c['SalesRepName']
    self.num_users = c['Users']
    self.account_company_id = c['AccountCompanyID']
    self.plan = c['Name']
    self.mrr = c['MRR']
    self.original_hbc = c['OriginalHBC'] # cf 80
    self.transition_date = c['TransitionDate'] # cf 30172
    self.qs_program = c['QSProgram'] # cf 26290
    self.onboarding_stage = c['OnboardingStage'] # cf 6960
    self.onboarding_sessions = c['OnboardingSessions'] # cf 9416
    self.international = c['International'] # cf 16440
    self.partner_status = c['PartnerStatus'] # contactstatusid in (65991, 84895, 88783, 88784)
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

  def get_companies 
    results = @client.execute("SELECT * FROM v_Pendo_AccountCompanies WHERE accountstatus = 'active'")
    companies = Array.new
    results.each(as: :hash) do |r|
      companies.push(r)
    end
    return companies
  end

  def pull_active_data
    to_process = Array.new
    user_ids = Array.new
    active_user_ids_sql = "  SELECT top 2500 userid FROM tblIntercomQueue 
                              WHERE lastprocesseddt <= dateadd(hh, -1, getutcdate()) AND status = 'Active' 
                              ORDER BY lastprocesseddt"
    results = @client.execute(active_user_ids_sql)
    results.each(as: :hash) do |r|
      user_ids.push(r['userid'])
    end

    # debug
    puts "actives: #{user_ids.count}"
    if user_ids.count < 2500
      inactive_user_ids_sql = "  SELECT TOP #{ 2500 - user_ids.count } userid FROM tblIntercomQueue 
                        WHERE lastprocesseddt <= dateadd(hh, -3, getutcdate()) AND status = 'Inactive' 
                        ORDER BY lastprocesseddt"
      results = @client.execute(inactive_user_ids_sql)
      results.each(as: :hash) do |r|
        user_ids.push(r['userid'])
      end
    end

    puts "total: #{user_ids.count}"

    sql = " SELECT * FROM v_Pendo_Users AS u 
            LEFT JOIN v_Pendo_AccountCompanies AS ac ON ac.AccountCompanyID = u.AccountCompanyID 
            LEFT JOIN v_Intercom_2_full as f on f.account_company_id = ac.accountcompanyid
            WHERE u.userid IN (#{user_ids.join(',')})"
    results = @client.execute(sql)
    results.each(as: :hash) do |r|
      to_process.push({ user: User.new(r), account: AccountCompany.new(r), features: FeatureUsage.new(r) })
    end
    return to_process
  end

  def reconcile_queue(res)
    sql = " UPDATE tblIntercomQueue SET LastProcessedDT = GETUTCDATE(), LastResponseCode = #{res[:status]} 
            WHERE UserID = #{res[:data]['user_id'].to_i}"
    result = @client.execute(sql)
    result.do
  end
end
