class MoneySupportsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_organization
  before_action :load_money_support
  before_action :replace_string_in_params

  def create
    if @money_support
      if @money_support.update_attribute :money, params[:money]
        flash.now[:success] = t ".success"
      else
        flash.now[:danger] = t ".danger"
      end
    else
      @money_support = @organization.money_supports.new(money_support_params)
      if @money_support.save
        flash.now[:success] = t ".success"
      else
        flash.now[:danger] = t ".danger"
      end
    end
  end

  private

  def money_support_params
    params.permit(:money).merge! arr_range:
      params[:arr_range].map(&:to_i)
  end

  def load_money_support
    @money_support = @organization.money_supports.find_by id: params[:id]
  end

  def load_organization
    @organization = Organization.find_by slug: params[:organization_id]
    return if @organization
    flash.now[:danger] = t ".not_found_org"
  end

  def replace_string_in_params
    params[:money] = params[:money].delete(",").to_i
  end
end
