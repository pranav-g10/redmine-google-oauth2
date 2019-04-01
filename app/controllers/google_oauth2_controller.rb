class GoogleOauth2Controller < AccountController
  unloadable

  def login
    auth = request.env['omniauth.auth']
    #render inline: auth.to_json
    authenticate(auth)
  end

  protected

  def authenticate(auth)
    unless auth['provider'] == 'google_oauth2'
      flash[:error] = 'OAuth provider doesn\'t match'
      return redirect_to :controller => :account, :action => :login
    end
    uid = auth['uid']
    info = auth['info']
    credentials = auth['credentials']
    extra = auth['extra']
    unless !!uid && !!info && !!credentials && !!extra
      flash[:error] = 'Login rejected by Oauth2 provider'
      return redirect_to :controller => :account, :action => :login
    end
    id_token = extra['id_token']
    id_info = extra['id_info']
    raw_info = extra['raw_info']
    unless !!id_token && !!id_info && !!raw_info
      flash[:error] = 'Login rejected by Oauth2 provider'
      return redirect_to :controller => :account, :action => :login
    end

    email = info['email']
    profile_url = raw_info['profile'] || email
    unless !!profile_url && !!email && info['email_verified']
      flash[:error] = 'Email is missing or not verified'
      return redirect_to :controller => :account, :action => :login
    end

    user = User.find_or_initialize_by_identity_url(profile_url)
    if user.new_record?
      user.login = email
      user.mail = email
      user.identity_url = profile_url
      user.firstname = id_info['given_name']
      user.lastname = id_info['family_name']
      user.random_password
      user.register
      register_automatically(user) do
        if Setting.self_registration?
          onthefly_creation_failed(user)
        else
          return redirect_to :controller => :account, :action => :login
        end
      end
    else
      if user.active?
        user.login = email
        user.mail = email
        user.save!
        successful_authentication(user)
      else
        account_pending
      end
    end
  end
end
