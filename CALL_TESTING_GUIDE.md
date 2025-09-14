# 📞 Video Call Testing Guide

## 🎯 Overview
This guide will help you test the video call feature on both mobile and web platforms.

## 🔧 Prerequisites

### 1. Backend Server Running
Make sure your backend server is running:
```bash
cd Backend
npm start
```

### 2. Database Tables Created
Ensure you've run the chat database setup:
- Execute `database/chat_tables.sql` in Supabase

### 3. IP Address Configuration
The call service is now configured to use:
- **Web**: `http://localhost:5000`
- **Mobile**: `http://192.168.1.5:5000` (your actual IP)

## 🚀 Testing Steps

### Step 1: Test Call Service Initialization

**Check if CallService is properly initialized:**
1. Open the app
2. Navigate to a chat conversation
3. Check the console logs for:
   ```
   ✅ Call socket initialization completed
   🌐 Connected to: http://192.168.1.5:5000
   ```

### Step 2: Test Audio Call

1. **Open a chat conversation**
2. **Tap the phone icon** (📞) in the chat header
3. **Expected behavior:**
   - Call screen opens
   - Shows "Waiting for answer..." status
   - Other user receives incoming call notification

### Step 3: Test Video Call

1. **Open a chat conversation**
2. **Tap the video camera icon** (📹) in the chat header
3. **Expected behavior:**
   - Video call screen opens
   - Camera and microphone permissions requested
   - Shows local video preview
   - Shows "Waiting for answer..." status

### Step 4: Test Call Acceptance

**On the receiving device:**
1. **Accept the incoming call**
2. **Expected behavior:**
   - Call screen opens
   - WebRTC connection established
   - Video streams exchanged
   - Call timer starts

### Step 5: Test Call Features

**During an active call:**
- **Mute/Unmute**: Tap microphone icon
- **Video On/Off**: Tap camera icon
- **Speaker**: Tap speaker icon
- **End Call**: Tap red phone icon
- **Debug Info**: Tap bug icon (for troubleshooting)

## 🔍 Troubleshooting

### Call Service Issues

**Problem:** "Socket not initialized" error
**Solution:**
- Check if backend server is running
- Verify IP address configuration
- Check authentication token

**Problem:** "Connection refused" error
**Solution:**
- Verify backend server is running on port 5000
- Check IP address in call service configuration
- Ensure both devices are on same network

### WebRTC Issues

**Problem:** "Failed to access camera/microphone"
**Solution:**
- Grant camera and microphone permissions
- Check browser permissions (for web)
- Restart the app

**Problem:** "Peer connection failed"
**Solution:**
- Check network connectivity
- Verify STUN servers are accessible
- Check firewall settings

**Problem:** No video/audio
**Solution:**
- Check camera/microphone permissions
- Verify WebRTC is supported
- Check network quality

### Mobile-Specific Issues

**Problem:** Call doesn't work on mobile
**Solution:**
- Update IP address in `call_service.dart`
- Check mobile network connectivity
- Verify backend is accessible from mobile

**Problem:** Permissions denied
**Solution:**
- Go to device settings
- Grant camera and microphone permissions
- Restart the app

## 📱 Mobile Testing Setup

### Android Testing
1. **Enable permissions in AndroidManifest.xml:**
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.INTERNET" />
   ```

2. **Test on device:**
   ```bash
   flutter run
   ```

### iOS Testing
1. **Enable permissions in Info.plist:**
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>This app needs camera access for video calls</string>
   <key>NSMicrophoneUsageDescription</key>
   <string>This app needs microphone access for calls</string>
   ```

2. **Test on device:**
   ```bash
   flutter run
   ```

## 🌐 Web Testing Setup

### Chrome Testing
1. **Enable WebRTC in Chrome:**
   - Go to `chrome://flags/`
   - Enable "WebRTC" features
   - Restart Chrome

2. **Test permissions:**
   - Allow camera and microphone when prompted
   - Check browser console for errors

### Cross-Platform Testing
- **Mobile to Web**: Test calls between mobile app and web browser
- **Web to Mobile**: Test calls from web browser to mobile app
- **Mobile to Mobile**: Test calls between two mobile devices

## 🧪 Testing Checklist

### Backend Testing
- [ ] Backend server running on port 5000
- [ ] Socket.io accepting connections
- [ ] Video call routes working
- [ ] WebRTC signaling working

### Frontend Testing
- [ ] Call service initializes properly
- [ ] Audio call button works
- [ ] Video call button works
- [ ] Call screen opens
- [ ] Permissions requested
- [ ] WebRTC connection established
- [ ] Video streams working
- [ ] Audio streams working
- [ ] Call controls working
- [ ] Call end works

### Cross-Platform Testing
- [ ] Mobile can call web
- [ ] Web can call mobile
- [ ] Mobile can call mobile
- [ ] Video quality acceptable
- [ ] Audio quality acceptable
- [ ] Call duration tracking works

## 🚨 Common Issues & Solutions

### 1. "Socket not initialized"
- **Cause**: CallService not initialized
- **Fix**: Call `CallService.initializeWithAuth()` before making calls

### 2. "Connection refused"
- **Cause**: Wrong IP address or backend not running
- **Fix**: Update IP address and ensure backend is running

### 3. "Failed to access camera/microphone"
- **Cause**: Permissions not granted
- **Fix**: Grant permissions in device settings

### 4. "Peer connection failed"
- **Cause**: Network or WebRTC issues
- **Fix**: Check network connectivity and WebRTC support

### 5. "No video/audio"
- **Cause**: WebRTC connection not established
- **Fix**: Check STUN servers and network quality

## 📞 Call Flow

1. **User A** taps call button
2. **CallService** sends "outgoing-call" event
3. **Backend** stores call data and notifies **User B**
4. **User B** receives "incoming-call" event
5. **User B** accepts call
6. **WebRTC** offer/answer exchange
7. **ICE candidates** exchanged
8. **Media streams** established
9. **Call active** with video/audio

## 🔧 Configuration Files

### Updated Files:
- ✅ `Frontend/lib/features/calls/services/call_service.dart` - IP detection
- ✅ `Frontend/lib/features/messaging/screens/chat_screen.dart` - Call buttons
- ✅ `Backend/routes/vcall.js` - Video call routes
- ✅ `Backend/server.js` - Socket.io configuration

## 📞 Support

If you encounter issues:

1. **Check the logs:**
   - Backend: Console output
   - Frontend: Flutter logs or browser console

2. **Test connectivity:**
   - Backend: `curl http://localhost:5000/health`
   - Mobile: `http://192.168.1.5:5000/health`

3. **Verify configuration:**
   - IP addresses in call service
   - Permissions granted
   - Network connectivity

The video call feature should now work seamlessly on both mobile and web! 🎉
