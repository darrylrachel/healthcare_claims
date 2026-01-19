DROP TABLE IF EXISTS stg.members;
CREATE TABLE stg.members (
    member_id VARCHAR,
    member_age INTEGER,
    member_gender TEXT,
    plan_type VARCHAR,
    enrollment_start_date DATE,
    enrollment_end_date DATE

);

DROP TABLE IF EXISTS stg.claims;
CREATE TABLE stg.claims(
    claim_id VARCHAR,
    member_id VARCHAR,
    provider_id VARCHAR,
    claim_date DATE,
    claim_type TEXT,
    cpt_code VARCHAR,
    icd_code VARCHAR,
    billed_amount NUMERIC(12, 2),
    paid_amount NUMERIC(12, 2)
);


INSERT INTO stg.members (member_id,
                         member_age,
                         member_gender,
                         plan_type,
                         enrollment_start_date,
                         enrollment_end_date
)
SELECT member_id,
       CAST(member_age AS INTEGER) AS member_age,
       CASE member_gender
           WHEN UPPER('F') THEN 'Female'
           WHEN UPPER('M') THEN 'Male'
           ELSE 'N/A'
       END AS member_gender,
       UPPER(TRIM(plan_type)) AS plan_type,
       CAST(enrollment_start_date AS DATE),
       CAST(enrollment_end_date AS DATE)
FROM raw.members;


-- ---------------------
-- stg.claims
-- ---------------------
INSERT INTO stg.claims (claim_id,
                        member_id,
                        provider_id,
                        claim_date,
                        claim_type,
                        cpt_code,
                        icd_code,
                        billed_amount,
                        paid_amount
)
SELECT claim_id,
       member_id,
       provider_id,
       CAST(claim_date AS DATE) AS claim_date,
       claim_type,
       cpt_code,
       icd_code,
       CAST(billed_amount AS NUMERIC(12,2)) AS billed_amount,
       CAST(paid_amount AS NUMERIC(12,2)) AS paid_amount
FROM raw.claims;