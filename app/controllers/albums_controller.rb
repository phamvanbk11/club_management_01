class AlbumsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_club
  before_action :load_album, except: %i(index create)
  authorize_resource

  def index
    load_and_to_hash_albums
  end

  def create
    @album = Album.new album_params
    if @album.save
      create_acivity @album, Settings.create, @album.club, current_user,
        Activity.type_receives[:club_member]
      flash.now[:success] = t "club_manager.album.success_create"
    else
      flash_error @album
    end
    load_and_to_hash_albums
  end

  def show
    @image = Image.new
    @videos = @album.videos.upload_success
    @other_albums = @club.albums.includes(:images).newest.other(@album.id)
      .page(params[:page]).per Settings.per_page_album
    @hash_other_albums = @other_albums.group_by{|e| e.created_at&.beginning_of_month}
  end

  def destroy
     if @album && @album.destroy
      flash.now[:success] = t "success_process"
    elsif @album
      flash.now[:danger] = t "error_process"
    end
  end

  def edit; end

  def update
    if @album && @album.update_attributes(album_params)
      create_acivity @album, Settings.update, @album.club, current_user,
        Activity.type_receives[:club_member]
      flash.now[:success] = t "club_manager.album.success_update"
    else
      flash_error @album
    end
  end

  private
  def load_club
    @club = Club.find_by slug: params[:club_id]
    return if @club
    if request.xhr?
      flash.now[:danger] = t "flash_not_found.club"
    else
      flash[:danger] = t "flash_not_found.club"
      redirect_to root_path
    end

  end

  def load_album
    if @club
      @album = Album.includes(:images).find_by id: params[:id]
      return if @album
      if request.xhr?
        flash.now[:danger] = t "flash_not_found.album"
      else
        flash[:danger] = t "flash_not_found.album"
        redirect_to @club
      end
     end

  end

  def album_params
    params.require(:album).permit(:name).merge! club_id: @club.id
  end

  def load_and_to_hash_albums
    @albums = @club.albums.newest.includes(:images).page(params[:page])
      .per Settings.per_page_album
    @hash_albums = @albums.group_by{|e| e.created_at&.beginning_of_month}
  end
end
