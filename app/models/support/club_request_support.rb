class Support::ClubRequestSupport
  attr_reader :club_request

  def initialize user, params
    @params = params
    @user = user
  end

  def new_club_request
    ClubRequest.new
  end

  def organizations
    @user.user_organizations.includes(:organization).joined
  end

  def frequencies
    Frequency.by_organization(
      @params[:organization_id] || organizations.first.id)
  end

  def club_types
    ClubType.of_organization(
      @params[:organization_id] || organizations.first.id)
  end

  def user_organizations
    UserOrganization.load_user_organization(
      @params[:organization_id] || organizations.first&.id)
      .except_me(@user.id).includes :user
  end
end
