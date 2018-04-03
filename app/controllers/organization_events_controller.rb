class OrganizationEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_organization, only: [:index]

  def index
    @organization_event = @organization.events.status_public(true)
      .newest.page(params[:page]).per Settings.club_per_page
  end

  private
  def load_organization
    @organization = Organization.includes(:events).friendly.find_by slug: params[:id]
    return if @organization
    flash[:danger] = t("organization_not_found")
    redirect_to root_url
  end
end
