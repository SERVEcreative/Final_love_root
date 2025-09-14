# Supabase Realtime Setup Guide

## 🚨 **Current Issue**
Your Supabase Realtime connection is failing with the error:
```
❌ Supabase Realtime connection failed:
RealtimeSubscribeStatus.subscribed - null
```

## 🔧 **Solution: Enable Supabase Realtime**

### Step 1: Enable Realtime in Supabase Dashboard

1. **Go to your Supabase Dashboard**
   - Visit: https://supabase.com/dashboard
   - Select your project: `kgijlarzjdpardjbefoq`

2. **Navigate to Database Settings**
   - Go to **Settings** → **Database**
   - Scroll down to **Replication** section

3. **Enable Realtime**
   - Find **Realtime** toggle
   - **Turn it ON**
   - This enables real-time subscriptions for your database

### Step 2: Configure Realtime Policies (Optional)

1. **Go to Authentication → Policies**
2. **Create Realtime Policies** (if needed):
   ```sql
   -- Allow users to subscribe to their own call channels
   CREATE POLICY "Users can subscribe to their own calls" ON calls
   FOR SELECT USING (auth.uid()::text = caller_id::text OR auth.uid()::text = receiver_id::text);
   ```

### Step 3: Verify Realtime is Working

1. **Check Realtime Status**
   - In Supabase Dashboard → **Settings** → **API**
   - Look for **Realtime** section
   - Should show "Enabled" status

2. **Test Connection**
   - Run your Flutter app
   - Check console logs for:
   ```
   ✅ Supabase Realtime connection verified
   📞 Real-time channel subscribed successfully
   ```

## 🔍 **Alternative Solutions**

### If Realtime Still Doesn't Work:

1. **Check Network/Firewall**
   - Ensure your network allows WebSocket connections
   - Some corporate networks block WebSocket traffic

2. **Use Database Polling (Fallback)**
   - The app will automatically fall back to database polling
   - Calls will still work, but with slight delays

3. **Check Supabase Status**
   - Visit: https://status.supabase.com/
   - Ensure Supabase services are operational

## 📱 **Testing the Fix**

After enabling Realtime:

1. **Start your Flutter app**
2. **Check console logs** for successful connection
3. **Make a test call** between two devices
4. **Verify real-time signaling** is working

## 🚀 **Expected Logs After Fix**

```
✅ Supabase initialized successfully
✅ Supabase Call Service initialized successfully
📞 Test channel status: SUBSCRIBED, error: null
✅ Supabase Realtime connection verified
📞 Setting up realtime listener for user: [user_id]
📞 Channel subscription status: SUBSCRIBED
📞 Real-time channel subscribed successfully
```

## 💡 **Important Notes**

- **Realtime is required** for instant call notifications
- **Without Realtime**, calls will use fallback mechanisms
- **Database polling** will work but with delays
- **WebRTC signaling** will still function for video calls

## 🆘 **Still Having Issues?**

If Realtime still doesn't work:

1. **Check Supabase Project Settings**
2. **Verify API keys are correct**
3. **Check network connectivity**
4. **Contact Supabase Support** if needed

The call system will continue to work with fallback mechanisms, but enabling Realtime provides the best user experience.
