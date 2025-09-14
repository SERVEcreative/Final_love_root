-- Call System Setup for Existing Users Table
-- This file creates the call system tables that work with your existing users table

-- =====================================================
-- CALL SYSTEM TABLES
-- =====================================================

-- 1. Calls table for call signaling and management
CREATE TABLE IF NOT EXISTS calls (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    caller_id UUID REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES users(id) ON DELETE CASCADE,
    caller_name VARCHAR(100), -- For quick display without joins
    receiver_name VARCHAR(100), -- For quick display without joins
    status VARCHAR(20) DEFAULT 'ringing' CHECK (status IN ('ringing', 'accepted', 'rejected', 'ended', 'missed')),
    call_type VARCHAR(20) DEFAULT 'video' CHECK (call_type IN ('video', 'audio')),
    duration_seconds INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    accepted_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    call_quality_score INTEGER CHECK (call_quality_score >= 1 AND call_quality_score <= 5)
);

-- 2. Call signaling table for WebRTC signaling data
CREATE TABLE IF NOT EXISTS call_signaling (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    call_id UUID REFERENCES calls(id) ON DELETE CASCADE,
    from_user UUID REFERENCES users(id) ON DELETE CASCADE,
    to_user UUID REFERENCES users(id) ON DELETE CASCADE,
    signal_type VARCHAR(20) NOT NULL CHECK (signal_type IN ('offer', 'answer', 'ice_candidate', 'call_end')),
    signal_data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE
);

