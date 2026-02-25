-- ============================================================
-- E-CABBZ: Master Franchise Registration Table
-- Run this in your Supabase SQL Editor
-- ============================================================

-- STEP 1: Change drivers.id column from UUID to TEXT
--         (Required for the ECABBZ-DRV-YYYYMMDD-XXXX format)
-- ⚠️ Skip this if you already changed it.
ALTER TABLE drivers ALTER COLUMN id TYPE text;
ALTER TABLE drivers ALTER COLUMN id DROP DEFAULT;

-- ============================================================
-- STEP 2: Create master_franchises table
-- ============================================================
CREATE TABLE IF NOT EXISTS master_franchises (
  -- Primary key: meaningful ID like ECABBZ-MFR-20260224-A3F7
  id                        TEXT PRIMARY KEY,

  -- ── Personal / Owner Info ──────────────────────────────────
  full_name                 TEXT NOT NULL,
  fathers_husband_name      TEXT NOT NULL,
  age                       INT  NOT NULL,
  company_name              TEXT,
  ownership_type            TEXT NOT NULL CHECK (ownership_type IN ('Individual', 'Pvt Ltd', 'Partnership', 'Trust')),

  -- ── Contact Info ──────────────────────────────────────────
  mobile1                   TEXT NOT NULL,
  mobile2                   TEXT,
  email                     TEXT NOT NULL,

  -- ── Identity Documents ───────────────────────────────────
  pan                       TEXT NOT NULL,
  aadhaar                   TEXT NOT NULL,

  -- ── Address ──────────────────────────────────────────────
  state                     TEXT NOT NULL,
  district                  TEXT NOT NULL,
  town                      TEXT NOT NULL,
  address                   TEXT NOT NULL,
  pin                       TEXT NOT NULL,
  avg_population            TEXT,

  -- ── Nearby Landmarks ─────────────────────────────────────
  police_station_name       TEXT,
  police_station_contact    TEXT,
  railway_station           TEXT,   -- name + distance
  airport                   TEXT,   -- name + distance
  seaport                   TEXT,   -- name + distance
  metro_station             TEXT,   -- name + distance
  -- Nearest highways — 5 types, each stored as name + distance in km
  expressway_name           TEXT,   -- Expressway: name/route
  expressway_km             TEXT,   -- Expressway: distance in km
  national_hwy_name         TEXT,   -- National Highway: name/route
  national_hwy_km           TEXT,   -- National Highway: distance in km
  state_hwy_name            TEXT,   -- State Highway: name/route
  state_hwy_km              TEXT,   -- State Highway: distance in km
  main_road_name            TEXT,   -- Main Central Road: name/route
  main_road_km              TEXT,   -- Main Central Road: distance in km
  town_road_name            TEXT,   -- Town Roads: name/route
  town_road_km              TEXT,   -- Town Roads: distance in km

  -- ── Business Profile ─────────────────────────────────────
  has_taxi_driver_database  BOOLEAN DEFAULT FALSE,
  taxi_driver_count         TEXT,
  has_ev_charging_station   BOOLEAN DEFAULT FALSE,
  ev_charging_details       TEXT,
  location_overview         TEXT,   -- pilgrimage / tourist / IT park / industrial / residential

  -- ── Infrastructure ───────────────────────────────────────
  has_land                  BOOLEAN DEFAULT FALSE,
  land_details              TEXT,   -- size, location, highway type
  has_office                BOOLEAN DEFAULT FALSE,
  office_details            TEXT,   -- sqft, location, address

  -- ── Experience ───────────────────────────────────────────
  taxi_experience           TEXT,
  ev_solar_experience       TEXT,

  -- ── Verification ─────────────────────────────────────────
  verified_city             TEXT,
  verified_date             DATE,

  -- ── Metadata ─────────────────────────────────────────────
  status                    TEXT NOT NULL DEFAULT 'pending'
                              CHECK (status IN ('pending', 'reviewing', 'approved', 'rejected')),
  created_at                TIMESTAMPTZ DEFAULT NOW(),
  updated_at                TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_master_franchises_updated_at
  BEFORE UPDATE ON master_franchises
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE master_franchises ENABLE ROW LEVEL SECURITY;

-- Allow anyone to INSERT (public registration)
CREATE POLICY "Allow public insert"
  ON master_franchises FOR INSERT
  WITH CHECK (true);

-- Allow SELECT only with matching ID (franchisee can view own record)
CREATE POLICY "Allow select own record"
  ON master_franchises FOR SELECT
  USING (true);

-- ============================================================
-- STEP 3: Index for sorting / querying
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_mfr_state     ON master_franchises (state);
CREATE INDEX IF NOT EXISTS idx_mfr_district  ON master_franchises (district);
CREATE INDEX IF NOT EXISTS idx_mfr_status    ON master_franchises (status);
CREATE INDEX IF NOT EXISTS idx_mfr_created   ON master_franchises (created_at DESC);
