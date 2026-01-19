-- =============================================================
-- Procedure: load schema
-- Purpose:   Create schemas + tables (if needed),
--            truncate, and load CSVs from /datasets.
-- =============================================================


-- --------------------
-- Schemas
-- --------------------
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dw;

-- --------------------
-- Tables (Bronze)
-- --------------------




-- --------------------
-- Truncate for reload
-- --------------------
TRUNCATE TABLE raw.

-- --------------------
-- Load: File
-- --------------------
COPY raw.
FROM '/datasets/ add_file.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', NULL '', ENCODING 'UTF8');
