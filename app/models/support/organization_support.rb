class Support::OrganizationSupport
  attr_reader :organization

  def initialize organization, page, q
    @organization = organization
    @page = page
    @q = q
  end

  def members
    user_ids = @q.result.ids
    @organization.user_organizations.includes(:user).by_user_ids(user_ids)
      .are_member.joined.newest.page(@page).per Settings.per_page_user
  end

  def admins
    user_ids = @q.result.ids
    @organization.user_organizations.includes(:user).by_user_ids(user_ids)
      .are_admin.newest.page(@page).per Settings.per_page_user
  end

  def clubs
    @organization.clubs
  end

  def size_members
    @organization.user_organizations.are_member.joined.size
  end

  def size_admins
    @organization.user_organizations.are_admin.size
  end
end
