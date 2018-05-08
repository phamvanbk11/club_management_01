class Support::ClubSupport
  attr_reader :club

  def initialize club_value, page, organization
    @club_value = club_value
    @page = page
    @organization = organization
  end

  def members
    @club_value.user_clubs.includes(:user).newest
  end

  def hash_albums
    albums.group_by{|e| e.created_at&.beginning_of_month}
  end

  def albums
    @club_value.albums.includes(:images).newest.page(@page).per Settings.per_page_album
  end

  def events
    @club_value.events.newest.page(@page).per Settings.event_page
  end

  def users
    @organization.user_organizations.joined.without_user_ids(members.map(&:user_id)).includes(:user)
  end

  def images_club
    images = []
    albums = @club_value.albums.newest.includes(:images)
    albums.each do |album|
      album.images.newest.each do |image|
        images << image
      end
    end
    images
  end

  def history_budget
    @club_value.events.without_notification(Event.event_categories[:notification]).newest
  end

  def members_joined
    @club_value.user_clubs.includes(:user).joined.newest
  end

  def members_manager
    @club_value.user_clubs.includes(:user).joined.manager.newest
  end

  def user_requests
    @club_value.user_clubs.includes(:user).pending.newest
  end

  def members_not_manager
    @club_value.user_clubs.includes(:user).joined.are_member.newest
  end

  def messages
    @club_value.messages
  end
 end
