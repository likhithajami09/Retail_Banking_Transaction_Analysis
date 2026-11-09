USE retail_banking;

-- =====================================================================
-- 4.2 UNDERSTAND ACCOUNT USAGE AND BRANCH ACTIVITY
-- Business objective: understand how accounts are used and how activity
-- differs across account types and branches.
--
-- Analytical questions:
--  Q1. How many accounts, and what total balance, per account type?
--  Q2. Which customers have multiple accounts?
--  Q3. Which branches have the most accounts and highest balances?
--  Q4. How do interest rates differ by account type?
--  Q5. How do active and closed accounts differ?
--  Q6. Which branches are overloaded (accounts per employee)?
--  Q7. Are there accounts with negative balances?
--  Q8. (added) Which account types are closed most often?
-- =====================================================================

-- Q1 + Q4: Account type summary
SELECT account_type, COUNT(*) AS accounts,
       ROUND(SUM(current_balance),2) AS total_balance,
       ROUND(AVG(current_balance),2) AS avg_balance,
       ROUND(AVG(interest_rate),2)   AS avg_interest
FROM accounts
GROUP BY account_type;
-- Finding: Total deposits are $10.20M. IRA holds the most ($2.89M), then Certificate of Deposit ($2.60M,
--          highest rate 4.62%), Business Checking ($2.06M), Money Market ($1.65M), Savings ($0.58M)
--          and Checking ($0.41M).
-- Insight: IRA, CD and Money Market hold 69% of deposits. Savings and Checking are popular by count
--          but hold small balances.
-- Recommendation: Move Savings customers toward Money Market or CD, and protect the IRA and CD base.

-- Q2: Customers with more than one account
SELECT c.customer_id, c.first_name, c.last_name, COUNT(a.account_id) AS num_accounts
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(a.account_id) > 1
ORDER BY num_accounts DESC;
-- Finding: 211 customers (57.7% of the 366 account holders) hold more than one account; the maximum is 8.
--          134 customers (26.8% of all customers) hold no account at all.
-- Insight: Multi-account holding indicates deep relationships, but over a quarter of customers have no account.
-- Recommendation: Offer bundled benefits to multi-account holders and invite no-account customers to open one.

-- Q3: Branch ranking (grouped by branch_id because branch names repeat)
SELECT b.branch_id, b.branch_name, b.city, b.region,
       COUNT(a.account_id) AS accounts,
       ROUND(SUM(a.current_balance),2) AS total_balance
FROM branches b
JOIN accounts a ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.branch_name, b.city, b.region
ORDER BY total_balance DESC
LIMIT 10;
-- Finding: BR025 Atlanta leads with $501,926, then BR004 San Diego and BR023 Washington. The smallest
--          is BR010 Memphis ($58,688). The top 10 of 40 branches hold 37.3% of balances.
-- Insight: Branch deposit performance varies about 8x between best and worst.
-- Recommendation: Study what top branches do and set improvement targets for the bottom branches.

-- Q5: Active vs closed
SELECT status, COUNT(*) AS accounts,
       ROUND(AVG(current_balance),2) AS avg_balance
FROM accounts
GROUP BY status;
-- Finding: 497 accounts are Active and 203 are Closed (29.0%), all with a $0 balance.
-- Insight: Nearly 3 in 10 accounts have been closed, and the money left before closure.
-- Recommendation: Add exit surveys and watch accounts whose balance falls sharply as an early warning.

-- Q6: Accounts per employee at each branch (workload)
SELECT b.branch_id, b.branch_name, b.employee_count,
       COUNT(a.account_id) AS accounts,
       ROUND(COUNT(a.account_id)/b.employee_count,2) AS accounts_per_employee
FROM branches b
LEFT JOIN accounts a ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.branch_name, b.employee_count
ORDER BY accounts_per_employee DESC;
-- Finding: BR011 Pittsburgh is the most loaded (1.75 accounts per employee); the lowest are BR003
--          Anchorage and BR018 Philadelphia (0.30). Bank average is about 0.57.
-- Insight: Workload differs about 6x between branches.
-- Recommendation: Rebalance staff or redirect new account openings toward under-used branches.

-- Q7: Accounts below zero (using overdraft)
SELECT account_id, account_type, current_balance, overdraft_limit
FROM accounts
WHERE current_balance < 0;
-- Finding: 0 rows. No account has a negative balance. 219 accounts have an overdraft limit.
-- Insight: Overdraft facilities exist but none is currently used.
-- Recommendation: Review whether overdraft limits are priced and promoted well.

-- Q8 (added): Closure rate by account type
SELECT account_type, COUNT(*) AS accounts,
       SUM(status = 'Closed') AS closed,
       ROUND(SUM(status = 'Closed')*100/COUNT(*),1) AS pct_closed
FROM accounts
GROUP BY account_type
ORDER BY pct_closed DESC;
-- Finding: Business Checking 33.6% and Certificate of Deposit 33.1% close the most; IRA is lowest at 24.3%.
-- Insight: Business Checking is both a large deposit product and the most-closed one.
-- Recommendation: Investigate why Business Checking and CD accounts close and introduce retention offers.

-- 4.2 Conclusion: Deposits ($10.2M) are concentrated in IRA, CD and Money Market. 29% of accounts are
--   closed, and branch performance and workload are very uneven.
