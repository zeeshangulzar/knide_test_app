# What is Kinde?

## 🔐 **Overview**

**Kinde is an Authentication & User Management Platform** (like Auth0, Okta, or Firebase Auth)

Think of it as: **"Login-as-a-Service"**

---

## 🎯 **What Problem Does Kinde Solve?**

Instead of building your own:
- ❌ Login/Signup forms
- ❌ Password reset functionality
- ❌ Email verification
- ❌ User database
- ❌ Security (encryption, JWT tokens, etc.)
- ❌ OAuth/Social logins (Google, GitHub, etc.)

**You just integrate Kinde** and get all of that for free! ✅

---

## 🏢 **Real-World Analogy**

### Without Kinde:
```
You → Build entire authentication system from scratch
     → Manage user passwords
     → Handle security vulnerabilities
     → Maintain user database
     → Build "Forgot Password" flow
     → Add 2FA, SSO, etc.
     → Spend weeks/months on auth alone
```

### With Kinde:
```
You → Add 5 lines of code
     → Users can login/signup
     → Kinde handles everything
     → You focus on building your app
     → Go to production in days
```

---

## 🔄 **How It Works**

```
1. User clicks "Login" on your app
   ↓
2. Redirected to Kinde's login page
   (branded to look like YOUR app, not Kinde's)
   ↓
3. User enters email/password
   ↓
4. Kinde validates credentials
   ↓
5. User redirected back to your app
   ↓
6. Your app gets JWT token with user info
   ✅ User is logged in!
```

---

## 🎁 **What Kinde Provides**

| Feature | Description |
|---------|-------------|
| **Authentication** | Login, signup, logout |
| **User Management** | User profiles, organizations, teams |
| **Social Login** | Google, GitHub, Microsoft, Apple, etc. |
| **Security** | 2FA, password policies, encryption |
| **Permissions & Roles** | Role-based access control (RBAC) |
| **Feature Flags** | A/B testing, gradual feature rollouts |
| **Session Control** | Remember me, session expiry control |
| **SSO** | Single Sign-On for enterprises |
| **Custom Domains** | White-label authentication |

---

## 💰 **Pricing**

- **Free tier** for small projects (up to 10,500 monthly active users)
- **Paid plans** for larger businesses
- You pay for users/features, not infrastructure
- No credit card required to start

---

## 🆚 **Kinde vs Competitors**

| Platform | Pros | Cons |
|----------|------|------|
| **Auth0** | Mature, feature-rich | Expensive, complex pricing |
| **Firebase Auth** | Free tier, Google integration | Locked into Google ecosystem |
| **Supabase Auth** | Open source, self-hostable | Requires more setup |
| **Clerk** | Modern UI, good DX | More expensive |
| **Kinde** | Simple, affordable, modern | Newer (less mature) |

---

## 🔧 **What the Kinde Ruby SDK Does**

The `kinde-ruby-sdk` gem is **the bridge** between:
- Your Ruby/Rails app ↔️ Kinde's authentication service

