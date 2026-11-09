USE retail_banking;

-- =====================================================================
-- 4.1 UNDERSTAND CUSTOMER PROFILE AND SEGMENTATION
-- Business objective: understand the customer base and the differences
-- between customer groups.
--
-- "Today" rule: the latest transaction date (2025-02-22) is treated as today.
--
-- Analytical questions:
--  Q1. How many customers are in each segment?
--  Q2. What are average income and credit score per segment?
--  Q3. Which cities and states have the most customers?
--  Q4. What does the age and gender mix look like?
--  Q5. What share of customers are active and KYC-verified?
--  Q6. How long have customers been with the bank?
--  Q7. How are customers spread across credit score bands?
-- =====================================================================

SELECT MAX(transaction_date) AS today FROM transactions;   -- 2025-02-22

-- Q1 + Q2: Customers per segment, with average income and credit score
SELECT segment, COUNT(*) AS customers,
       ROUND(AVG(annual_income),0) AS avg_income,
       ROUND(AVG(credit_score),0)  AS avg_credit_score
FROM customers
GROUP BY segment
ORDER BY customers DESC;
-- Finding: Student is the largest segment (100 customers, 20.0%), then Business (97), Retail (80),
--          Premium (76), Wealth (74) and Senior (73). Average income only ranges from $140,526 (Retail)
--          to $158,668 (Premium), and average credit score from 679 to 687.
-- Insight: The segments are almost identical in income and credit quality, so the labels are not tied
--          to measurable customer value.
-- Recommendation: Re-define segments using clear criteria (income, balances, product holdings).

-- Q3: Top 10 cities by customers
SELECT city, state, COUNT(*) AS customers
FROM customers
GROUP BY city, state
ORDER BY customers DESC
LIMIT 10;
-- Finding: Omaha NE leads with 15 customers. Customers are spread over 56 cities, and the top 10
--          cities hold only 27% (135).
-- Insight: The customer base is geographically spread out, with no single dominant market.
-- Recommendation: Decide branch and marketing investment by product and branch performance, and use
--          digital channels for the long tail of small cities.

-- Q4: Gender split
SELECT gender, COUNT(*) AS customers FROM customers GROUP BY gender;
-- Finding: Male 190 (38.0%), Non-binary 156 (31.2%), Female 154 (30.8%).
-- Insight: The mix is fairly balanced.
-- Recommendation: Keep products and communication gender-neutral.

-- Q4: Age groups (uses the "today" rule)
SELECT CASE
         WHEN TIMESTAMPDIFF(YEAR, date_of_birth, (SELECT MAX(transaction_date) FROM transactions)) < 30 THEN 'Under 30'
         WHEN TIMESTAMPDIFF(YEAR, date_of_birth, (SELECT MAX(transaction_date) FROM transactions)) < 45 THEN '30-44'
         WHEN TIMESTAMPDIFF(YEAR, date_of_birth, (SELECT MAX(transaction_date) FROM transactions)) < 60 THEN '45-59'
         ELSE '60+' END AS age_group,
       COUNT(*) AS customers
FROM customers
GROUP BY age_group;
-- Finding: 30-44 is the largest group (168, 33.6%), then 45-59 (151), 60+ (111) and Under 30 (70, 14.0%).
-- Insight: The bank is strongest with mid-career customers, weakest with young adults.
-- Recommendation: Build a digital-first starter proposition to attract under-30s.

-- Q5: KYC status vs active status
SELECT kyc_status, is_active, COUNT(*) AS customers
FROM customers
GROUP BY kyc_status, is_active;
-- Finding: Verified 143, Partial 129, Pending 123, Failed 105 (all inactive). 241 of the 375 active
--          customers (64.3%) are Partial or Pending; only 28.6% of all customers are Verified.
-- Insight: Failed-KYC customers are all inactive, so that control works, but almost two thirds of active
--          customers have incomplete KYC, which is a compliance risk.
-- Recommendation: Run a KYC completion drive for the 241 active Partial/Pending customers.

-- Q6: Tenure in years by segment (uses the "today" rule)
SELECT segment,
       ROUND(AVG(TIMESTAMPDIFF(YEAR, customer_since,
            (SELECT MAX(transaction_date) FROM transactions))),1) AS avg_tenure_years
FROM customers
GROUP BY segment;
-- Finding: Overall average tenure is 6.9 years. Business (7.3) is longest; Wealth (6.4) and Premium (6.2)
--          are the shortest.
-- Insight: The two highest-value-sounding segments are the newest.
-- Recommendation: Prioritise onboarding and early engagement for Premium and Wealth.

-- Q7: Credit score bands
SELECT CASE WHEN credit_score >= 750 THEN 'Excellent'
            WHEN credit_score >= 650 THEN 'Good'
            WHEN credit_score >= 550 THEN 'Fair'
            ELSE 'Poor' END AS credit_band,
       COUNT(*) AS customers
FROM customers
GROUP BY credit_band;
-- Finding: Excellent 169, Good 124, Fair 135, Poor 72. 58.6% of customers are Good or Excellent.
-- Insight: The base is reasonably strong for lending, but 41.4% are Fair or Poor.
-- Recommendation: Cross-sell cards and loans to Good/Excellent customers, and offer credit-builder
--          products to Fair/Poor customers.

-- 4.1 Conclusion: Balanced by gender, spread across 56 cities, mostly aged 30-59, 75% active. Segment
--   labels do not reflect income or credit quality, and 64% of active customers lack completed KYC.
