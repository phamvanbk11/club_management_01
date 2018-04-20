class VideosController < ApplicationController
  before_action :authenticate_user!
  authorize_resource
  before_action :load_album, only: [:destroy, :create, :update]
  before_action :load_video, only: [:destroy, :update, :upload]

  def create
    filename = params[:filename]
    uuid = SecureRandom.uuid
    ext  = File.extname(filename)
    dir  = Rails.root.to_s + Settings.folder_public + Settings.folder_upload +
      Settings.folder_video
    FileUtils.mkdir_p(dir) unless File.exist?(dir)
    @video = @album.videos.new name: filename,
      video_file: File.join(Settings.folder_upload + Settings.folder_video, "#{uuid}#{ext}"),
      user_id: current_user.id
    if @video.save
      render json: {id: @video.id, uploaded_size: @video.uploaded_size}
    else
      render json: {error: @video.errors}
    end
  end

  def upload
    if @video && params[:video][:url]
      file = params[:video][:url]
      @video.uploaded_size += file.size
      if @video.save
        File.open(Rails.root.to_s + Settings.folder_public + @video.video_file,
          Settings.type_write){|f| f.write(file.read)}
        render json: {id: @video.id, uploaded_size: @video.uploaded_size}
      else
        flash.now[:danger] = t ".error_upload"
        render json: {error: @video.errors}
      end
    end
  end

  def update
    if @video
      uuid = SecureRandom.uuid
      ffmpeg = FFMPEG::Movie.new Rails.root.to_s + Settings.folder_public + @video.video_file
      dir = Rails.root.join Settings.path_images_screenshot
      FileUtils.mkdir_p(dir) unless File.exist?(dir)
      image = ffmpeg.screenshot(Settings.path_images_screenshot + uuid + Settings.ext_image_screen)
      if @video.update_attributes is_success: true,
        image_file: Settings.folder_upload + Settings.folder_image_video +
          "/#{uuid}" + Settings.ext_image_screen
        flash.now[:success] = t ".upload_success"
      else
        flash.now[:danger] = t ".upload_errors"
      end
    end
    @club = @album.club
    @videos = @album.videos.upload_success
    render json: {html: render_to_string(partial: "videos/list_video", locals: {videos: @videos,
      club: @club, album: @album}), message: render_to_string(partial: "shared/flash_warning")}
  end

  def destroy
    if @video && @video.destroy
      delete_file @video.video_file
      delete_file @video.image_file
      flash.now[:danger] = t "club_manager.video.deleted"
    else
      flash.now[:error] = t "club_manager.video.cant_delete"
    end
    respond_to do |format|
      format.js
    end
  end

  private
  def load_video
    @video = Video.find_by id: params[:id]
    return if @video
    flash.now[:danger] = t ".not_found_video"
  end

  def load_album
    @album = Album.find_by id: params[:album_id]
    return if @album
    flash.now[:danger] = t "not_found_album"
    redirect_to root_path
  end

  def delete_file path
    File.delete Rails.root.to_s + Settings.folder_public + path
  end
end
