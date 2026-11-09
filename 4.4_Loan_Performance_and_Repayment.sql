USE retail_banking;

-- =====================================================================
-- 4.4 EVALUATE LOAN PERFORMANCE AND REPAYMENT BEHAVIOUR
-- Business objective: understand how loans are performing and whether
-- customers repay as expected.
--
-- Analytical questions:
--  Q1. How many loans and how much money by type and purpose?
--  Q2. What share of principal is still outstanding?
--  Q3. How many loans are in each status?
--  Q4. How many payments are late, and what are the penalties?
--  Q5. Which loan types and branches have the worst repayment?
--  Q6. Which customers pay late most often?
--  Q7. Which payment methods are preferred, and which relate to delays?
--  Q8. Are there matured loans that still have a balance?
-- =====================================================================

-- Q1 + Q2: Loan type summary
SELECT loan_type, COUNT(*) AS loans,
       ROUND(SUM(principal_amount),2)    AS total_principal,
       ROUND(SUM(outstanding_balance),2) AS total_outstanding,
       ROUND(SUM(outstanding_balance)*100/SUM(principal_amount),1) AS pct_outstanding
FROM loans
GROUP BY loan_type;
-- Finding: Education is the largest (64 loans). Business has the highest outstanding share (80.9%).
--          Overall $53.44M of $72.21M (74.0%) is outstanding.
-- Insight: Three quarters of all money lent has not come back.
-- Recommendation: Review Business loan underwriting and monitor repayment progress by type.

-- Q1: Purpose breakdown
SELECT purpose, COUNT(*) AS loans, ROUND(AVG(principal_amount),2) AS avg_loan
FROM loans
GROUP BY purpose
ORDER BY loans DESC;
-- Finding: Education 64 loans, Business Expansion 52, Vehicle 48, Personal 48, Debt Consolidation 46,
--          Home Purchase 42 (largest average at $259,769).
-- Insight: Borrowing is spread across purposes, with Home Purchase carrying the largest tickets.
-- Recommendation: Tailor products to Education and Business Expansion.

-- Q3: Loan status
SELECT loan_status, COUNT(*) AS loans,
       ROUND(SUM(outstanding_balance),2) AS outstanding
FROM loans
GROUP BY loan_status;
-- Finding: Defaulted 86 ($18.60M), In Arrears 83 ($20.57M), Active 65, Closed 66. Defaulted plus In Arrears
--          = 169 loans (56.3%) holding 73.3% of all outstanding balances.
-- Insight: Most loans, and nearly three quarters of the money owed, are troubled.
-- Recommendation: Launch a collections and restructuring programme and review lending standards.

-- Loan status by loan type
SELECT loan_type,
       SUM(loan_status = 'Active')     AS active,
       SUM(loan_status = 'Closed')     AS closed,
       SUM(loan_status = 'In Arrears') AS in_arrears,
       SUM(loan_status = 'Defaulted')  AS defaulted,
       ROUND(SUM(loan_status IN ('Defaulted','In Arrears'))*100/COUNT(*),1) AS pct_troubled
FROM loans
GROUP BY loan_type
ORDER BY pct_troubled DESC;
-- Finding: Troubled share: Auto 62.5%, Home 59.5%, Credit Builder 57.1%, Business 55.8%, Education 53.1%,
--          Personal 51.1%.
-- Insight: Every loan type is above 50% troubled; Auto and Home are the worst.
-- Recommendation: Prioritise collections on Auto and Home and tighten Auto loan approval.

-- Q4: Late payments overall
SELECT COUNT(*) AS total_payments,
       SUM(days_late > 0) AS late_payments,
       ROUND(SUM(days_late > 0)*100/COUNT(*),1) AS pct_late,
       ROUND(SUM(penalty),2) AS total_penalty
FROM loan_payments;
-- Finding: 500 of 2,000 payments (25.0%) were late, by 22.5 days on average, generating $93,961.47 in
--          penalties. Counting Missed payments (468), 48.4% of payments are late or missed.
-- Recommendation: Send reminders before due dates and escalate quickly after the first missed payment.

