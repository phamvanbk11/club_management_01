class ClubManager::ImportUserClubsController < BaseClubManagerController
  before_action :load_club, only: :create

  def create
    if params[:file].present?
      if UserClub.open_spreadsheet(params[:file]) == Settings.error_import
        flash[:danger] = t("errors_file_format")
      elsif msg = UserClub.import_file_club(params[:file], @club.organization, @club)
        flash[:success] = t("import_success") + msg
      else
        flash[:danger] = t("errors_file_user")
      end
    else
      flash[:danger] = t("import_file")
    end
    redirect_to :back
  end
end
