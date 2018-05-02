class FrequenciesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_organization
  before_action :load_frequency, only: [:edit, :update, :destroy]
  before_action :new_frequency, only: :create
  authorize_resource

  def new
    if @organization
      @frequency = @organization.frequencies.new
      gon.operators = Frequency.operators
    end
  end

  def create
    if @frequency.save
      flash.now[:success] = t ".create_success"
    elsif @frequency.errors.blank?
      flash.now[:danger] = t ".create_errors"
    end
  end

  def update
    return unless @frequency
    if @frequency.update_attributes frequency_params
      flash.now[:success] = t ".update_success"
    elsif @frequency.errors.blank?
      flash.now[:danger] = t ".update_errors"
    end
  end

  def destroy
    return unless @frequency
    if @frequency.destroy
      flash.now[:success] = t ".destroy_success"
    elsif @frequency.errors.blank?
      flash.now[:danger] = t ".destroy_errors"
    end
  end

  def index
    @frequencies = @organization.frequencies.page(params[:page])
      .per Settings.per_page_range
  end

  private

  def frequency_params
    params.require(:frequency).permit(:value_from, :value_to)
      .merge!(operator: params[:frequency][:operator]&.to_i)
  end

  def load_organization
    @organization = Organization.find_by slug: params[:organization_id]
    return if @organization
    flash.now[:danger] = t ".not_found_org"
  end

  def load_frequency
    return unless @organization
    @frequency = Frequency.find_by id: params[:id]
    return if @frequency
    flash.now[:danger] = t ".not_found_frequency"
  end

  def new_frequency
    @frequency = @organization.frequencies.new frequency_params
  end
end
