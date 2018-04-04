class Admin::UsersController < Admin::AdminController
  before_action :load_user, except: [:index, :new, :create]
  authorize_resource

  def new
    @user = User.new
  end

  def create
    @user = User.new params_user
    if @user.save
      flash.now[:success] = t "admin_manage.create_success"
    else
      flash.now[:danger] = t "admin_manage.errors"
    end
  end

  def edit; end

  def show; end

  def index
    @q = User.search params[:q]
    @users = @q.result.includes(:user_organizations, :organizations)
      .newest.page(params[:page]).per Settings.per_page_user
    @organizations = Organization.newest
  end

  def update
    if @user && @user.update_attributes(params_user)
      flash.now[:success] = t "admin_manage.update_success"
    elsif @user
      flash.now[:danger] = t "admin_manage.errors"
    end
  end

  def destroy
    if @user && @user.destroy
      flash.now[:success] = t "admin_manage.destroy_success"
    elsif @user
      flash.now[:danger] = t "admin_manage.errors"
    end
  end

  private

  def load_user
    @user = User.find_by id: params[:id]
    return if @user
    flash.now[:danger] = t("can_not_found_user")
  end

  def params_user
    params.require(:user).permit :full_name, :email, :phone, :password, :password_confirmation, :employee_code
  end
end
