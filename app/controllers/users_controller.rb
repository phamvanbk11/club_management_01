class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_user, only: [:show, :edit, :update]
  before_action :load_organizations, only: :show
  authorize_resource

  def show
    @clubs = Club.of_user_clubs(@user.user_clubs.joined)
      .page(params[:page]).per Settings.user.club_per_page
    @club_time_lines = current_user.clubs
  end

  def edit
    @user = current_user
    return if current_user
    flash[:danger] = t("user_not_found")
    redirect_to root_url
  end

  def update
    if @user.update user_params
      flash[:success] = t("update_user_success")
      bypass_sign_in @user
      redirect_to user_url(@user)
    else
      flash_error @user
      redirect_back fallback_location: user_path(id: current_user.id)
    end
  end

  private
  def load_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t("user_not_found")
    redirect_to root_url
  end

  def user_params
    params.require(:user).permit :full_name, :email, :phone, :avatar,
      :password, :password_confirmation, :tag_list, :tag, {tag_ids: []}, :tag_ids
  end

  def load_organizations
    @organizaitons = Organization.by_user_organizations(
      @user.user_organizations.joined
    )
  end
end
