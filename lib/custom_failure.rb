class CustomFailure < Devise::FailureApp
  def redirect_url
    if warden_options[:scope] == :admin
      new_admin_session_url
    else
      root_path
    end
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
