# Romantic App - Backend Architecture

## 🏗️ **Recommended Stack: Supabase + Node.js**

### **Core Technologies:**
- **Database**: PostgreSQL (Supabase)
- **Authentication**: Supabase Auth + Twilio
- **Backend API**: Node.js + Express
- **Real-time**: Supabase Realtime
- **File Storage**: Supabase Storage
- **Push Notifications**: Firebase Cloud Messaging
- **Video Calls**: Agora.io
- **Deployment**: Railway/Render

---

## 📊 **Database Schema**

### **Users Table**
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone_number VARCHAR(15) UNIQUE NOT NULL,
  country_code VARCHAR(5) NOT NULL,
  full_name VARCHAR(100),
  bio TEXT,
  age INTEGER,
  gender VARCHAR(10),
  location VARCHAR(100),
  profile_image_url TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  is_online BOOLEAN DEFAULT FALSE,
  last_seen TIMESTAMP,
  coins INTEGER DEFAULT 0,
  premium_subscription BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### **OTP Verification Table**
```sql
CREATE TABLE otp_verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone_number VARCHAR(15) NOT NULL,
  otp_code VARCHAR(6) NOT NULL,
  is_used BOOLEAN DEFAULT FALSE,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### **User Profiles Table**
```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  profile_image_url TEXT,
  bio TEXT,
  interests TEXT[],
  photos TEXT[],
  is_public BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### **Matches Table**
```sql
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user1_id UUID REFERENCES users(id) ON DELETE CASCADE,
  user2_id UUID REFERENCES users(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'pending', -- pending, accepted, rejected
  matched_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user1_id, user2_id)
);
```

### **Messages Table**
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT,
  message_type VARCHAR(20) DEFAULT 'text', -- text, image, voice, video
  media_url TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### **Video Calls Table**
```sql
CREATE TABLE video_calls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  caller_id UUID REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID REFERENCES users(id) ON DELETE CASCADE,
  room_name VARCHAR(100),
  status VARCHAR(20) DEFAULT 'initiated', -- initiated, ongoing, completed, missed
  started_at TIMESTAMP,
  ended_at TIMESTAMP,
  duration INTEGER, -- in seconds
  created_at TIMESTAMP DEFAULT NOW()
);
```

