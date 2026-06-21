-- 001_initial.sql
-- Blamics Database Schema
-- Run manually via migration runner: python -m app.db.migrations.migrate

-- ==========================================
-- ENUMS
-- ==========================================
CREATE TYPE event_status AS ENUM ('upcoming', 'active', 'completed', 'cancelled', 'withdrawn', 'changed');
CREATE TYPE event_importance AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE entity_type_enum AS ENUM ('ipo', 'corporate_action', 'bond', 'news', 'event');
CREATE TYPE action_type_enum AS ENUM ('dividend', 'bonus', 'split', 'rights');
CREATE TYPE source_priority_enum AS ENUM ('official', 'secondary', 'unofficial');
CREATE TYPE event_type_enum AS ENUM (
    'ipo_open', 'ipo_close', 'ipo_listing', 'ipo_allotment',
    'dividend_ex', 'dividend_record', 'dividend_payment',
    'bonus_ex', 'bonus_record',
    'split_ex', 'split_record',
    'rights_open', 'rights_close',
    'bond_open', 'bond_close',
    'news_published'
);

-- ==========================================
-- 0. Sources
-- Source of truth for where data came from.
-- ==========================================
CREATE TABLE sources (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    priority source_priority_enum NOT NULL,
    website TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- 1. IPOs
-- Stores current state of IPOs.
-- ==========================================
CREATE TABLE ipos (
    id TEXT PRIMARY KEY,
    company_name TEXT NOT NULL,
    symbol TEXT,
    issue_price_min NUMERIC,
    issue_price_max NUMERIC,
    lot_size INTEGER,
    issue_size NUMERIC,
    retail_quota NUMERIC,
    status event_status NOT NULL DEFAULT 'upcoming',
    open_date DATE,
    close_date DATE,
    allotment_date DATE,
    listing_date DATE,
    
    -- Source Attribution
    source_id TEXT NOT NULL REFERENCES sources(id),
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- 2. IPO GMP History
-- Append-only tracking of Grey Market Premium values.
-- ==========================================
CREATE TABLE ipo_gmp_history (
    id SERIAL PRIMARY KEY,
    ipo_id TEXT NOT NULL REFERENCES ipos(id) ON DELETE CASCADE,
    gmp_value NUMERIC NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL,
    
    -- Source Attribution
    source_id TEXT NOT NULL REFERENCES sources(id),
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_ipo_gmp_history_ipo_id ON ipo_gmp_history(ipo_id);
CREATE INDEX idx_ipo_gmp_history_timestamp ON ipo_gmp_history(timestamp DESC);

-- ==========================================
-- 3. Corporate Actions
-- Stores current state of dividends, bonuses, splits, rights.
-- ==========================================
CREATE TABLE corporate_actions (
    id TEXT PRIMARY KEY,
    company_name TEXT NOT NULL,
    symbol TEXT NOT NULL,
    action_type action_type_enum NOT NULL,
    ratio TEXT,
    record_date DATE,
    ex_date DATE,
    payment_date DATE,
    status event_status NOT NULL DEFAULT 'upcoming',
    
    -- Source Attribution
    source_id TEXT NOT NULL REFERENCES sources(id),
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_corporate_actions_type ON corporate_actions(action_type);

-- ==========================================
-- 4. Bonds
-- Stores current state of retail-accessible bonds.
-- ==========================================
CREATE TABLE bonds (
    id TEXT PRIMARY KEY,
    issuer_name TEXT NOT NULL,
    symbol TEXT,
    issue_price NUMERIC,
    coupon_rate NUMERIC,
    maturity_date DATE,
    open_date DATE,
    close_date DATE,
    status event_status NOT NULL DEFAULT 'upcoming',
    
    -- Source Attribution
    source_id TEXT NOT NULL REFERENCES sources(id),
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- 5. News
-- Event-relevant news items.
-- ==========================================
CREATE TABLE news (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    summary TEXT,
    url TEXT,
    related_entity_type entity_type_enum,
    related_entity_id TEXT, -- Loose FK
    relevance_reason TEXT,
    published_at TIMESTAMPTZ NOT NULL,
    
    -- Source Attribution
    source_id TEXT NOT NULL REFERENCES sources(id),
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_news_entity ON news(related_entity_type, related_entity_id);
CREATE INDEX idx_news_published_at ON news(published_at DESC);

-- ==========================================
-- 6. Timeline Events
-- The primary dashboard model. Driven by entities above.
-- ==========================================
CREATE TABLE timeline_events (
    id TEXT PRIMARY KEY,
    event_type event_type_enum NOT NULL,
    entity_type entity_type_enum NOT NULL,
    entity_id TEXT NOT NULL, -- Loose FK
    title TEXT NOT NULL,
    subtitle TEXT,
    event_date TIMESTAMPTZ NOT NULL,
    status event_status NOT NULL,
    importance event_importance NOT NULL,
    importance_score INTEGER NOT NULL DEFAULT 0,
    
    -- Source Attribution
    source_id TEXT NOT NULL REFERENCES sources(id),
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_timeline_events_date ON timeline_events(event_date);
CREATE INDEX idx_timeline_events_status ON timeline_events(status);
CREATE INDEX idx_timeline_events_entity ON timeline_events(entity_type, entity_id);
CREATE INDEX idx_timeline_events_importance ON timeline_events(importance_score DESC, event_date ASC);

-- ==========================================
-- 7. Watchlist
-- Remote backup for local-first watchlist state.
-- ==========================================
CREATE TABLE watchlist (
    entity_id TEXT NOT NULL,
    entity_type entity_type_enum NOT NULL,
    
    -- Timestamps
    added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    PRIMARY KEY (entity_id, entity_type)
);

-- ==========================================
-- 8. Event Field History
-- Append-only history of field changes (conflict tracking).
-- Separates current state from historical changes.
-- ==========================================
CREATE TABLE event_field_history (
    id SERIAL PRIMARY KEY,
    entity_type entity_type_enum NOT NULL,
    entity_id TEXT NOT NULL,
    field_name TEXT NOT NULL,
    old_value TEXT,
    new_value TEXT,
    
    -- Source Attribution
    source_id TEXT NOT NULL REFERENCES sources(id),
    
    -- Timestamps
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_event_field_history_entity ON event_field_history(entity_type, entity_id);
CREATE INDEX idx_event_field_history_changed_at ON event_field_history(changed_at DESC);
