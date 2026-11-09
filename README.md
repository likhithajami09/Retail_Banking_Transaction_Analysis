# Retail Banking Transaction Analysis (MySQL)

A MySQL business analytics project: I designed a 7-table retail banking database from an ER diagram and used SQL to analyse customers, accounts, transactions, loans and cards, then turned the results into business recommendations.

**Project presentation (Google Slides):** [PASTE GOOGLE SLIDES LINK HERE]
**Video walkthrough (LinkedIn):** [PASTE LINKEDIN POST LINK HERE]

## Team
Likhitha Jami, Vyshnavi Mulle, Naina Patel Yadav

## Business questions
1. Who are our customers, and how do segments differ?
2. How are accounts used and how do branches perform?
3. How does money move through transactions and channels?
4. Are loans being repaid on time?
5. Are customers using their cards and other products?

## Dataset (7 tables)
| Table | Rows |
|---|---|
| customers | 500 |
| accounts | 700 |
| branches | 40 |
| loans | 300 |
| loan_payments | 2,000 |
| cards | 600 |
| transactions | 5,000 |

## Repository structure
| File | What it contains |
|---|---|
| `1.database_setup.sql` | Creates the database and all 7 tables with keys and constraints |
| `2.data_verification.sql` | Staging load (NULLIF for blank dates), row counts and category checks |
| `3.Basic_Analysis.sql` | 10 exploration queries |
| `4.1_Customer_Profile_and_Segmentation.sql` | Objective 1 |
| `4.2_Account_Usage_and_Branch_Activity.sql` | Objective 2 |
| `4.3_Transaction_Patterns.sql` | Objective 3 |
| `4.4_Loan_Performance_and_Repayment.sql` | Objective 4 |
| `4.5_Card_Usage_and_Product_Engagement.sql` | Objective 5 |
| `5.Data_Quality_and_Final_Conclusions.md` | Data quality notes and final recommendations |
| `Retail_Banking_Project_PPT.pptx` | Project presentation |
| `Retail_Banking_Transaction_Analysis_Documentation.docx` | Full project documentation |

## How to run
1. Run `1.database_setup.sql` in MySQL Workbench.
2. Import the CSV files into the tables, then run `2.data_verification.sql`.
3. Run the analysis files in order (3, then 4.1 to 4.5). Each query has its Finding, Insight and Recommendation in the comments.

Note: time-based logic treats the latest transaction date (2025-02-22) as "today".

## Skills used
SQL, MySQL, Database Design, ER Diagrams, Joins, Aggregations, Subqueries, CASE Expressions, Data Analysis, Business Insights

## Key findings
- Only 28.6% of customers are fully KYC-verified
- Only 33.8% of transactions complete
- 56.3% of loans are Defaulted or In Arrears
- 93.8% of cards are inactive
