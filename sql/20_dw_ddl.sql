-- ============================================================
-- DW BUILD SCRIPT (PostgreSQL) - FULL REFRESH
-- ============================================================

-- If your session is in a failed transaction state:
ROLLBACK;

BEGIN;

-- 1) Ensure DW schema exists
CREATE SCHEMA IF NOT EXISTS dw;

-- 2) Create DIM tables
CREATE TABLE IF NOT EXISTS dw.dim_member (
    member_id               VARCHAR PRIMARY KEY,
    member_age              INTEGER,
    member_gender           VARCHAR(10),
    plan_type               VARCHAR(50),
    enrollment_start_date   DATE,
    enrollment_end_date     DATE,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dw.dim_provider (
    provider_id VARCHAR PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS dw.dim_cpt (
    cpt_code VARCHAR PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS dw.dim_icd (
    icd_code VARCHAR PRIMARY KEY
);

-- 3) Create FACT table
CREATE TABLE IF NOT EXISTS dw.fact_claims (
    claim_id      VARCHAR PRIMARY KEY,
    member_id     VARCHAR NOT NULL,
    provider_id   VARCHAR,
    claim_date    DATE,
    claim_type    VARCHAR(50),
    cpt_code      VARCHAR,
    icd_code      VARCHAR,
    billed_amount NUMERIC(12, 2),
    paid_amount   NUMERIC(12, 2)
);

-- 4) FULL REFRESH LOAD (truncate in safe order)
-- If FKs already exist from a previous run, truncating fact first can fail.
-- So we truncate fact first, then dims.
TRUNCATE TABLE dw.fact_claims;

TRUNCATE TABLE dw.dim_provider;
TRUNCATE TABLE dw.dim_cpt;
TRUNCATE TABLE dw.dim_icd;
TRUNCATE TABLE dw.dim_member;

-- 5) Load DIM: member (MUST come before fact FK)
INSERT INTO dw.dim_member (
    member_id,
    member_age,
    member_gender,
    plan_type,
    enrollment_start_date,
    enrollment_end_date
)
SELECT
    TRIM(member_id::text)                              AS member_id,
    member_age,
    member_gender,
    plan_type,
    CAST(enrollment_start_date AS DATE)                AS enrollment_start_date,
    CAST(enrollment_end_date AS DATE)                  AS enrollment_end_date
FROM stg.members
WHERE member_id IS NOT NULL;

-- 6) Load thin dims from claims
INSERT INTO dw.dim_provider (provider_id)
SELECT DISTINCT TRIM(provider_id::text)
FROM stg.claims
WHERE provider_id IS NOT NULL;

INSERT INTO dw.dim_cpt (cpt_code)
SELECT DISTINCT TRIM(cpt_code::text)
FROM stg.claims
WHERE cpt_code IS NOT NULL;

INSERT INTO dw.dim_icd (icd_code)
SELECT DISTINCT TRIM(icd_code::text)
FROM stg.claims
WHERE icd_code IS NOT NULL;

-- 7) Load FACT
INSERT INTO dw.fact_claims (
    claim_id, member_id, provider_id, claim_date, claim_type,
    cpt_code, icd_code, billed_amount, paid_amount
)
SELECT
    TRIM(claim_id::text)           AS claim_id,
    TRIM(member_id::text)          AS member_id,
    CASE WHEN provider_id IS NULL THEN NULL ELSE TRIM(provider_id::text) END AS provider_id,
    CAST(claim_date AS DATE)       AS claim_date,
    claim_type,
    CASE WHEN cpt_code IS NULL THEN NULL ELSE TRIM(cpt_code::text) END       AS cpt_code,
    CASE WHEN icd_code IS NULL THEN NULL ELSE TRIM(icd_code::text) END       AS icd_code,
    billed_amount,
    paid_amount
FROM stg.claims
WHERE claim_id IS NOT NULL;

COMMIT;

-- ============================================================
-- 8) Add constraints OUTSIDE the load transaction
--    (Cleaner error handling; if it fails, loads still exist)
-- ============================================================

-- Member FK
ALTER TABLE dw.fact_claims
DROP CONSTRAINT IF EXISTS fk_fact_claims_member;

ALTER TABLE dw.fact_claims
ADD CONSTRAINT fk_fact_claims_member
FOREIGN KEY (member_id) REFERENCES dw.dim_member(member_id);

-- Provider FK
ALTER TABLE dw.fact_claims
DROP CONSTRAINT IF EXISTS fk_fact_claims_provider;

ALTER TABLE dw.fact_claims
ADD CONSTRAINT fk_fact_claims_provider
FOREIGN KEY (provider_id) REFERENCES dw.dim_provider(provider_id);

-- CPT FK
ALTER TABLE dw.fact_claims
DROP CONSTRAINT IF EXISTS fk_fact_claims_cpt;

ALTER TABLE dw.fact_claims
ADD CONSTRAINT fk_fact_claims_cpt
FOREIGN KEY (cpt_code) REFERENCES dw.dim_cpt(cpt_code);

-- ICD FK
ALTER TABLE dw.fact_claims
DROP CONSTRAINT IF EXISTS fk_fact_claims_icd;

ALTER TABLE dw.fact_claims
ADD CONSTRAINT fk_fact_claims_icd
FOREIGN KEY (icd_code) REFERENCES dw.dim_icd(icd_code);

-- ============================================================
-- 9) Indexes for Tableau performance
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_fact_claims_member_id   ON dw.fact_claims (member_id);
CREATE INDEX IF NOT EXISTS idx_fact_claims_claim_date  ON dw.fact_claims (claim_date);
CREATE INDEX IF NOT EXISTS idx_fact_claims_claim_type  ON dw.fact_claims (claim_type);
CREATE INDEX IF NOT EXISTS idx_fact_claims_provider_id ON dw.fact_claims (provider_id);
CREATE INDEX IF NOT EXISTS idx_fact_claims_cpt_code    ON dw.fact_claims (cpt_code);
CREATE INDEX IF NOT EXISTS idx_fact_claims_icd_code    ON dw.fact_claims (icd_code);
