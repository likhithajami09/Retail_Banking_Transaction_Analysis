USE retail_banking;

-- =====================================================================
-- 4.5 UNDERSTAND CARD USAGE AND PRODUCT ENGAGEMENT
-- Business objective: understand card usage and how it relates to the
-- broader banking relationship.
--
-- Analytical questions:
--  Q1. How many cards of each type and network?
--  Q2. How much of the credit limit is being used?
--  Q3. What share of cards is active vs inactive?
--  Q4. Who earns the most reward points?
--  Q5. Which cards have expired?
--  Q6. How many cards does each customer hold?
--  Q7. How many products does each customer use?
-- =====================================================================

-- Q1 + Q2: Card type summary
SELECT card_type, COUNT(*) AS cards,
       ROUND(AVG(credit_limit),2) AS avg_limit,
       ROUND(AVG(outstanding_balance),2) AS avg_outstanding,
       ROUND(AVG(reward_points),0) AS avg_rewards
FROM cards
GROUP BY card_type;
-- Finding: Debit 358 cards (59.7%), Credit 242 (40.3%). Average reward points are almost identical
--          (Credit 24,790 vs Debit 24,490).
-- Insight: Debit cards earn as many rewards as credit cards, which suggests an undifferentiated programme.
-- Recommendation: Review the rewards design by card type.

-- Q1: Network share
SELECT network, COUNT(*) AS cards FROM cards GROUP BY network ORDER BY cards DESC;
-- Finding: Visa 26.5%, Mastercard 25.5%, American Express 24.7%, Discover 23.3%.
-- Insight: Cards are spread evenly across four networks.
-- Recommendation: Use this balance as leverage in partnership negotiations.

-- Q3: Active vs inactive
SELECT is_active, COUNT(*) AS cards,
       ROUND(AVG(outstanding_balance),2) AS avg_outstanding,
       ROUND(AVG(reward_points),0) AS avg_rewards
FROM cards
GROUP BY is_active;
-- Finding: Only 37 cards (6.2%) are active; 563 (93.8%) are inactive.
-- Insight: Almost the entire card portfolio is dormant.
-- Recommendation: Run activation and reissue campaigns with incentives.

-- Q2: Credit utilization (top 10, only cards with a limit)
SELECT card_id, credit_limit, outstanding_balance,
       ROUND(outstanding_balance*100/credit_limit,1) AS utilization_pct
FROM cards
WHERE credit_limit > 0
ORDER BY utilization_pct DESC
LIMIT 10;
-- Finding: The highest utilization is 79.6% (CARD000583); no card is above 80%.

-- Q2: Utilization summary
SELECT COUNT(*) AS credit_cards,
       ROUND(SUM(outstanding_balance)*100/SUM(credit_limit),1) AS overall_utilization_pct,
       SUM(outstanding_balance*100/credit_limit > 50) AS cards_above_50pct
FROM cards
WHERE credit_limit > 0;
-- Finding: 242 credit cards, overall utilization 41.8%, and 90 cards (37.2%) are above 50%.
-- Insight: Customers use a healthy share of their credit, with no card maxed out.
-- Recommendation: Review limit increases for good payers and watch the 90 cards above 50%.

-- Q4: Reward points leaders
SELECT card_id, account_id, card_type, reward_points, is_active
FROM cards
ORDER BY reward_points DESC
LIMIT 10;
-- Finding: The top 10 cards hold about 49,000-50,000 points each, and all 10 are inactive.
-- Insight: The largest reward balances sit on inactive cards, a possible liability and a reactivation hook.
-- Recommendation: Contact these customers with a points-redemption or reactivation offer.

-- Q5: Expired cards (uses the "today" rule)
SELECT COUNT(*) AS expired_cards
FROM cards
WHERE expiry_date < (SELECT MAX(transaction_date) FROM transactions);
-- Finding: 445 of 600 cards (74.2%) have expired.
-- Insight: Most cards lapsed and were not renewed, which partly explains the low active rate.
-- Recommendation: Automate renewal before expiry.