### **Coins Transactions Table**
```sql
CREATE TABLE coin_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  amount INTEGER NOT NULL,
  transaction_type VARCHAR(20), -- earned, spent, purchased
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🔐 **Authentication Flow**

### **1. Phone Number Registration**
```javascript
// 1. User enters phone number
// 2. Generate OTP and send via Twilio
// 3. Store OTP in database with expiration
// 4. User enters OTP
// 5. Verify OTP and create user account
```

### **2. OTP Verification Process**
```javascript
// API Endpoints:
POST /api/auth/send-otp
POST /api/auth/verify-otp
POST /api/auth/register
POST /api/auth/login
```

---

## 🚀 **API Endpoints Structure**

### **Authentication**
- `POST /api/auth/send-otp` - Send OTP to phone number
- `POST /api/auth/verify-otp` - Verify OTP code
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user
- `GET /api/auth/profile` - Get user profile

### **User Management**
- `GET /api/users/discover` - Get discover profiles
- `POST /api/users/like` - Like a profile
- `POST /api/users/pass` - Pass on a profile
- `GET /api/users/matches` - Get user matches
- `PUT /api/users/profile` - Update user profile
- `POST /api/users/upload-photo` - Upload profile photo

### **Messaging**
- `GET /api/messages/conversations` - Get conversations
- `GET /api/messages/:conversationId` - Get messages
- `POST /api/messages/send` - Send message
- `PUT /api/messages/:messageId/read` - Mark as read

### **Video Calls**
- `POST /api/calls/initiate` - Start video call
- `POST /api/calls/accept` - Accept call
- `POST /api/calls/reject` - Reject call
- `POST /api/calls/end` - End call
- `GET /api/calls/history` - Get call history

### **Coins & Premium**
- `GET /api/coins/balance` - Get coin balance
- `POST /api/coins/earn` - Earn coins (watch ad)
- `POST /api/coins/spend` - Spend coins
- `POST /api/premium/subscribe` - Subscribe to premium

---

## 🔧 **Implementation Steps**

### **Phase 1: Basic Authentication**
1. Set up Supabase project
2. Configure Twilio for SMS
3. Implement OTP generation and verification
4. Create user registration/login flow

### **Phase 2: Core Features**
1. User profile management
2. Discover and matching system
3. Basic messaging
4. Coin system integration

### **Phase 3: Advanced Features**
1. Real-time messaging
2. Video calling with Agora
3. Push notifications
4. Premium features

### **Phase 4: Optimization**
1. Performance optimization
2. Analytics and monitoring
3. Advanced matching algorithms
4. Security enhancements

---

## 💰 **Cost Estimation**

### **Supabase (Monthly)**
- **Free Tier**: $0 (50,000 MAU, 500MB database)
- **Pro Plan**: $25 (100,000 MAU, 8GB database)
- **Team Plan**: $599 (Unlimited MAU, 100GB database)

### **Twilio (Pay per use)**
- **SMS**: $0.0079 per message
- **Voice**: $0.0085 per minute

### **Agora.io (Pay per use)**
- **Video**: $0.004 per minute per user
- **Audio**: $0.0007 per minute per user

### **Deployment (Railway/Render)**
- **Free Tier**: $0 (limited usage)
- **Paid Plans**: $5-20/month

---

## 🔒 **Security Considerations**

1. **Phone Number Verification**: Always verify phone numbers
2. **Rate Limiting**: Prevent OTP abuse
3. **Data Encryption**: Encrypt sensitive data
4. **Input Validation**: Validate all user inputs
5. **JWT Tokens**: Secure authentication tokens
6. **HTTPS**: Always use secure connections

---

## 📱 **Flutter Integration**

### **Required Packages**
```yaml
dependencies:
  supabase_flutter: ^2.0.0
  http: ^1.1.0
  dio: ^5.3.0
  agora_rtc_engine: ^6.2.0
  firebase_messaging: ^14.7.0
  shared_preferences: ^2.2.0
  image_picker: ^1.0.0
  cached_network_image: ^3.3.0
```

### **Service Layer Structure**
```
lib/
├── services/
│   ├── auth_service.dart
│   ├── api_service.dart
│   ├── storage_service.dart
│   ├── messaging_service.dart
│   ├── video_call_service.dart
│   └── notification_service.dart
├── models/
│   ├── user.dart
│   ├── message.dart
│   ├── match.dart
│   └── video_call.dart
└── providers/
    ├── auth_provider.dart
    ├── user_provider.dart
    └── chat_provider.dart
```

---

## 🚀 **Deployment Strategy**

### **Development**
- Local development with hot reload
- Supabase local development
- Test with real devices

### **Staging**
- Deploy to staging environment
- Test all features thoroughly
- Performance testing

### **Production**
- Deploy to production
- Monitor performance
- Set up analytics
- Implement backup strategies

---

## 📈 **Future Enhancements**

### **Short Term (1-3 months)**
- Push notifications
- Profile verification
- Advanced matching algorithms
- In-app purchases

### **Medium Term (3-6 months)**
- Video calling
- Voice messages
- Location-based matching
- Social media integration

### **Long Term (6+ months)**
- AI-powered matching
- Virtual gifts
- Events and meetups
- Premium subscriptions
- Multi-language support

---

## 🎯 **Success Metrics**

### **User Engagement**
- Daily/Monthly Active Users
- Time spent in app
- Message response rate
- Video call completion rate

### **Business Metrics**
- User acquisition cost
- Revenue per user
- Premium conversion rate
- User retention rate

### **Technical Metrics**
- App performance
- API response times
- Error rates
- Uptime percentage
