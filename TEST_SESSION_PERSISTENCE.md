# Testing Session Persistence (PR #66)

## Quick Test in Rails Console

### Step 1: Start Rails Console
```bash
cd /Users/kasutaja/Desktop/projects/kinde_test_app
bin/rails console
```

### Step 2: Test Persistent Session (29 days)
```ruby
require 'jwt'

# Create persistent token
persistent_token = JWT.encode(
  { 'sub' => 'user_123', 'ksp' => { 'persistence' => true } },
  'secret',
  'HS256'
)

# Create token store
store = KindeSdk::TokenStore.new({ access_token: persistent_token })

# Check results
puts "Persistent: #{store.persistent}"  # => true
puts "Expires: #{store.cookie_expiration}"  # => 29 days from now
```

**Expected Output:**
```
Persistent: true
Expires: 2025-11-29 10:41:01 +0500
```

---

### Step 3: Test Non-Persistent Session (Browser Close)
```ruby
# Create non-persistent token
non_persistent_token = JWT.encode(
  { 'sub' => 'user_456', 'ksp' => { 'persistence' => false } },
  'secret',
  'HS256'
)

# Create token store
store = KindeSdk::TokenStore.new({ access_token: non_persistent_token })

# Check results
puts "Persistent: #{store.persistent}"  # => false
puts "Expires: #{store.cookie_expiration}"  # => nil (session cookie!)
```

**Expected Output:**
```
Persistent: false
Expires: nil
```

---

### Step 4: Test Session Configuration
```ruby
# Simulate Rails session
class MockSession
  attr_accessor :options
  def initialize
    @options = {}
  end
end

# Test with persistent = true
session1 = MockSession.new
KindeSdk::TokenManager.send(:apply_session_persistence, true, session1)
puts "Persistent session expire_after: #{session1.options[:expire_after]}"
# => 2505600 (29 days in seconds)

# Test with persistent = false
session2 = MockSession.new
KindeSdk::TokenManager.send(:apply_session_persistence, false, session2)
puts "Session-only expire_after: #{session2.options[:expire_after]}"
# => nil (browser close)
```

**Expected Output:**
```
Persistent session expire_after: 2505600
Session-only expire_after: nil
```

---

## Testing in Browser

### Option A: Check Cookie Expiration in DevTools

1. Login to your app
2. Open Browser DevTools (F12)
3. Go to **Application** → **Cookies**
4. Find `_kinde_test_app_session` cookie
5. Check **Expires / Max-Age:**

**If persistent = true:**
```
Expires: Fri, 29 Nov 2025 05:41:01 GMT  (29 days from now)
```

**If persistent = false:**
```
Expires: Session  (← means browser close!)
```

---

### Option B: Test Browser Behavior

#### Testing Persistent Session:
1. Login to your app
2. Close browser completely
3. Reopen browser
4. Visit http://localhost:3000/profile
5. ✅ **Still logged in** (29 days)

#### Testing Session-Only:
1. Login with persistence = false token
2. Close browser completely
3. Reopen browser
4. Visit http://localhost:3000/profile
5. ❌ **Logged out** (redirected to login)

---

## Configure Kinde to Send persistence = false

### In Kinde Dashboard:

1. Go to https://app.kinde.com
2. Navigate to **Settings** → **Authentication**
3. Look for **Session Settings** or **Session Persistence**
4. Configure "Remember Me" options:
   - **Checked**: persistence = true (29 days)
   - **Unchecked**: persistence = false (browser close)

*Note: Exact location may vary. Check Kinde documentation for your version.*

---

## Testing Both Scenarios Side-by-Side

### Create Two Test Users in Kinde:

**User 1 (Persistent):**
- Login option: "Remember Me" checked
- JWT will have: `{ "ksp": { "persistence": true } }`
- Session lasts 29 days

**User 2 (Session-Only):**
- Login option: "Remember Me" unchecked
- JWT will have: `{ "ksp": { "persistence": false } }`
- Session expires on browser close

---

## Verify in Rails Logs

After login, check your Rails server logs:

**Persistent Session:**
```
Session Persistent: true
Session Options: {:expire_after=>2505600}
```

**Session-Only:**
```
Session Persistent: false
Session Options: {:expire_after=>nil}
```

---

## Quick Verification Checklist

- [ ] `test-ksp` endpoint shows both true/false scenarios
- [ ] Rails console can create both token types
- [ ] Browser DevTools shows correct cookie expiration
- [ ] Persistent session survives browser restart
- [ ] Session-only expires on browser close
- [ ] Flash message shows correct persistence status

---

## Common Issues

### Issue: Always shows persistent = true
**Solution:** Check if Kinde is sending the KSP claim in the JWT token

### Issue: Cookie still expires on browser close
**Solution:** Verify `session.options[:expire_after]` is set to 2505600

### Issue: Can't test browser close behavior
**Solution:** Make sure to close ALL browser windows, not just the tab

---

## Resources

- **PR #66 Review:** See `PR_66_REVIEW_REPORT.md`
- **Kinde Docs:** https://kinde.com/docs
- **Rails Session Docs:** https://guides.rubyonrails.org/security.html#sessions

