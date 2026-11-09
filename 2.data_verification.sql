USE retail_banking;

-- =====================================================================
-- SPRINT 2 (continued): DATA LOADING AND VERIFICATION
-- Data is imported from CSV files (MySQL Workbench > Table Data Import Wizard).
-- Order: branches, customers, accounts, loans, cards, transactions, loan_payments.
-- =====================================================================

-- Accounts are loaded through a staging table because close_date is blank
-- for open accounts. Blank text cannot go into a DATE column, so NULLIF()
-- converts '' to NULL on the way in.
CREATE TABLE accounts_staging (
    account_id      VARCHAR(20),
    customer_id     VARCHAR(20),
    branch_id       VARCHAR(10),
    account_type    VARCHAR(30),
    open_date       VARCHAR(20),
    close_date      VARCHAR(20),
    current_balance VARCHAR(30),
    interest_rate   VARCHAR(10),
    overdraft_limit VARCHAR(30),
    status          VARCHAR(20)
);

-- (import accounts.csv into accounts_staging first)
SELECT COUNT(*) FROM accounts_staging;   -- should be 700

INSERT INTO accounts
  (account_id, customer_id, branch_id, account_type, open_date, close_date,
   current_balance, interest_rate, overdraft_limit, status)
SELECT account_id, customer_id, branch_id, account_type,
       NULLIF(open_date,''),
       NULLIF(close_date,''),
       NULLIF(current_balance,''),
       NULLIF(interest_rate,''),
       NULLIF(overdraft_limit,''),
       status
FROM accounts_staging;

-- Staging vs final table check
SELECT COUNT(*) AS in_accounts FROM accounts;
SELECT COUNT(*) AS in_staging  FROM accounts_staging;
SELECT COUNT(DISTINCT account_id) AS unique_ids_in_staging FROM accounts_staging;

-- Row count check for all 7 tables
SELECT 'customers' AS tbl, COUNT(*) AS rows_loaded FROM customers
UNION ALL SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL SELECT 'branches', COUNT(*) FROM branches
UNION ALL SELECT 'loans', COUNT(*) FROM loans
UNION ALL SELECT 'loan_payments', COUNT(*) FROM loan_payments
UNION ALL SELECT 'cards', COUNT(*) FROM cards
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions;
-- Expected: customers 500, accounts 700, branches 40, loans 300,
--           loan_payments 2000, cards 600, transactions 5000

-- Check the category values in key columns
SELECT DISTINCT is_active FROM customers;
SELECT DISTINCT status FROM transactions;
SELECT DISTINCT loan_status FROM loans;
SELECT DISTINCT status FROM accounts;

-- Data quality notes found during verification:
-- 1. close_date is blank for the 497 open accounts (handled with NULLIF).
-- 2. All 7 files passed key checks: no duplicate primary keys, no orphan foreign keys.
-- 3. 13 of 40 branches share a name, so branch analysis groups by branch_id.
