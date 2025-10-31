# Kinde SDK Configuration
# Replace these with your actual Kinde credentials from https://app.kinde.com

KindeSdk.configure do |config|
  config.client_id = ENV['KINDE_CLIENT_ID'] || 'your_client_id_here'
  config.client_secret = ENV['KINDE_CLIENT_SECRET'] || 'your_client_secret_here'
  config.domain = ENV['KINDE_DOMAIN'] || 'https://xcorebit.kinde.com'
  config.callback_url = 'http://localhost:3000/auth/callback'
  config.logout_url = 'http://localhost:3000'
  config.scope = 'openid profile email offline'
  config.pkce_enabled = true
  config.auto_refresh_tokens = true
end

