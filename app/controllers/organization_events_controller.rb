class OrganizationEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_organization, only: [:index]

  def index
    return unless @organization
    if params[:q]
      @q = @organization.clubs.search(params[:q])
      club_ids = @q.result.ids
      @organization_event = @organization.events.status_public(true).in_clubs(club_ids)
        .newest.page(params[:page]).per Settings.club_per_page
    else
      @organization_event = @organization.events.status_public(true)
        .newest.page(params[:page]).per Settings.club_per_page
    end
  end

  private
  def load_organization
    @organization = Organization.includes(:events).friendly.find_by slug: params[:id]
    return if @organization
    flash[:danger] = t("organization_not_found")
  end
end