### It handles:
1. ✅ Redirecting users to Kinde login
2. ✅ Receiving authentication tokens
3. ✅ Validating JWT tokens
4. ✅ Managing user sessions
5. ✅ Refreshing expired tokens
6. ✅ Session persistence control (NEW in PR #66!)

---

## 📊 **Code Comparison**

### Before Kinde (Traditional Approach):
```ruby
# You have to build all this yourself:
class UsersController
  def create
    user = User.new(user_params)
    if user.save
      UserMailer.verification_email(user).deliver_now
      # + password hashing
      # + session management
      # + password reset flow
      # + email verification
      # + 2FA implementation
      # + OAuth integrations
      # + security audits
      # ... 1000+ lines of code
    end
  end
end

# Plus models, mailers, views, tests, security audits...
# Estimated time: 2-4 weeks of development
```

### With Kinde:
```ruby
# Just redirect to Kinde:
class AuthController < ApplicationController
  def login
    auth_data = KindeSdk.auth_url
    redirect_to auth_data[:url]
  end
  
  def callback
    tokens = KindeSdk.fetch_tokens(params[:code])
    session[:user] = KindeSdk.client(tokens).oauth.get_user_profile_v2
    redirect_to dashboard_path
  end
end

# That's it! ~10 lines of code
# Estimated time: 30 minutes
```

---

## 🚀 **Quick Start**

### 1. Sign Up for Kinde
```bash
# Visit https://app.kinde.com/register
# Create a free account
```

### 2. Create an Application
```
1. Go to Applications → Create Application
2. Choose "Regular Web Application"
3. Note your credentials:
   - Client ID
   - Client Secret
   - Domain
```

### 3. Install the SDK
```ruby
# Gemfile
gem 'kinde_sdk'
```

```bash
bundle install
```

### 4. Configure
```ruby
# config/initializers/kinde.rb
KindeSdk.configure do |config|
  config.client_id = ENV['KINDE_CLIENT_ID']
  config.client_secret = ENV['KINDE_CLIENT_SECRET']
  config.domain = ENV['KINDE_DOMAIN']
  config.callback_url = 'http://localhost:3000/auth/callback'
  config.logout_url = 'http://localhost:3000'
end
```

### 5. Add Routes
```ruby
# config/routes.rb
get '/login', to: 'auth#login'
get '/auth/callback', to: 'auth#callback'
get '/logout', to: 'auth#logout'
```

### 6. Create Controller
```ruby
# app/controllers/auth_controller.rb
class AuthController < ApplicationController
  def login
    redirect_to KindeSdk.auth_url[:url], allow_other_host: true
  end
  
  def callback
    tokens = KindeSdk.fetch_tokens(params[:code])
    session[:tokens] = tokens
    redirect_to root_path
  end
  
  def logout
    session.clear
    redirect_to KindeSdk.logout_url, allow_other_host: true
  end
end
```

### 7. Done! 🎉
```
Visit http://localhost:3000/login
You'll be redirected to Kinde
Login/signup
Redirected back to your app
✅ User is authenticated!
```

---

## 🔒 **Security Features**

Kinde handles security so you don't have to:

- ✅ **Password Hashing** - bcrypt with proper salting
- ✅ **JWT Tokens** - Secure, signed tokens
- ✅ **PKCE** - Protection against authorization code interception
- ✅ **Rate Limiting** - Prevents brute force attacks
- ✅ **Breach Detection** - Checks against known compromised passwords
- ✅ **Compliance** - GDPR, SOC 2, HIPAA ready

---

## 📈 **Use Cases**

### Perfect For:
- ✅ SaaS applications
- ✅ B2B products
- ✅ Multi-tenant apps
- ✅ Mobile + Web apps
- ✅ Startups (quick launch)
- ✅ Enterprises (scalable, secure)

### Examples:
- **E-commerce:** Customer accounts, order history
- **Project Management:** Team collaboration, permissions
- **Healthcare:** HIPAA-compliant patient portals
- **Education:** Student/teacher management
- **Internal Tools:** Employee dashboards, admin panels

---

## 🎯 **Bottom Line**

**Kinde = Outsourced Authentication**

Instead of:
- ❌ Spending weeks building login systems
- ❌ Hiring security experts
- ❌ Maintaining user databases
- ❌ Dealing with password breaches
- ❌ Implementing OAuth providers
- ❌ Building 2FA from scratch

You:
- ✅ Add Kinde SDK (5 minutes)
- ✅ Get enterprise-grade auth
- ✅ Focus on your actual product
- ✅ Launch faster
- ✅ Sleep better (security handled)

---

## 💡 **Analogy**

**Kinde is to Authentication what Stripe is to Payments**

- You don't build your own credit card processing → You use Stripe
- You don't build your own authentication → You use Kinde

Both save you months of development and years of maintenance!

---

## 🔗 **Resources**

- **Website:** https://kinde.com
- **Documentation:** https://kinde.com/docs
- **Dashboard:** https://app.kinde.com
- **Ruby SDK Docs:** https://kinde.com/docs/developer-tools/ruby-sdk
- **Community:** https://thekindecommunity.slack.com

---

## 🆕 **What's New in PR #66?**

The PR you're reviewing adds **Session Persistence Control**:

- 🟢 **Persistent Sessions** - Users stay logged in for 29 days ("Remember Me")
- 🔴 **Session-Only** - Users log out when browser closes (high security)

The system reads the `ksp.persistence` claim from JWT tokens and automatically configures session expiration. This gives you fine-grained control over user session duration!

---

**Questions?** Check out the [Kinde Documentation](https://kinde.com/docs) or join the [Community Slack](https://thekindecommunity.slack.com)

