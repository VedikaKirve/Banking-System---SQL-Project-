# Banking System SQL Project

## Project Overview
This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, query, and analyze Bank's Data. 
The project allows to manage bank accounts, record transactions, and analyze customer activity through SQL queries and CSV exports. 
It is designed to demonstrate database design, SQL query writing, and integration with real-world banking scenarios.
This project is ideal for learning:
- How to design and normalize relational databases.
- Writing SQL queries (easy → intermediate → advanced).
- Performing analytics on financial data.
- Preparing data for visualization (e.g., Power BI).

## Project Objective
Build a realistic banking system database to analyze customer behavior, account activity, loans, and branch performance using PostgreSQL to answer specific business questions and derive insights from the sales data.

## Business Questions
### Basic Queries:
1. List all customers with their email and phone number.
2. Show all accounts with account type and balance.
3. Find all transactions above ₹50,000.
4. List all active loans.
5. Show all branches in a specific city.

### Intermediate Queries:
1. Calculate total balance per customer.
2. Find customers with more than two accounts.
3. Show transactions per account in the last 30 days.
4. Identify customers who have both a loan and a savings account.
5. Find average loan amount per loan type.

### Advanced Queries:
1. Find the top 5 customers with the highest total balance.
2. Detect accounts with no activity for the last 6 months.
3. Calculate monthly revenue from interest on loans.
4. Generate a summary of deposits vs withdrawals per branch.
5. Identify customers who frequently overdraw (negative balance).

### Advanced Features:
- Views: Create views for customer summaries, branch-wise revenue, or loan status reports.
- Triggers: Implement triggers to update account balances automatically after a transaction.
- Stored Procedures: Develop stored procedures to generate monthly statements or calculate interest.
- Indexing: Apply indexing on frequently queried columns like account_id, customer_id, and transaction_date for performance optimization.

## Overall Business Insights:
- Balanced Product Mix → Savings, Current, and Loan accounts are nearly equal, indicating strong product diversification.
- Healthy Loan Portfolio → Loans are evenly spread across auto, personal, and home sectors, reducing credit risk concentration.
- Steady Deposits but Seasonal Withdrawals → Deposits are stable, withdrawals/transfers peak in certain months → bank should prepare liquidity buffers.
- High-Value Customer Dependency → A small group of customers hold large deposits → poses risk if they move funds elsewhere.
- Cross-Selling Opportunity → With customers already holding multiple accounts, targeting loans/insurance/wealth products is viable.

## Conclusion:
The bank shows:
- Strong customer engagement (10K transactions).
- Diverse loan and account base, reducing risk.
- Dependence on few high-value customers → requires loyalty programs.
- Seasonal transaction patterns → liquidity planning is key.

## Author
**Vedika Kirve**
This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!
Email: vedikakirve6@gmail.com  
LinkedIn: (www.linkedin.com/in/vedikakirve06)  
GitHub: [github.com/VedikaKirve](https://github.com/VedikaKirve)
