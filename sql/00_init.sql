-- =============================================================
-- Procedure: load schema
-- Purpose:   Create schemas + tables (if needed),
--            truncate, and load CSVs from /datasets.
-- =============================================================

CREATE OR REPLACE PROCEDURE "schema name".load_"schema name"()
LANGUAGE plpgsql
AS $$
DECLARE
  v_start       timestamptz := clock_timestamp();
  v_step_start  timestamptz;
  v_rows        bigint;
BEGIN
  RAISE NOTICE 'Starting "schema name" load...';

  -- --------------------
  -- Schemas
  -- --------------------
  CREATE SCHEMA IF NOT EXISTS "schema name";
  CREATE SCHEMA IF NOT EXISTS "schema name";
  CREATE SCHEMA IF NOT EXISTS "schema name";

  -- --------------------
  -- Tables (Bronze)
  -- --------------------




  -- --------------------
  -- Truncate for reload
  -- --------------------
  RAISE NOTICE 'Truncating "schema name" tables...';
  TRUNCATE TABLE
    "schema name".

  -- --------------------
  -- Load: File
  -- --------------------
  v_step_start := clock_timestamp();
  EXECUTE format($f$
    COPY bronze.crm_cust_info
    FROM %L
    WITH (FORMAT csv, HEADER true, DELIMITER ',', NULL '', ENCODING 'UTF8')
  $f$, '/datasets/ add_file.csv');

  SELECT count(*) INTO v_rows FROM bronze. add_file;
  RAISE NOTICE 'Loaded "schema name". add_file: % rows (%.3f sec)',
    v_rows, EXTRACT(epoch FROM (clock_timestamp() - v_step_start));


END;
$$;

-- Run it:
CALL bronze.load_"schema name"();
