class IntercomPayload
  attr_accessor :contact_data, :company_data

  # mapping user and account company data to IntercomPayload object attributes
  def initialize(data)
    @contact_data = self.contact(data[:user])
    @company_data = self.company(data[:account], data[:features])
  end

  # flatten and JSONize self for API call to intercom
  def package
    @contact_data[:companies] = [ @company_data ]
   return @contact_data.to_json
  end
  
  def contact(c)
    contact_metadata = {
      name: "#{c.first_name} #{c.last_name}",
      user_id: c.user_id,
      email: c.email,
      signed_up_at: c.created_date,
      custom_attributes: {
        'Is Owner' => c.owner_ind,
        'Is Admin' => c.admin_ind,
        'Has Activated' => c.activated,
        'Contact Status' => c.status
      }
    }
  end

  # accepts company metainfo and features
  def company(m,f)
    # https://api.intercom.io/companies
    company_metadata = {
      name: m.name,
      plan: m.plan,
      company_id: m.account_company_id,
      user_count: m.num_users,
      monthly_spend: m.mrr,
      industry: m.industry,
      custom_attributes: {
        # metadata
        'signed_at' => m.signed_date.nil? ? nil : m.signed_date.to_i, # cast to unix seconds
        'Partner Status' => m.partner_status, 
        'Sales Rep' => m.sales_rep, 
        'Original HBC' => m.original_hbc,
        'transitioned_at' => m.transition_date.nil? ? nil : m.transition_date.to_i,
        'QS Program' => m.qs_program,
        'Onboarding Stage' => m.onboarding_stage,
        'Onboarding Sessions' => m.onboarding_sessions,
        'International' => m.international,
        # features
        'Unused Users' => f.unused_users,
        'Contacts - more than 5' => f.enough_contacts,
        'Contacts - imported a CSV' => f.has_imported,
        'Number of Contacts' => m.num_contacts, # meta
        'Contacts - custom status' => f.custom_statuses,
        'Custom Fields' => f.has_custom_fields,
        'Deals - created' => f.has_deals,
        'Deals - custom stage' => f.custom_stages,
        'Email Sync' => f.email_integration,
        'Email Template' => f.has_templates,
        'Email Template - has automations' => f.template_automations,
        'Forms' => f.has_forms,
        'Forms - number of submissions' => f.submissions,
        'Forms - has automations' => f.form_automations,
        'Event Based Campaign' => f.event_campaigns,
        'Event Based Campaign - contacts on' => f.contacts_on_event_campaigns,
        'Regular Campaign' => f.reg_campaigns,
        'Regular Campaign - contacts on' => f.contacts_on_reg_campaigns,
        'Tags' => f.has_tags,
        'Tags Rules' => f.has_tag_rules,
        'Tag Rules - triggered' => f.contacts_triggered_tag_rules,
        'Webpage Tracking' => f.tracked_webpage
      }.reject { |k,v| v.nil? }
    }
  end

end
