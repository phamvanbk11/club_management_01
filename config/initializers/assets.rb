# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'
# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path
Rails.application.config.assets.precompile += %w(application_admin.js ckeditor/config.js images.js
  club_manager/select_tag.js manager/select_tag.js chosen.js bootstrap-tagsinput.js handle_menu.js
  close.js jquery.range.js sort_by_date.js budgets.js load_notification.js.coffee event.js
  add_user_club.js search_member.js donate.js club_request.js statistic_report.js choose_member.js
  choose_member_clubs.js edit_club_type.js tabs.js filter_report.js edit_statistic_report.js search_report.js
  edit_report_category organization_settings club_logo background_club background_org upload_video money_format
  check_box category_report.js option_event_activity.js sponsor.js event_notification.js add_member_join_event.js
  post.js delete_experience.js edit_post.js evaluate.js next_page_time_line.js)
Rails.application.config.assets.precompile += %w(application_admin.css user_login.scss user_login_modal.scss
  organization-details.css intro.css jquery.range.css user_profile tabs.scss)
# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
