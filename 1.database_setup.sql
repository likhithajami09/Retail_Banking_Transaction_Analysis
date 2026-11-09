-- =====================================================================
-- SPRINT 2: DATABASE SETUP
-- Creates the retail_banking database and its 7 tables (in dependency order)
-- =====================================================================
CREATE DATABASE IF NOT EXISTS retail_banking;
USE retail_banking;

CREATE TABLE branches (
    branch_id      VARCHAR(10) PRIMARY KEY,
    branch_name    VARCHAR(100) NOT NULL,
    city           VARCHAR(50),
    state          VARCHAR(30),
    region         VARCHAR(30),
    opening_date   DATE,
    employee_count INT DEFAULT 0
);

CREATE TABLE customers (
    customer_id    VARCHAR(20) PRIMARY KEY,
    first_name     VARCHAR(50) NOT NULL,
    last_name      VARCHAR(50),
    date_of_birth  DATE,
    gender         VARCHAR(20),
    city           VARCHAR(50),
    state          VARCHAR(30),
    customer_since DATE,
    kyc_status     VARCHAR(20),
    segment        VARCHAR(30),
    annual_income  DECIMAL(12,2),
    credit_score   INT,
    is_active      VARCHAR(3) DEFAULT 'Yes'
);

CREATE TABLE accounts (
    account_id      VARCHAR(20) PRIMARY KEY,
    customer_id     VARCHAR(20) NOT NULL,
    branch_id       VARCHAR(10) NOT NULL,
    account_type    VARCHAR(30) NOT NULL,
    open_date       DATE,
    close_date      DATE NULL,
    current_balance DECIMAL(15,2) DEFAULT 0,
    interest_rate   DECIMAL(5,2),
    overdraft_limit DECIMAL(12,2) DEFAULT 0,
    status          VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id)   REFERENCES branches(branch_id)
);

CREATE TABLE cards (
    card_id             VARCHAR(20) PRIMARY KEY,
    account_id          VARCHAR(20) NOT NULL,
    card_type           VARCHAR(20),
    issue_date          DATE,
    expiry_date         DATE,
    credit_limit        DECIMAL(12,2),
    outstanding_balance DECIMAL(12,2) DEFAULT 0,
    reward_points       INT DEFAULT 0,
    is_active           VARCHAR(3),
    network             VARCHAR(20),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

CREATE TABLE loans (
    loan_id             VARCHAR(20) PRIMARY KEY,
    customer_id         VARCHAR(20) NOT NULL,
    branch_id           VARCHAR(10) NOT NULL,
    loan_type           VARCHAR(30),
    principal_amount    DECIMAL(15,2),
    interest_rate       DECIMAL(5,2),
    tenure_months       INT,
    disbursement_date   DATE,
    maturity_date       DATE,
    emi_amount          DECIMAL(12,2),
    outstanding_balance DECIMAL(15,2),
    loan_status         VARCHAR(30),
    purpose             VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id)   REFERENCES branches(branch_id)
);

CREATE TABLE transactions (
    transaction_id   VARCHAR(20) PRIMARY KEY,
    account_id       VARCHAR(20) NOT NULL,
    transaction_date DATE,
    transaction_time TIME,
    transaction_type VARCHAR(30),
    amount           DECIMAL(15,2),
    channel          VARCHAR(30),
    description      VARCHAR(50),
    balance_after    DECIMAL(15,2),
    status           VARCHAR(20),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

CREATE TABLE loan_payments (
    payment_id       VARCHAR(20) PRIMARY KEY,
    loan_id          VARCHAR(20) NOT NULL,
    payment_date     DATE,
    scheduled_amount DECIMAL(12,2),
    paid_amount      DECIMAL(12,2),
    principal_paid   DECIMAL(12,2),
    interest_paid    DECIMAL(12,2),
    penalty          DECIMAL(12,2) DEFAULT 0,
    days_late        INT DEFAULT 0,
    payment_method   VARCHAR(30),
    status           VARCHAR(20),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);
