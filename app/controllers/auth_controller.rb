class AuthController < ApplicationController
  # Skip CSRF protection for Kinde callback
  skip_before_action :verify_authenticity_token, only: [:callback]

  def login
    # Generate auth URL
    auth_data = KindeSdk.auth_url

    # Store code verifier for PKCE
    session[:code_verifier] = auth_data[:code_verifier] if auth_data[:code_verifier]

    # Redirect to Kinde login
    redirect_to auth_data[:url], allow_other_host: true
  end

  def callback
    begin
      # Exchange code for tokens
      tokens = KindeSdk.fetch_tokens(
        params[:code],
        code_verifier: session[:code_verifier]
      )

      # DEBUG: Decode JWT to see what Kinde sent
      require "jwt"
      payload = JWT.decode(tokens[:access_token], nil, false).first rescue {}
      Rails.logger.info "🔍 JWT Claims from Kinde: #{payload.inspect}"
      Rails.logger.info "🔍 KSP Claim: #{payload['ksp'].inspect}"

      # Create token store (handles KSP persistence automatically)
      token_store = KindeSdk::TokenManager.create_store(tokens)

      # IMPORTANT: Apply session persistence BEFORE storing data
      session.options[:expire_after] = token_store.persistent ? 2505600 : nil

      # Store only essential token data (optimized for cookie size)
      session[:kinde_token_store] = token_store.to_session

      # Create Kinde client
      client = KindeSdk.client(tokens)

      # Get user info and store ONLY essential data
      user = client.oauth.get_user_profile_v2
      session[:user_id] = user.id
      session[:user_email] = user.email

      # Check session persistence (NEW FEATURE from PR #66!)
      @session_persistent = token_store.persistent

      # Show detailed message
      ksp_status = payload["ksp"] ? "KSP claim present: #{payload['ksp']}" : "No KSP claim (defaulting to persistent)"
      flash[:success] = "✅ Logged in! Session: #{@session_persistent ? '29 days' : 'browser close'} | #{ksp_status}"
      redirect_to profile_path
    rescue => e
      flash[:error] = "Authentication failed: #{e.message}"
      redirect_to root_path
    end
  end

  def profile
    if session[:user_id]
      @user = {
        id: session[:user_id],
        email: session[:user_email]
      }
      @persistent = KindeSdk.session_persistent?
    else
      flash[:error] = "Please log in first"
      redirect_to root_path
    end
  end

  def logout
    session.clear
    redirect_to KindeSdk.logout_url, allow_other_host: true
  end

  def test_ksp
    # Test KSP feature (Session Persistence from PR #66)
    require "jwt"

    # Test with persistent token
    persistent_token = JWT.encode(
      { "sub" => "test_user", "ksp" => { "persistence" => true } },
      "secret",
      "HS256"
    )

    # Test with non-persistent token
    non_persistent_token = JWT.encode(
      { "sub" => "test_user", "ksp" => { "persistence" => false } },
      "secret",
      "HS256"
    )

    @results = {
      persistent: KindeSdk::TokenStore.new({ access_token: persistent_token }).persistent,
      non_persistent: KindeSdk::TokenStore.new({ access_token: non_persistent_token }).persistent,
      persistent_expiry: KindeSdk::TokenStore.new({ access_token: persistent_token }).cookie_expiration,
      non_persistent_expiry: KindeSdk::TokenStore.new({ access_token: non_persistent_token }).cookie_expiration
    }

    render json: @results
  end

  # Simulate login with non-persistent session for testing
  def test_session_only
    require "jwt"

    # Create a non-persistent test token
    test_token = JWT.encode(
      {
        "sub" => "test_user_session_only",
        "email" => "test@example.com",
        "ksp" => { "persistence" => false }  # ← Session-only!
      },
      "secret",
      "HS256"
    )

    tokens = {
      access_token: test_token,
      refresh_token: "test_refresh",
      expires_at: nil
    }

    # Create token store (will detect persistence = false)
    token_store = KindeSdk::TokenManager.create_store(tokens)
    # IMPORTANT: Apply session persistence BEFORE storing data
    session.options[:expire_after] = token_store.tokens[:expires_at]  # nil = session cookie (browser close)

    session[:kinde_token_store] = token_store.to_session
    session[:user_id] = "test_user_session_only"
    session[:user_email] = "test@example.com"

    flash[:success] = "🔴 Test Login: Session-Only Mode (closes on browser exit)"
    redirect_to profile_path
  end

  # Simulate login with persistent session for testing
  def test_persistent
    require "jwt"

    # Create a persistent test token
    test_token = JWT.encode(
      {
        "sub" => "test_user_persistent",
        "email" => "persistent@example.com",
        "ksp" => { "persistence" => true }  # ← Persistent!
      },
      "secret",
      "HS256"
    )

    tokens = {
      access_token: test_token,
      refresh_token: "test_refresh",
      expires_at: Time.now.to_i + 3600
    }

    # Create token store (will detect persistence = true)
    token_store = KindeSdk::TokenManager.create_store(tokens)
    # IMPORTANT: Apply session persistence BEFORE storing data
    session.options[:expire_after] = token_store.tokens[:expires_at]  # 29 days in seconds

    session[:kinde_token_store] = token_store.to_session
    session[:user_id] = "test_user_persistent"
    session[:user_email] = "persistent@example.com"

    flash[:success] = "🟢 Test Login: Persistent Mode (29 days)"
    redirect_to profile_path
  end
end

