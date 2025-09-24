-- Customers Table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(15),
    address VARCHAR(255),
    date_of_birth DATE,
    registration_date DATE
);

-- Branches Table
CREATE TABLE Branches (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100),
    address VARCHAR(255),
    city VARCHAR(50),
    manager_name VARCHAR(100)
);

-- Accounts Table
CREATE TABLE Accounts (
    account_id INT PRIMARY KEY,
    customer_id INT REFERENCES Customers(customer_id),
    account_type VARCHAR(20),
    balance NUMERIC(15,2),
    created_date DATE,
    status VARCHAR(20)
);

-- Transactions Table
CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT REFERENCES Accounts(account_id),
    transaction_type VARCHAR(20),
    amount NUMERIC(15,2),
    transaction_date TIMESTAMP,
    method VARCHAR(50)
);

-- Loans Table
CREATE TABLE Loans (
    loan_id INT PRIMARY KEY,
    account_id INT REFERENCES Accounts(account_id),
    loan_type VARCHAR(50),
    loan_amount NUMERIC(15,2),
    interest_rate NUMERIC(5,2),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20)
);

-- Indexing for Faster Queries
CREATE INDEX idx_account_customer ON Accounts(customer_id);
CREATE INDEX idx_transaction_account ON Transactions(account_id);
CREATE INDEX idx_loan_account ON Loans(account_id);

-- Basic Queries
-- 1. List all customers with their full name, email, and phone number
SELECT first_name || ' ' || last_name AS full_name, email, phone
FROM Customers;

-- 2. Show all active accounts with their type and balance.
SELECT account_id, account_type, balance
FROM Accounts
WHERE status = 'Active';

-- 3. Find all transactions above ₹50,000.
SELECT transaction_id, account_id, transaction_type, amount
FROM Transactions
WHERE amount > 50000
ORDER BY amount DESC;

-- 4. List all active loans with their account ID and loan amount.
SELECT loan_id, account_id, loan_amount, loan_type, status
FROM Loans
WHERE status = 'Active';

-- 5. Show all branches in the city ‘Mumbai’.
SELECT branch_id, branch_name, address
FROM Branches
WHERE city = 'Mumbai';

-- Intermediate Queries
-- 1. Calculate the total balance per customer.
SELECT c.customer_id, c.first_name || ' ' || c.last_name AS full_name,
       SUM(a.balance) AS total_balance
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, full_name
ORDER BY total_balance DESC;

-- 2. Find customers with more than 2 accounts.
SELECT c.customer_id, c.first_name || ' ' || c.last_name AS full_name,
       COUNT(a.account_id) AS num_accounts
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, full_name
HAVING COUNT(a.account_id) > 2;

-- 3. Show transactions per account in the last 30 days.
SELECT account_id, COUNT(transaction_id) AS transaction_count,
       SUM(amount) AS total_amount
FROM Transactions
WHERE transaction_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY account_id
ORDER BY total_amount DESC;

-- 4. Identify customers who have both a loan and a savings account.
SELECT DISTINCT c.customer_id, c.first_name || ' ' || c.last_name AS full_name
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id
JOIN Loans l ON a.account_id = l.account_id
WHERE a.account_type = 'Savings';

-- 5. Find the average loan amount per loan type.
SELECT loan_type, ROUND(AVG(loan_amount), 2) AS avg_loan_amount
FROM Loans
GROUP BY loan_type;

-- Advanced Queries
-- 1. Find the top 5 customers with the highest total balance.
SELECT c.customer_id, c.first_name || ' ' || c.last_name AS full_name,
       SUM(a.balance) AS total_balance
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, full_name
ORDER BY total_balance DESC
LIMIT 5;

-- 2. Detect accounts with no activity in the last 6 months.
SELECT a.account_id, c.first_name || ' ' || c.last_name AS full_name
FROM Accounts a
JOIN Customers c ON a.customer_id = c.customer_id
WHERE a.account_id NOT IN (
    SELECT DISTINCT account_id
    FROM Transactions
    WHERE transaction_date >= CURRENT_DATE - INTERVAL '6 months'
);


-- 3. Calculate monthly revenue from interest on active loans 
-- (assuming simple interest for demonstration).
SELECT DATE_TRUNC('month', start_date) AS month,
       ROUND(SUM(loan_amount * interest_rate / 100 / 12),2) AS estimated_monthly_interest
FROM Loans
WHERE status = 'Active'
GROUP BY month
ORDER BY month;

-- 4. Generate a summary of deposits vs withdrawals per branch.
SELECT b.branch_name,
       SUM(CASE WHEN t.transaction_type = 'Deposit' THEN t.amount ELSE 0 END) AS total_deposits,
       SUM(CASE WHEN t.transaction_type = 'Withdrawal' THEN t.amount ELSE 0 END) AS total_withdrawals
FROM Branches b
JOIN Accounts a ON a.customer_id IN (SELECT customer_id FROM Customers) -- simplified mapping
JOIN Transactions t ON t.account_id = a.account_id
GROUP BY b.branch_name
ORDER BY total_deposits DESC;

-- 5. Identify customers who frequently overdraw (negative balance).
SELECT c.customer_id, c.first_name || ' ' || c.last_name AS full_name, COUNT(*) AS overdraft_count
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id
WHERE a.balance < 0
GROUP BY c.customer_id, full_name
HAVING COUNT(*) >= 1
ORDER BY overdraft_count DESC;

-- Advanced Features
-- Views
-- Customer Summary View: total balance, number of accounts, active loans per customer
CREATE OR REPLACE VIEW customer_summary AS
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name AS full_name,
       COUNT(a.account_id) AS total_accounts,
       SUM(a.balance) AS total_balance,
       COUNT(l.loan_id) FILTER (WHERE l.status='Active') AS active_loans
FROM Customers c
LEFT JOIN Accounts a ON c.customer_id = a.customer_id
LEFT JOIN Loans l ON a.account_id = l.account_id
GROUP BY c.customer_id, full_name;

SELECT * FROM customer_summary ORDER BY total_balance DESC;

-- Trigger: Auto-update account balance after transaction
CREATE OR REPLACE FUNCTION update_account_balance()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.transaction_type = 'Deposit' THEN
        UPDATE Accounts
        SET balance = balance + NEW.amount
        WHERE account_id = NEW.account_id;
    ELSIF NEW.transaction_type = 'Withdrawal' THEN
        UPDATE Accounts
        SET balance = balance - NEW.amount
        WHERE account_id = NEW.account_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_balance
AFTER INSERT ON Transactions
FOR EACH ROW
EXECUTE FUNCTION update_account_balance();

-- Stored Procedure: Generate monthly statement for a customer.
CREATE OR REPLACE FUNCTION generate_monthly_statement(p_customer_id INT, p_month DATE)
RETURNS TABLE(
    transaction_id INT,
    account_id INT,
    transaction_type VARCHAR,
    amount NUMERIC,
    transaction_date TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.transaction_id, t.account_id, t.transaction_type, t.amount, t.transaction_date
    FROM Transactions t
    JOIN Accounts a ON t.account_id = a.account_id
    WHERE a.customer_id = p_customer_id
      AND DATE_TRUNC('month', t.transaction_date) = DATE_TRUNC('month', p_month)
    ORDER BY t.transaction_date;
END;
$$ LANGUAGE plpgsql;

