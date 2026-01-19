# Healthcare Claims Cost Analysis

## Overview

This project analyzes synthetic healthcare claims data to identify the primary drivers of insurer costs. The objective is to understand where healthcare spending is concentrated across claim types, procedures, diagnoses, and members, and to evaluate how billed amounts compare to actual paid amounts.

---

## Which claim types are the most expensive?

Inpatient claims are the most expensive claim type, accounting for the largest share of total paid costs despite not having the highest claim volume. This indicates that overall spending is driven primarily by high-severity claims rather than claim frequency.

---

## Which CPT and ICD codes drive the highest spending?

Healthcare spending was analyzed by aggregating total paid amounts at the procedure (CPT) and diagnosis (ICD) code levels. Codes were ranked by total paid amount to identify the primary cost drivers. The analysis shows that a limited number of CPT and ICD codes contribute disproportionately to total healthcare spending, suggesting that specific procedures and clinical conditions account for a significant share of insurer costs.

Average paid amount per claim was also evaluated to differentiate between high-volume, low-cost services and lower-volume, high-cost procedures.

---

## Which members account for the largest share of total costs?

Total paid healthcare costs were aggregated at the member level to assess cost concentration across the population. Members were ranked by total paid amount, and each member’s share of overall spending was calculated as a percentage of total paid costs. The results show that a small subset of members accounts for a disproportionately large share of total healthcare spending, indicating cost concentration driven by high-severity or high-utilization cases rather than evenly distributed costs across the member base.

---

## How do billed amounts compare to paid amounts?

Billed and paid amounts were compared using a paid-to-billed ratio to evaluate reimbursement behavior. Overall, paid amounts are consistently lower than billed amounts, as expected. However, the paid ratio varies significantly by claim type, provider, and procedure, indicating differences in pricing agreements and reimbursement structures. Certain claim types and CPT codes are reimbursed at relatively higher rates, while others exhibit substantial discounts from billed charges.

---

## Approach

The data was modeled using a dimensional warehouse structure with a claim-level fact table and supporting dimension tables. Analysis focused on total paid amounts to reflect insurer cost exposure, supplemented with claim counts and average paid per claim to distinguish between utilization-driven and severity-driven cost patterns.

---

## Limitations

This analysis is based on synthetic data and does not include provider or procedure descriptions. The results are intended to demonstrate analytical methodology and data modeling practices rather than draw real-world healthcare or financial conclusions.