-- Payment status
SELECT status, COUNT(*) AS payments FROM loan_payments GROUP BY status;
-- Finding: Paid 573 (28.7%), Late 500 (25.0%), Missed 468 (23.4%), Pending 459 (23.0%).
-- Insight: Fewer than 3 in 10 payments are made fully on time.
-- Recommendation: Track on-time payment rate as a core KPI.

-- Q5: Repayment behaviour by loan type
SELECT l.loan_type, COUNT(*) AS payments,
       ROUND(AVG(p.days_late),1) AS avg_days_late,
       ROUND(SUM(p.days_late > 0)*100/COUNT(*),1) AS pct_late,
       ROUND(SUM(p.status = 'Missed')*100/COUNT(*),1) AS pct_missed,
       ROUND(SUM(p.penalty),2)   AS total_penalty
FROM loans l
JOIN loan_payments p ON l.loan_id = p.loan_id
GROUP BY l.loan_type;
-- Finding: Late rate is highest for Home (28.2%) and Business (26.9%). Late or missed combined is
--          highest for Business (53.3%) and Auto (50.5%).
-- Insight: Business loans are the weakest on repayment behaviour.
-- Recommendation: Focus Business loan monitoring and early-contact processes.

-- Q5: Repayment behaviour by branch
SELECT b.branch_id, b.branch_name,
       COUNT(p.payment_id) AS payments,
       SUM(p.days_late > 0) AS late_payments,
       ROUND(SUM(p.days_late > 0)*100/COUNT(p.payment_id),1) AS pct_late,
       ROUND(SUM(p.penalty),2) AS total_penalty
FROM branches b
JOIN loans l         ON b.branch_id = l.branch_id
JOIN loan_payments p ON l.loan_id   = p.loan_id
GROUP BY b.branch_id, b.branch_name
ORDER BY late_payments DESC
LIMIT 10;
-- Finding: BR017 Omaha has the most late payments (28 of 76), then BR003 Anchorage and BR023 Washington
--          (26 each). By rate, BR012 Los Angeles (45.5%) and BR020 Colorado Springs (41.7%) are worst.
-- Insight: The worst branches have about twice the average late payments.
-- Recommendation: Review collection practices at the worst branches.

-- Q6: Customers with the most late payments
SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(*) AS late_payments, ROUND(SUM(p.penalty),2) AS penalties
FROM customers c
JOIN loans l         ON c.customer_id = l.customer_id
JOIN loan_payments p ON l.loan_id     = p.loan_id
WHERE p.days_late > 0
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY late_payments DESC
LIMIT 10;
-- Finding: Thomas Chen (C000446) has 9 late payments. 197 of the 233 customers with loans (84.5%) paid
--          late at least once; the top 10 account for just 14% of late payments.
-- Insight: Late payment is widespread, so fixing it needs process changes, not just targeting individuals.
-- Recommendation: Introduce automated reminders and flexible due dates, with outreach for repeat late payers.

-- Q7: Payment method preference
SELECT payment_method, COUNT(*) AS payments,
       ROUND(AVG(days_late),1) AS avg_days_late,
       ROUND(SUM(days_late > 0)*100/COUNT(*),1) AS pct_late
FROM loan_payments
GROUP BY payment_method
ORDER BY payments DESC;
-- Finding: Cheque is most used (19.4%); Auto Debit just 5.6%. Late rate is highest for Cash (28.3%) and
--          Cheque (26.3%), lowest for Auto Debit (19.6%).
-- Insight: Manual methods are least reliable, but Auto Debit adoption is very low.
-- Recommendation: Offer incentives to move borrowers to Auto Debit and align debit dates with salary dates.

-- Q8: Loans past maturity that still have a balance (uses the "today" rule)
SELECT loan_id, loan_type, maturity_date, outstanding_balance, loan_status
FROM loans
WHERE maturity_date < (SELECT MAX(transaction_date) FROM transactions)
  AND outstanding_balance > 0;
-- Finding: 31 loans are past maturity with $8,040,386.61 still owed (17 In Arrears, 14 Defaulted).
-- Insight: These are likely recovery or write-off candidates.
-- Recommendation: Escalate to recovery or restructuring and provision against losses.

-- 4.4 Conclusion: 56.3% of loans are Defaulted or In Arrears, holding 73.3% of the $53.4M outstanding.
--   Only 28.7% of payments are on time. Business and Auto loans are weakest and Auto Debit users repay best.
