class UpdateUserOrganizationService
  def initialize params_user_ids, params_roles
    @user_ids = params_user_ids
    @roles = params_roles
  end

  def update_user
    @user_organization_update = []
    @user_ids.each.with_index(Settings.user_club.number) do |user_id, index|
      member = UserOrganization.load_user user_id
      if member && member.is_admin != @roles[index]
        member.is_admin = @roles[index]
        @user_organization_update << member
      end
    end
    @user_organization_update
  end
end
