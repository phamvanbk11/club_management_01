namespace :db do
  desc "add_setting"
  task add_setting: :environment do
    organization = Organization.all
    organization.each do |org|
      org.organization_settings.create key: Settings.key_date_remind_month, value: 25
      org.organization_settings.create key: Settings.key_date_remind_quarter, value: 25
      org.organization_settings.create key: Settings.key_dealine_report, value: 30
      org.organization_settings.create key: Settings.key_date_report, value: 30
    end
  end
end
