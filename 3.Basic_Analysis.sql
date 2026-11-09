USE retail_banking;

-- =====================================================================
-- SPRINT 3: BASIC ANALYSIS / DATA EXPLORATION
-- =====================================================================

-- 1. Total customers
SELECT COUNT(*) AS total_customers FROM customers;
-- Result: 500 customers.

-- 2. Total accounts
SELECT COUNT(*) AS total_accounts FROM accounts;
-- Result: 700 accounts (1.4 accounts per customer on average).

-- 3. Account types available
SELECT DISTINCT account_type FROM accounts;
-- Result: 6 types: Business Checking, Certificate of Deposit, Checking, IRA, Money Market, Savings.

-- 4. Active customers
SELECT COUNT(*) AS active_customers FROM customers WHERE is_active = 'Yes';
-- Result: 375 of 500 customers are active (75.0%).

-- 5. Transaction types available
SELECT DISTINCT transaction_type FROM transactions;
-- Result: 6 types: ATM Withdrawal, Credit, Debit, Fee, Interest, Transfer.

-- 6. Total amount of completed transactions
SELECT SUM(amount) AS total_completed_amount
FROM transactions WHERE status = 'Completed';
-- Result: $10,976,552.36 across 1,688 completed transactions.

-- 7. Loan types available
SELECT DISTINCT loan_type FROM loans;
-- Result: 6 types: Auto, Business, Credit Builder, Education, Home, Personal.

-- 8. Total number of loans
SELECT COUNT(*) AS total_loans FROM loans;
-- Result: 300 loans.

-- 9. Card types available
SELECT DISTINCT card_type FROM cards;
-- Result: 2 types: Credit, Debit.

-- 10. Total outstanding loan balance
SELECT SUM(outstanding_balance) AS total_outstanding FROM loans;
-- Result: $53,441,891.25 is still owed (74.0% of the $72.21M originally lent).
