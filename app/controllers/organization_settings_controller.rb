class OrganizationSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_organization
  before_action :load_settings
  authorize_resource

  def index; end

  def update
    if @organization && params[:settings]
      import_settings params[:settings]
      system Settings.command_update_whenever
      flash.now[:success] = t ".update_success"
    else
      flash.now[:success] = t ".update_errors"
    end
  end

  private
  def load_organization
    @organization = Organization.find_by slug: params[:organization_slug]
    return if @organization
    flash.now[:danger] = t "organization_not_found"
  end

  def load_settings
    if @organization
      @settings = @organization.organization_settings
      @money_supports = @organization.money_supports.group_by &:arr_range
      @range_supports = @organization.range_supports.newest.page(params[:page]).per Settings.per_page_range
      @range_supports_full = @organization.range_supports
    end
  end

  def import_settings settings
    list_settings = []
    settings.each do |key, value|
      setting = @organization.organization_settings.find_by key: key
      if setting
        setting.value = value
        list_settings << setting
      end
    end
    OrganizationSetting.import list_settings, on_duplicate_key_update: [:value] if list_settings
  end
end