-- 3. Call participants table (for group calls in future)
CREATE TABLE IF NOT EXISTS call_participants (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    call_id UUID REFERENCES calls(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    left_at TIMESTAMP WITH TIME ZONE,
    participant_status VARCHAR(20) DEFAULT 'active' CHECK (participant_status IN ('active', 'muted', 'left', 'kicked')),
    is_host BOOLEAN DEFAULT FALSE
);

-- 4. Call history table (for analytics and user history)
CREATE TABLE IF NOT EXISTS call_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    call_id UUID REFERENCES calls(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    other_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    call_direction VARCHAR(10) CHECK (call_direction IN ('incoming', 'outgoing')),
    call_outcome VARCHAR(20) CHECK (call_outcome IN ('answered', 'missed', 'rejected', 'failed')),
    duration_seconds INTEGER DEFAULT 0,
    call_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    call_quality_rating INTEGER CHECK (call_quality_rating >= 1 AND call_quality_rating <= 5),
    notes TEXT
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Calls table indexes
CREATE INDEX IF NOT EXISTS idx_calls_caller_id ON calls(caller_id);
CREATE INDEX IF NOT EXISTS idx_calls_receiver_id ON calls(receiver_id);
CREATE INDEX IF NOT EXISTS idx_calls_status ON calls(status);
CREATE INDEX IF NOT EXISTS idx_calls_created_at ON calls(created_at);
CREATE INDEX IF NOT EXISTS idx_calls_call_type ON calls(call_type);

-- Call signaling indexes
CREATE INDEX IF NOT EXISTS idx_call_signaling_call_id ON call_signaling(call_id);
CREATE INDEX IF NOT EXISTS idx_call_signaling_from_user ON call_signaling(from_user);
CREATE INDEX IF NOT EXISTS idx_call_signaling_to_user ON call_signaling(to_user);
CREATE INDEX IF NOT EXISTS idx_call_signaling_type ON call_signaling(signal_type);
CREATE INDEX IF NOT EXISTS idx_call_signaling_created_at ON call_signaling(created_at);

-- Call participants indexes
CREATE INDEX IF NOT EXISTS idx_call_participants_call_id ON call_participants(call_id);
CREATE INDEX IF NOT EXISTS idx_call_participants_user_id ON call_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_call_participants_status ON call_participants(participant_status);

-- Call history indexes
CREATE INDEX IF NOT EXISTS idx_call_history_user_id ON call_history(user_id);
CREATE INDEX IF NOT EXISTS idx_call_history_other_user_id ON call_history(other_user_id);
CREATE INDEX IF NOT EXISTS idx_call_history_call_date ON call_history(call_date);
CREATE INDEX IF NOT EXISTS idx_call_history_outcome ON call_history(call_outcome);

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to update call duration when call ends
CREATE OR REPLACE FUNCTION update_call_duration()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'ended' AND OLD.status != 'ended' THEN
        NEW.ended_at = NOW();
        IF NEW.accepted_at IS NOT NULL THEN
            NEW.duration_seconds = EXTRACT(EPOCH FROM (NOW() - NEW.accepted_at))::INTEGER;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Function to create call history entry
CREATE OR REPLACE FUNCTION create_call_history_entry()
RETURNS TRIGGER AS $$
BEGIN
    -- Only create history for ended calls
    IF NEW.status = 'ended' OR NEW.status = 'missed' OR NEW.status = 'rejected' THEN
        -- Insert history for caller
        INSERT INTO call_history (
            call_id, user_id, other_user_id, call_direction, call_outcome, 
            duration_seconds, call_date, call_quality_rating
        ) VALUES (
            NEW.id, NEW.caller_id, NEW.receiver_id, 'outgoing',
            CASE 
                WHEN NEW.status = 'ended' THEN 'answered'
                WHEN NEW.status = 'rejected' THEN 'rejected'
                WHEN NEW.status = 'missed' THEN 'missed'
                ELSE 'failed'
            END,
            NEW.duration_seconds, NEW.created_at, NEW.call_quality_score
        );
        
        -- Insert history for receiver
        INSERT INTO call_history (
            call_id, user_id, other_user_id, call_direction, call_outcome, 
            duration_seconds, call_date, call_quality_rating
        ) VALUES (
            NEW.id, NEW.receiver_id, NEW.caller_id, 'incoming',
            CASE 
                WHEN NEW.status = 'ended' THEN 'answered'
                WHEN NEW.status = 'rejected' THEN 'rejected'
                WHEN NEW.status = 'missed' THEN 'missed'
                ELSE 'failed'
            END,
            NEW.duration_seconds, NEW.created_at, NEW.call_quality_score
        );
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Function to clean up old signaling data
CREATE OR REPLACE FUNCTION cleanup_old_signaling_data()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete signaling data older than 1 hour for ended calls
    DELETE FROM call_signaling 
    WHERE call_id = NEW.id 
    AND NEW.status IN ('ended', 'rejected', 'missed')
    AND created_at < NOW() - INTERVAL '1 hour';
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers
CREATE TRIGGER update_call_duration_trigger
    BEFORE UPDATE ON calls
    FOR EACH ROW EXECUTE FUNCTION update_call_duration();

CREATE TRIGGER create_call_history_trigger
    AFTER UPDATE ON calls
    FOR EACH ROW EXECUTE FUNCTION create_call_history_entry();

CREATE TRIGGER cleanup_signaling_data_trigger
    AFTER UPDATE ON calls
    FOR EACH ROW EXECUTE FUNCTION cleanup_old_signaling_data();

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS on all call tables
ALTER TABLE calls ENABLE ROW LEVEL SECURITY;
ALTER TABLE call_signaling ENABLE ROW LEVEL SECURITY;
ALTER TABLE call_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE call_history ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS POLICIES
-- =====================================================

-- Calls table policies
CREATE POLICY "Users can view their own calls" ON calls
    FOR SELECT USING (
        caller_id = auth.uid() OR 
        receiver_id = auth.uid()
    );

CREATE POLICY "Users can create calls" ON calls
    FOR INSERT WITH CHECK (
        caller_id = auth.uid()
    );

CREATE POLICY "Users can update their own calls" ON calls
    FOR UPDATE USING (
        caller_id = auth.uid() OR 
        receiver_id = auth.uid()
    );

-- Call signaling policies
CREATE POLICY "Users can view signaling for their calls" ON call_signaling
    FOR SELECT USING (
        from_user = auth.uid() OR 
        to_user = auth.uid()
    );

CREATE POLICY "Users can create signaling messages" ON call_signaling
    FOR INSERT WITH CHECK (
        from_user = auth.uid()
    );

-- Call participants policies
CREATE POLICY "Users can view participants in their calls" ON call_participants
    FOR SELECT USING (
        user_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM calls 
            WHERE calls.id = call_participants.call_id 
            AND (calls.caller_id = auth.uid() OR calls.receiver_id = auth.uid())
        )
    );

CREATE POLICY "Users can join their own calls" ON call_participants
    FOR INSERT WITH CHECK (
        user_id = auth.uid()
    );

CREATE POLICY "Users can update their own participation" ON call_participants
    FOR UPDATE USING (
        user_id = auth.uid()
    );

-- Call history policies
CREATE POLICY "Users can view their own call history" ON call_history
    FOR SELECT USING (
        user_id = auth.uid()
    );

CREATE POLICY "System can insert call history" ON call_history
    FOR INSERT WITH CHECK (true);

-- =====================================================
-- SAMPLE DATA (Optional - for testing)
-- =====================================================

-- Uncomment these lines to insert sample data for testing
/*
-- Insert sample call (replace with actual user IDs from your users table)
INSERT INTO calls (caller_id, receiver_id, caller_name, receiver_name, status, call_type)
VALUES (
    (SELECT id FROM users LIMIT 1 OFFSET 0), -- First user
    (SELECT id FROM users LIMIT 1 OFFSET 1), -- Second user
    'Test Caller',
    'Test Receiver',
    'ended',
    'video'
);
*/

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Uncomment to verify the setup
/*
-- Check if tables were created
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('calls', 'call_signaling', 'call_participants', 'call_history');

-- Check if indexes were created
SELECT indexname FROM pg_indexes 
WHERE tablename IN ('calls', 'call_signaling', 'call_participants', 'call_history');

-- Check if RLS is enabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename IN ('calls', 'call_signaling', 'call_participants', 'call_history');
*/

-- =====================================================
-- SETUP COMPLETE
-- =====================================================

-- This completes the call system setup for your existing users table
-- Your call system is now ready to work with Supabase Realtime!
