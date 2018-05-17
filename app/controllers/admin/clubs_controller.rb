class Admin::ClubsController < Admin::AdminController
  before_action :load_organization
  before_action :load_club, only: [:show, :destroy, :edit, :update]

  def index
    @q = @organization.clubs.search params[:q]
    @clubs = @q.result.includes(:user_clubs)
      .newest.page(params[:page]).per Settings.club_per_page
  end

  def show
    @support = Support::ClubSupport.new @club, params[:page], @organization
  end

  def update
    @club_update = @club.update_attributes club_params
    if @club_update
      flash[:success] = t "club_manager.club.success_update"
      redirect_to admin_organization_clubs_path(@organization)
    else
      flash_error @club
      redirect_to edit_admin_organization_clubs_path(@organization, @club)
    end
  end

  def destroy
    if @club.destroy
      flash.now[:success] = t "delete_success"
    else
      flash.now[:danger] = t "delete_club_type_error"
    end
  end

  private
  def club_params
    params.require(:club).permit :name, :content, :goal, :logo, :rules,
      :rule_finance, :time_join, :image, :tag_list, :plan, :punishment, :member,
      :local, :activities_connect, time_activity: []
  end

  def load_organization
    @organization = Organization.friendly.find_by slug: params[:organization_id]
    return if @organization
    flash[:danger] = t("organization_not_found")
    redirect_to admin_path
  end

  def load_club
    @club = Club.friendly.find_by slug: params[:id]
    return if @club
    flash[:danger] = t("not_found")
    redirect_to admin_path
  end
end