-- Q5: Active cards that have already expired
SELECT card_id, expiry_date, is_active
FROM cards
WHERE is_active = 'Yes'
  AND expiry_date < (SELECT MAX(transaction_date) FROM transactions);
-- Finding: 0 rows. 118 inactive cards have not yet expired, and 176 cards sit on closed accounts.
-- Insight: Status controls work for expiry. The 118 unexpired inactive cards are the easiest targets.
-- Recommendation: Target the 118 unexpired inactive cards first.

-- Q6: Cards per customer
SELECT c.customer_id, c.first_name, c.last_name, COUNT(cd.card_id) AS cards
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN cards cd   ON a.account_id  = cd.account_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY cards DESC
LIMIT 10;
-- Finding: Anna Jones (C000226) holds 12 cards and Pooja Garcia (C000146) 11. 267 customers hold cards.
-- Insight: Card ownership is concentrated in engaged customers.
-- Recommendation: Offer these customers premium or consolidated card products.

-- Q7: Product mix per customer
SELECT c.customer_id, c.segment,
       COUNT(DISTINCT a.account_id) AS accounts,
       COUNT(DISTINCT cd.card_id)   AS cards,
       COUNT(DISTINCT l.loan_id)    AS loans
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN cards cd   ON a.account_id  = cd.account_id
LEFT JOIN loans l    ON c.customer_id = l.customer_id
GROUP BY c.customer_id, c.segment;
-- Finding: 124 customers hold all three products, 60 hold a loan only and 74 hold nothing.

-- Q7: How many customers use 0, 1, 2 or 3 product types
SELECT product_types, COUNT(*) AS customers
FROM (
  SELECT c.customer_id,
         (COUNT(DISTINCT a.account_id) > 0)
       + (COUNT(DISTINCT cd.card_id)   > 0)
       + (COUNT(DISTINCT l.loan_id)    > 0) AS product_types
  FROM customers c
  LEFT JOIN accounts a ON c.customer_id = a.customer_id
  LEFT JOIN cards cd   ON a.account_id  = cd.account_id
  LEFT JOIN loans l    ON c.customer_id = l.customer_id
  GROUP BY c.customer_id
) t
GROUP BY product_types
ORDER BY product_types;
-- Finding: 0 products: 74 (14.8%); 1: 110 (22.0%); 2: 192 (38.4%); 3: 124 (24.8%). 99 account holders
--          have no card.
-- Insight: 63% use two or more products, but 60 borrowers do not bank with the bank.
-- Recommendation: Offer accounts to loan-only borrowers, issue cards to the 99 account holders without
--          one, and re-engage the 74 customers with no products.

-- Q7: Average number of products by segment
SELECT segment, ROUND(AVG(product_types),2) AS avg_products
FROM (
  SELECT c.customer_id, c.segment,
         (COUNT(DISTINCT a.account_id) > 0)
       + (COUNT(DISTINCT cd.card_id)   > 0)
       + (COUNT(DISTINCT l.loan_id)    > 0) AS product_types
  FROM customers c
  LEFT JOIN accounts a ON c.customer_id = a.customer_id
  LEFT JOIN cards cd   ON a.account_id  = cd.account_id
  LEFT JOIN loans l    ON c.customer_id = l.customer_id
  GROUP BY c.customer_id, c.segment
) t
GROUP BY segment
ORDER BY avg_products DESC;
-- Finding: Senior 1.93 ... Premium 1.55 (lowest).
-- Insight: Premium customers use the fewest products, the opposite of what a premium segment should show.
-- Recommendation: Design a premium bundle (account + card + loan benefits).

-- 4.5 Conclusion: 93.8% of cards are inactive and 74% have expired, though credit utilization is healthy
--   (41.8%). Cross-sell opportunity is large.
