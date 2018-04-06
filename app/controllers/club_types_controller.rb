class ClubTypesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_organization
  before_action :load_club_types
  before_action :find_club_type, only: %i(edit destroy update)
  authorize_resource

  def create
    @club_type = @organization.club_types.new club_type_params
    respond_to do |format|
      if @club_type.save
        flash.now[:success] = t "create_club_type"
      else
        format.json{render json: @club_type}
      end
      format.js
    end
  end

  def index; end

  def edit; end

  def destroy
    respond_to do |format|
      if @club_type.clubs.size == Settings.club_type_delete
        delete_club_type
      else
        flash.now[:danger] = t "exist_club"
      end
      format.js
    end
  end

  def update
    respond_to do |format|
      if @club_type.update_attributes name: params[:name]
        flash.now[:success] = t "update_club_type"
      else
        flash.now[:success] = t "update_error"
      end
      format.js
    end
  end

  private

  def delete_club_type
    if @club_type.destroy
      flash.now[:success] = t "delete_club_type"
    else
      flash[:danger] = t "delete_club_type_error"
    end
  end

  def load_organization
    @organization = Organization.friendly.find_by slug: params[:organization_id]
    return if @organization
    flash.now[:danger] = t "organization_not_found"
  end

  def load_club_types
    if @organization
      @club_types = @organization.club_types.order_desc.page(params[:page])
        .per Settings.per_page_type
    end
  end

  def find_club_type
    @club_type = ClubType.find_by id: params[:id]
    return if @club_type
    flash[:warning] = t "error_find_type"
  end

  def club_type_params
    params.require(:club_type).permit :name
  end
end
