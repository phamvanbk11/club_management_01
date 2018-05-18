class Admin::UserClubsController < Admin::AdminController
  before_action :load_club
  before_action :load_user_club, only: [:update, :destroy, :create]

  def create
    if params[:user_ids]
      import_member
    elsif @member
      load_user_club
      unless @member.joined!
        flash.now[:danger] = t "namespace_admin.errors_in_process"
      end
    end
  end

  def index
    @support = Support::ClubSupport.new @club, params[:page], @club.organization
  end

  def update
    if @member && @member.update_attributes(is_manager: status_params_add_admin?)
      flash.now[:success] = t "admin_manage.member.success"
    elsif @member
      flash.now[:danger] = t "admin_manage.member.errors"
    end
  end

  def destroy
    if @member && @member.destroy
      flash.now[:success] = t "admin_manage.member.success_destroy"
    elsif @member
      flash.now[:danger] = t "admin_manage.member.errors"
    end
  end

  private
  def load_club
    @club = Club.find_by slug: params[:club_id]
    return if @club
    flash.now[:danger] = t "namespace_admin.not_found_club"
  end

  def load_user_club
    @member = UserClub.find_by(id: params[:id]) if @club
    return if @member
    flash.now[:danger] = t "namespace_admin.not_found_user_club"
  end

  def status_params_add_admin?
    params[:add_admin] == Settings.string_true
  end

  def import_member
    user_clubs = []
    params[:user_ids].each do |user_id|
      user_clb = @club.user_clubs.new user_id: user_id, status: :joined
      user_clubs << user_clb
    end
    if UserClub.import user_clubs
      flash[:success] = t "import_success"
    else
      flash[:success] = t "namespace_admin.errors_in_process"
    end
    redirect_to admin_organization_club_path(@club.organization, @club)
  end
end
