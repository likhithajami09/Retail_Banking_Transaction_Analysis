USE retail_banking;

-- =====================================================================
-- 4.3 ANALYZE TRANSACTION PATTERNS
-- Business objective: understand how customers use their accounts and
-- how money moves through the bank.
--
-- Analytical questions:
--  Q1. What are the most common transaction types and channels?
--  Q2. What is the average and total amount per type?
--  Q3. What are the most common descriptions?
--  Q4. How does activity change over time?
--  Q5. How many transactions are failed or pending?
--  Q6. Which customers and segments transact the most?
--  Q7. Which transactions are unusually large?
--  Q8. How does each type relate to account balances?
-- =====================================================================

-- Q1 + Q2: Type summary
SELECT transaction_type, COUNT(*) AS txns,
       ROUND(SUM(amount),2) AS total_amount,
       ROUND(AVG(amount),2) AS avg_amount
FROM transactions
GROUP BY transaction_type
ORDER BY txns DESC;
-- Finding: Types are evenly spread (Transfer 858 ... Fee 784). Average amounts are $6,916 to $7,759.
-- Insight: Interest and Fee amounts are as large as ordinary debits, which is unusual and worth validating.
-- Recommendation: Validate Fee and Interest amounts with the source system.

-- Q1: Channel usage
SELECT channel, COUNT(*) AS txns,
       ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM transactions),1) AS pct
FROM transactions
GROUP BY channel
ORDER BY txns DESC;
-- Finding: Online 29.4%, Branch 22.9%, Mobile 20.5%, ATM 17.1%, POS 5.6%, Wire Transfer 4.5%.
-- Insight: Digital (Online + Mobile) carries 49.9% of activity, but Branch is still a major channel.
-- Recommendation: Keep investing in Online and Mobile and move routine Branch transactions to digital.

-- Q1: Type x channel
SELECT transaction_type, channel, COUNT(*) AS txns
FROM transactions
GROUP BY transaction_type, channel
ORDER BY transaction_type, txns DESC;
-- Finding: ATM Withdrawal only at ATMs; Debit only via Mobile, Online and POS; Transfer is the only
--          type using Wire Transfer.
-- Insight: Each type has a defined set of channels, so channel performance can be managed by type.
-- Recommendation: Strengthen the specific channels that carry each type.

-- Q3: Top descriptions
SELECT description, COUNT(*) AS txns
FROM transactions
GROUP BY description
ORDER BY txns DESC
LIMIT 10;
-- Finding: Investment 1,404 (28.1%), Utility 1,320 (26.4%), Rent 905 (18.1%), Salary 280 (5.6%).
-- Insight: Salary credits are only 5.6%, so the bank is not capturing much payroll activity.
-- Recommendation: Promote salary-account offers and build bill-payment and investment features.

-- Q4: Yearly trend
SELECT YEAR(transaction_date) AS yr, COUNT(*) AS txns, ROUND(SUM(amount),2) AS total_amount
FROM transactions
GROUP BY yr
ORDER BY yr;
-- Finding: 98.7% of transactions fall in 2022-2024. Volume grew from 1,279 (2022) to 1,723 (2023, +34.7%)
--          to 1,933 (2024, +12.2%).

-- Q4: Monthly trend
SELECT DATE_FORMAT(transaction_date,'%Y-%m') AS month,
       COUNT(*) AS txns, ROUND(SUM(amount),2) AS total_amount
FROM transactions
GROUP BY month
ORDER BY month;
-- Finding: Activity is growing at a slowing pace. Busiest month is Jul 2024 (181). No transactions in Jan 2025.
-- Insight: Growth is real but decelerating, and the data is essentially a 2022-2024 window.
-- Recommendation: Plan capacity around mid-year peaks and confirm whether Jan 2025 is a reporting gap.

-- Q5: Status breakdown
SELECT status, COUNT(*) AS txns FROM transactions GROUP BY status;
-- Finding: Completed 1,688 (33.8%), Pending 1,684 (33.7%), Failed 1,628 (32.6%). Success rates by channel
--          are all between 31.6% (ATM) and 35.4% (Online).
-- Insight: Only one in three transactions completes, and the problem is bank-wide. This is the biggest
--          operational issue.
-- Recommendation: Investigate processing failures and pending queues, and set a target completion rate.

-- Q6: Top 10 most active customers
SELECT c.customer_id, c.first_name, c.last_name, c.segment,
       COUNT(t.transaction_id) AS txns,
       ROUND(SUM(t.amount),2)  AS total_amount
FROM customers c
JOIN accounts a     ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id  = t.account_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.segment
ORDER BY txns DESC
LIMIT 10;
-- Finding: Anna Jones (C000226) leads with 65 transactions. The top 10 customers account for only 8.2%
--          of all transactions. 366 of 500 customers have transacted.
-- Insight: Activity is widely spread. About 27% of customers (134) have no transactions at all.
-- Recommendation: Offer loyalty benefits to top users and run activation campaigns for dormant customers.

-- Q6: Transactions by customer segment
SELECT c.segment, COUNT(t.transaction_id) AS txns,
       ROUND(AVG(t.amount),2) AS avg_amount
FROM customers c
JOIN accounts a     ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id  = t.account_id
GROUP BY c.segment;
-- Finding: Business is the most active segment (1,054 txns); Premium is the lowest (663).
-- Insight: Premium customers transact the least despite the label.
-- Recommendation: Prioritise service quality for Business and investigate low Premium engagement.

-- Q7: Large transactions (above 2x the overall average)
SELECT * FROM transactions
WHERE amount > 2 * (SELECT AVG(amount) FROM transactions)
ORDER BY amount DESC
LIMIT 20;
-- Finding: The threshold is $14,356. 206 transactions exceed it, but only 57 are Completed
--          (82 Pending, 67 Failed).
-- Insight: Large transfers mostly do not complete, hurting customer trust.
-- Recommendation: Add alerts and manual review for large pending items.

-- Q8: Average account balance after each type
SELECT transaction_type, ROUND(AVG(balance_after),2) AS avg_balance_after
FROM transactions
GROUP BY transaction_type;
-- Finding: Balances are higher after Credit ($25,502) and Interest ($25,416) than after Debit, ATM, Fee, Transfer.
-- Insight: Inflow types are associated with higher balances. balance_after looks inconsistent in places.
-- Recommendation: Use balance_after for indicative analysis only.

-- 4.3 Conclusion: Usage is spread evenly across types, with Online/Mobile leading and volume growing
--   each year. The standout problem is that only 33.8% of transactions complete.
