class SetLanguageController < ApplicationController
  def update
    language = params[:id]
    case language
    when Settings.languages.en
      I18n.locale = :en
    when Settings.languages.vi
      I18n.locale = :vi
    when Settings.languages.jp
      I18n.locale = :jp
    end
    set_session_and_redirect
  end

  private
  def set_session_and_redirect
    session[:locale] = I18n.locale
    redirect_back fallback_location: root_path
  rescue ActionController::RedirectBackError
    redirect_to :root
  end
end
