require File.expand_path("../..//config/environment.rb", __FILE__)
set :environment, "production"
set :output, error: "log/cron_error_log.log", standard: "log/cron_log.log"

setting_month = OrganizationSetting.of_key Settings.key_date_remind_month
setting_quarter = OrganizationSetting.of_key Settings.key_date_remind_quarter

if setting_month
  setting_month.each do |setting|
    every "0 0 #{setting.value} * *" do
      rake "send_notification_remind_report_month[#{setting.organization_id}]"
    end
  end
end

if setting_quarter
  setting_quarter.each do |setting|
    every "0 0 #{setting.value} * *" do
      rake "send_notification_remind_report_quarter[#{setting.organization_id}]"
    end
  end
end

every "0 0 * * 0" do
  rake "auto_create_event"
end
