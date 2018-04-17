desc "auto create event"
task auto_create_event: :environment do
  begin
    events = Event.events_auto_create(true)
    activities = []
    ActiveRecord::Base.transaction do
      events.each do |event|
        new_event = Event.create!(name: event.name, description: event.description,
          club_id: event.club_id, user_id: event.user_id, date_start: event.date_start + Settings.day_of_week,
          date_end: event.date_end + Settings.day_of_week, location: event.location,
          status: event.status, event_category: event.event_category,
          is_public: event.is_public, is_auto_create: true)
        activities << Activity.new(key: Settings.create, trackable: new_event,
          owner_type: User.name, owner_id: new_event.user_id,
          type_receive: Activity.type_receives[:club_member],
          container_type: Club.name, container_id: new_event.club.id)
        event.is_auto_create = false
      end
      Activity.import! activities
      Event.import! events.to_a, on_duplicate_key_update: [:is_auto_create]
    end
  rescue Exception => e
    puts e.message
    sleep(Settings.second_sleep_retry_task)
    retry
  end
end
