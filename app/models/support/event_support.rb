class Support::EventSupport
  attr_reader :event

  def initialize event, club
    @event = event
    @club = club
  end

  def expense_pending
    @event.donates.pending.expense_pending
  end

  def members_done
    User.with_deleted.done_by_ids(@event.budgets.pluck :user_id)
  end

  def members_yet
    @club.users.yet_by_ids(@event.budgets.pluck :user_id)
  end

  def comments
    @event.comments.includes(:user).newest
  end

  def posts
    @event.posts.includes(:user, :post_galleries).newest.page(Settings.page_default).per Settings.per_page
  end

  def load_albums
    @event.albums.first
  end

  def build_image
    @event.albums.first.images.build
  end

  def images
    @event.albums.first.images
  end

  def videos
    @event.albums.first.videos
  end
end
