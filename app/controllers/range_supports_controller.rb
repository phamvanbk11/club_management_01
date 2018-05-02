class RangeSupportsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_organization
  before_action :load_range_support, only: %i(edit update destroy)
  before_action :new_range_support, only: :create
  authorize_resource

  def index
    @range_supports = @organization.range_supports.newest.page(params[:page]).per Settings.per_page_range
  end

  def new
    gon.operators = RangeSupport.operators
  end

  def create
    if @range_support.save
      flash.now[:success] = t ".create_success"
    elsif @range_support.errors.blank?
      flash.now[:danger] = t ".create_errors"
    end
  end

  def edit
    gon.operators = RangeSupport.operators
  end

  def update
    return unless @range_support
    if @range_support.update_attributes range_support_params
      flash.now[:success] = t ".update_success"
    elsif @range_supports.errors.blank?
      flash.now[:danger] = t ".update_errors"
    end
  end

  def destroy
    return unless @range_support
    if @range_support.destroy
      flash.now[:success] = t ".destroy_success"
    else
      flash.now[:danger] = t ".destroy_errors"
    end
  end

  private

  def range_support_params
    params.require(:range_support).permit(:value_from, :value_to)
      .merge!(style: params[:range_support][:style]&.to_i,
      operator: params[:range_support][:operator]&.to_i)
  end

  def load_organization
    @organization = Organization.find_by slug: params[:organization_id]
    return if @organization
    flash.now[:danger] = t ".not_found_org"
  end

  def load_range_support
    if @organization
      @range_support = RangeSupport.find_by id: params[:id]
      return if @range_support
      flash.now[:danger] = t ".not_found_range_support"
    end
  end

  def new_range_support
    @range_support = @organization.range_supports.new range_support_params
  end
end
