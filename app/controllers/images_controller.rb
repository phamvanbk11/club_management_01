class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_album, only: [:destroy, :create]
  before_action :load_image, except: :create

  def create
    ActiveRecord::Base.transaction do
      params[:images][:urls].each do |img|
        @album.images.create!(url: img)
        flash[:success] = t "add_images_successfully"
      end
      redirect_back fallback_location: club_album_path(id: @album.id)
    end
  rescue
    flash[:danger] = t "error_in_process"
    redirect_back fallback_location: root_path
  end

  def destroy
    if @image.destroy
      flash[:danger] = t "club_manager.image.deleted"
    else
      flash[:error] = t "club_manager.image.cant_delete"
    end
  end

  private
  def load_image
    @image = Image.find_by id: params[:id]
    return if @image
    flash[:danger] = t "flash_not_found.image"
    redirect_to club_album_path @album
  end

  def load_album
    @album = Album.find_by id: params[:album_id]
    return if @album
    flash[:danger] = t "flash_not_found.album"
    redirect_to root_path
  end
end
