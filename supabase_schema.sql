-- Create the drivers table
CREATE TABLE drivers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Personal Details
  first_name TEXT NOT NULL,
  middle_name TEXT,
  last_name TEXT,
  state TEXT NOT NULL,
  district TEXT NOT NULL,
  village TEXT NOT NULL,
  address TEXT NOT NULL,
  pin TEXT NOT NULL,
  landmark TEXT,
  dob TEXT NOT NULL, -- Storing as TEXT since it's formatted as DD/MM/YYYY in UI
  blood_group TEXT NOT NULL,
  
  -- ID & Contact
  aadhaar TEXT NOT NULL UNIQUE,
  pan TEXT NOT NULL UNIQUE,
  mobile1 TEXT NOT NULL,
  mobile2 TEXT,
  email TEXT NOT NULL,
  
  -- Driving License
  license_no TEXT NOT NULL UNIQUE,
  license_issue_date TEXT NOT NULL,
  license_expiry_date TEXT NOT NULL,
  
  -- Bank Details
  bank1_name TEXT NOT NULL,
  bank1_acc TEXT NOT NULL,
  bank1_ifsc TEXT NOT NULL,
  bank2_name TEXT,
  bank2_acc TEXT,
  bank2_ifsc TEXT,
  
  -- Family Details
  father_name TEXT NOT NULL,
  father_mobile TEXT NOT NULL,
  mother_name TEXT NOT NULL,
  mother_mobile TEXT NOT NULL,
  spouse_name TEXT,
  spouse_mobile TEXT,
  
  -- Education, Languages & Experience (JSONB for flexibility)
  education_json JSONB,
  languages_json JSONB,
  experience_json JSONB,
  
  -- Legal & Insurance
  has_insurance BOOLEAN DEFAULT FALSE,
  insurance_company TEXT,
  policy_no TEXT,
  sum_insured TEXT, -- Storing as TEXT to handle potential currency/formatting
  policy_end_date TEXT,
  
  has_police_case BOOLEAN DEFAULT FALSE,
  case_details TEXT
);

-- Enable RLS
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;

-- Allow anyone to apply (insert only)
CREATE POLICY "Allow public insert (Driver Application)" ON drivers
FOR INSERT WITH CHECK (true);

-- Allow admins (service_role) full access
CREATE POLICY "Full access for service role" ON drivers
FOR ALL USING (true);
