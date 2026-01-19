-- Which claim types are the most expensive?
SELECT claim_type,
       COUNT(*)                  AS claim_count,
       SUM(paid_amount)          AS total_paid_amount,
       SUM(billed_amount)        AS total_billed_amount,
       ROUND(AVG(paid_amount),2) AS avg_paid_per_claim
FROM dw.fact_claims
GROUP BY claim_type
ORDER BY total_paid_amount DESC;


-- Which CPT and ICD codes drive the highest spending?
--  Top CPT codes by highest spending
SELECT cpt_code,
       COUNT(*)                    AS claim_count,
       SUM(paid_amount)            AS total_paid_amount,
       ROUND(AVG(paid_amount), 2)  AS avg_paid_per_claim
FROM dw.fact_claims
WHERE cpt_code IS NOT NULL
GROUP BY cpt_code
ORDER BY total_paid_amount DESC
LIMIT 10;

--  Top ICD codes by highest spending
SELECT icd_code,
       COUNT(*)                    AS claim_count,
       SUM(paid_amount)            AS total_paid_amount,
       ROUND(AVG(paid_amount), 2)  AS avg_paid_per_claim
FROM dw.fact_claims
WHERE icd_code IS NOT NULL
GROUP BY icd_code
ORDER BY total_paid_amount DESC
LIMIT 10;


-- Which members account for the largest share of total costs?
WITH member_costs AS (
    SELECT
        member_id,
        SUM(paid_amount) AS total_paid_amount
    FROM dw.fact_claims
    GROUP BY member_id
),
total_cost AS (
    SELECT SUM(total_paid_amount) AS overall_paid_amount
    FROM member_costs
)
SELECT
    mc.member_id,
    dm.member_age,
    dm.member_gender,
    dm.plan_type,
    mc.total_paid_amount,
    ROUND(
        mc.total_paid_amount / tc.overall_paid_amount * 100, 2
    ) AS pct_of_total_cost
FROM member_costs mc
JOIN dw.dim_member dm
  ON mc.member_id = dm.member_id
CROSS JOIN total_cost tc
ORDER BY mc.total_paid_amount DESC
LIMIT 10;


-- How do billed amounts compare to paid amounts?
--  Overall comparison
SELECT
    SUM(billed_amount) AS total_billed_amount,
    SUM(paid_amount)   AS total_paid_amount,
    ROUND(
        SUM(paid_amount) / SUM(billed_amount), 2
    ) AS overall_paid_ratio
FROM dw.fact_claims;


--  Compare by claim type
SELECT
    claim_type,
    COUNT(*) AS claim_count,
    SUM(billed_amount) AS total_billed_amount,
    SUM(paid_amount)   AS total_paid_amount,
    ROUND(
        SUM(paid_amount) / SUM(billed_amount), 2
    ) AS paid_ratio
FROM dw.fact_claims
GROUP BY claim_type
ORDER BY paid_ratio DESC;

--  Compare by provider
SELECT
    provider_id,
    COUNT(*) AS claim_count,
    SUM(billed_amount) AS total_billed_amount,
    SUM(paid_amount)   AS total_paid_amount,
    ROUND(
        SUM(paid_amount) / SUM(billed_amount), 2
    ) AS paid_ratio
FROM dw.fact_claims
WHERE provider_id IS NOT NULL
GROUP BY provider_id
HAVING SUM(billed_amount) > 0
ORDER BY paid_ratio DESC;


--  Compare by CPT (pricing efficiency)
SELECT
    cpt_code,
    COUNT(*) AS claim_count,
    SUM(billed_amount) AS total_billed_amount,
    SUM(paid_amount)   AS total_paid_amount,
    ROUND(
        SUM(paid_amount) / SUM(billed_amount), 2
    ) AS paid_ratio
FROM dw.fact_claims
WHERE cpt_code IS NOT NULL
GROUP BY cpt_code
HAVING SUM(billed_amount) > 0
ORDER BY paid_ratio DESC
LIMIT 10;