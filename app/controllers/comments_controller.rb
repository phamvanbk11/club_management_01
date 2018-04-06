class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_comment, except: :create

  def create
    comment = Comment.new comment_params
    if comment.save
      @event = comment.target
      @comments = @event.comments.newest.take(Settings.limit_comments)
      create_acivity comment.target, Settings.comment, comment.target.club, current_user,
        Activity.type_receives[:club_member]
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js{alert(t("comment_fail"))}
      end
    end
  end

  def destroy
    unless @comment.destroy
      flash.now[:danger] = t("error_process")
    end
    @comments = @comment.target.comments.newest.take(Settings.limit_comments)
    respond_to do |format|
      format.js
    end
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def update
    @comment.update_attributes content: params[:comment][:content]
    respond_to do |format|
      format.js
    end
  end

  private
  def comment_params
    params.require(:comment).permit(:target_id,
      :target_type, :content).merge! user_id: current_user.id
  end

  def load_comment
    @comment = Comment.find_by id: params[:id]
    unless @comment
      flash[:danger] = t("not_found_comment")
      redirect_back fallback_location: root_path
    end
  end
end
