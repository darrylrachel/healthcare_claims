-- =============================================================
-- Procedure: load schema
-- Purpose:   Create schemas + tables (if needed),
--            truncate, and load CSVs from /datasets.
-- =============================================================
DROP DATABASE IF EXISTS healthcare_claims;
CREATE DATABASE healthcare_claims;

-- --------------------
-- Schemas
-- --------------------
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dw;

-- --------------------
-- Tables (raw)
-- --------------------
DROP TABLE IF EXISTS raw.members;
CREATE TABLE raw.members (
    member_id TEXT,
    member_age TEXT,
    member_gender TEXT,
    plan_type TEXT,
    enrollment_start_date TEXT,
    enrollment_end_date TEXT

);

DROP TABLE IF EXISTS raw.claims;
CREATE TABLE raw.claims(
    claim_id TEXT,
    member_id TEXT,
    provider_id TEXT,
    claim_date TEXT,
    claim_type TEXT,
    cpt_code TEXT,
    icd_code TEXT,
    billed_amount TEXT,
    paid_amount TEXT
);


-- --------------------
-- Truncate for reload
-- --------------------
TRUNCATE TABLE raw.members;
TRUNCATE TABLE raw.claims;

-- --------------------
-- Load: File
-- --------------------
COPY raw.members
FROM '/datasets/members.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', NULL '', ENCODING 'UTF8');

COPY raw.claims
FROM '/datasets/claims.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', NULL '', ENCODING 'UTF8');
