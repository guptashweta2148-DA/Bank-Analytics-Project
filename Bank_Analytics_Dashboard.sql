CREATE DATABASE IF NOT EXISTS BankProject;
USE BankProject;

USE BankProject;

DROP TABLE IF EXISTS bank_loans;
CREATE TABLE bank_loans (
    State_Abbr_1 VARCHAR(100), Account_ID VARCHAR(100), Age_Range VARCHAR(100), 
    BH_Name VARCHAR(255), Bank_Name VARCHAR(255), Branch_Name VARCHAR(255), 
    Caste VARCHAR(100), Center_Id VARCHAR(100), City VARCHAR(255), Client_Id VARCHAR(100), 
    Client_Name VARCHAR(255), Close_Client VARCHAR(100), Closed_Date VARCHAR(100), 
    Officer_Name VARCHAR(255), DOB VARCHAR(100), Disb_By VARCHAR(255), 
    Disb_Date VARCHAR(100), Disb_Year VARCHAR(100), Gender VARCHAR(100), 
    Home_Ownership VARCHAR(100), Loan_Status VARCHAR(100), Loan_Transfer_Date VARCHAR(100), 
    Next_Meeting_Date VARCHAR(100), Product_Code VARCHAR(100), Grade VARCHAR(100), 
    Sub_Grade VARCHAR(100), Product_Id VARCHAR(100), Purpose VARCHAR(255), 
    Region VARCHAR(255), Religion VARCHAR(100), Verification_Status VARCHAR(100), 
    State_Abbr_2 VARCHAR(100), State_Name VARCHAR(255), Transfer_Logic VARCHAR(255), 
    Is_Delinquent VARCHAR(100), Is_Default VARCHAR(100), Age_Num VARCHAR(100), 
    Delinq_2yrs VARCHAR(100), App_Type VARCHAR(100), Loan_Amount VARCHAR(100), 
    Funded_Amount VARCHAR(100), Funded_Amount_Inv VARCHAR(100), Term VARCHAR(100), 
    Int_Rate VARCHAR(100), Total_Pymnt VARCHAR(100), Total_Pymnt_Inv VARCHAR(100), 
    Total_Rec_Prncp VARCHAR(100), Total_Fees VARCHAR(100), Total_Rec_Int VARCHAR(100), 
    Total_Rec_Late_Fee VARCHAR(100), Recoveries VARCHAR(100), Collection_Fee VARCHAR(100)
);

ALTER TABLE bank_loans 
MODIFY COLUMN Transfer_Logic VARCHAR(100),
MODIFY COLUMN Is_Delinquent VARCHAR(100),
MODIFY COLUMN Is_Default VARCHAR(100),
MODIFY COLUMN State_Abbr_1 VARCHAR(50),
MODIFY COLUMN State_Abbr_2 VARCHAR(50);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Bank_Data.csv'
INTO TABLE bank_loans
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- KPI's

-- 1. Total Loan Amount Funded
SELECT 
    CONCAT(ROUND(SUM(CAST(Loan_Amount AS DECIMAL(15,2))) / 1000000000, 3), 'B') AS Total_Funded_Amount
FROM bank_loans;


-- 2. Total Loans
SELECT 
    COUNT(Account_ID) AS Total_Loans
FROM bank_loans
WHERE Account_ID IS NOT NULL AND Account_ID != '';


-- 3. Total Collection (Total Amount Received)
SELECT 
    CONCAT(ROUND(SUM(CAST(Total_Pymnt AS DECIMAL(15,3))) / 1000000000, 2), 'B') AS Total_Collection
FROM bank_loans
WHERE Account_ID IS NOT NULL AND Account_ID != '';


-- 4. Total Interest
SELECT 
    CONCAT(ROUND(SUM(CAST(Total_Rec_Int AS DECIMAL(15,2))) / 1000000, 2), 'M') AS Total_Interest_Received
FROM bank_loans
WHERE Account_ID IS NOT NULL AND Account_ID != '';

-- 5. Branch-Wise (Interest, Fees, Total Revenue)
SELECT 
    Branch_Name,
    -- Sum of Interest
    CONCAT(ROUND(SUM(CAST(Total_Rec_Int AS DECIMAL(15,2))) / 1000000, 2), 'M') AS Interest_Income,
    -- Sum of Fees
    CONCAT(ROUND(SUM(CAST(Total_Fees AS DECIMAL(15,2))) / 1000000, 2), 'M') AS Fee_Income,
    -- Combined Revenue (Interest + Fees)
    CONCAT(ROUND(SUM(CAST(Total_Rec_Int AS DECIMAL(15,2)) + CAST(Total_Fees AS DECIMAL(15,2))) / 1000000, 2), 'M') AS Total_Revenue
FROM bank_loans
WHERE Account_ID IS NOT NULL AND Account_ID != ''
GROUP BY Branch_Name
ORDER BY SUM(CAST(Total_Rec_Int AS DECIMAL(15,2)) + CAST(Total_Fees AS DECIMAL(15,2))) DESC;

-- 6. State-Wise Loan Distribution
SELECT 
    State_Name, 
    COUNT(Account_ID) AS Total_Loan_Applications,
    CONCAT(ROUND(SUM(CAST(Loan_Amount AS DECIMAL(15,2))) / 1000000, 2), 'M') AS Total_Funded_Amount
FROM bank_loans
WHERE Account_ID IS NOT NULL AND Account_ID != ''
GROUP BY State_Name
ORDER BY SUM(CAST(Loan_Amount AS DECIMAL(15,2))) DESC;


-- 7. Religion-Wise Loan Distribution
SELECT 
    Religion, 
    COUNT(Account_ID) AS Total_Loan_Applications,
    CONCAT(ROUND(SUM(CAST(Loan_Amount AS DECIMAL(15,2))) / 1000000, 2), 'M') AS Total_Funded_Amount
FROM bank_loans
WHERE Account_ID IS NOT NULL AND Account_ID != ''
GROUP BY Religion
ORDER BY COUNT(Account_ID) DESC;

-- 8. Product Group-Wise Loan Distribution
SELECT 
    Purpose AS Product_Group, 
    COUNT(Account_ID) AS Total_Loan_Applications,
    CONCAT(ROUND(SUM(CAST(Loan_Amount AS DECIMAL(15,2))) / 1000000, 2), 'M') AS Total_Funded_Amount
FROM bank_loans
WHERE Account_ID IS NOT NULL AND Account_ID != ''
GROUP BY Purpose
ORDER BY SUM(CAST(Loan_Amount AS DECIMAL(15,2))) DESC;


-- 9. Yearly Disbursement Trend (using Fiscal Year column)
SELECT 
    Disb_Year AS Fiscal_Year, 
    COUNT(Account_ID) AS Total_Loans_Issued,
    CONCAT(ROUND(SUM(CAST(Loan_Amount AS DECIMAL(15,2))) / 1000000, 2), 'M') AS Total_Funded_Amount
FROM bank_loans
WHERE Account_ID != ''
GROUP BY Disb_Year
ORDER BY Disb_Year;


-- 10. Grade-Wise Loan Distribution
SELECT 
    Grade, 
    COUNT(Account_ID) AS Total_Loan_Applications,
    CONCAT(ROUND(SUM(CAST(Loan_Amount AS DECIMAL(15,2))) / 1000000, 2), 'M') AS Total_Funded_Amount
FROM bank_loans
WHERE Account_ID IS NOT NULL AND Account_ID != ''
GROUP BY Grade
ORDER BY Grade;

-- 11. Count of Default Loans
SELECT 
    COUNT(Account_ID) AS Total_Defaulted_Loans
FROM bank_loans
WHERE Is_Default = 'Y' 
  AND Account_ID IS NOT NULL 
  AND Account_ID != '';
  

-- 12. Count of Delinquent Clients
SELECT 
    COUNT(Account_ID) AS Total_Delinquent_Clients
FROM bank_loans
WHERE Is_Delinquent = 'Y' 
  AND Account_ID IS NOT NULL 
  AND Account_ID != '';
  

-- 13. Delinquent Loans Rate
SELECT 
    ROUND(
        (COUNT(CASE WHEN Is_Delinquent = 'Y' THEN 1 END) / COUNT(Account_ID)) * 100, 
    2) AS Delinquent_Loans_Percentage
FROM bank_loans
WHERE Account_ID IS NOT NULL AND Account_ID != '';

-- 14. Default Loan Rate
SELECT 
    ROUND(
        (COUNT(CASE WHEN Is_Default = 'Y' THEN 1 END) / COUNT(Account_ID)) * 100, 
    2) AS Default_Loan_Percentage
FROM bank_loans
WHERE Account_ID IS NOT NULL AND Account_ID != '';

-- 15. Loan Status-Wise Loan Distribution
SELECT 
    Loan_Status, 
    COUNT(Account_ID) AS Total_Loans,
    CONCAT(ROUND(SUM(CAST(Loan_Amount AS DECIMAL(15,2))) / 1000000, 2), 'M') AS Total_Funded_Amount,
    CONCAT(ROUND(SUM(CAST(Total_Pymnt AS DECIMAL(15,2))) / 1000000, 2), 'M') AS Total_Amount_Received
FROM bank_loans
WHERE Account_ID IS NOT NULL AND Account_ID != ''
GROUP BY Loan_Status
ORDER BY COUNT(Account_ID) DESC;


-- 16. Age Group-Wise Loan Distribution
SELECT 
    Age_Range, 
    COUNT(Account_ID) AS Total_Loan_Applications,
    CONCAT(ROUND(SUM(CAST(Loan_Amount AS DECIMAL(15,2))) / 1000000, 2), 'M') AS Total_Funded_Amount
FROM bank_loans
WHERE Account_ID IS NOT NULL AND Account_ID != ''
GROUP BY Age_Range
ORDER BY Age_Range;

-- 17. Loan Maturity (Term-Wise Distribution)
SELECT 
    Term AS Loan_Duration, 
    COUNT(Account_ID) AS Total_Loan_Applications,
    CONCAT(ROUND(SUM(CAST(Loan_Amount AS DECIMAL(15,2))) / 1000000, 2), 'M') AS Total_Funded_Amount,
    CONCAT(ROUND(SUM(CAST(Total_Pymnt AS DECIMAL(15,2))) / 1000000, 2), 'M') AS Total_Amount_Collected
FROM bank_loans
WHERE Account_ID IS NOT NULL AND Account_ID != ''
GROUP BY Term
ORDER BY Term;

-- 18. No Verified Loan Count
SELECT 
    COUNT(Account_ID) AS Total_Not_Verified_Loans,
    CONCAT(ROUND(SUM(CAST(Loan_Amount AS DECIMAL(15,2))) / 1000000, 2), 'M') AS Total_Funded_Amount
FROM bank_loans
WHERE Verification_Status = 'Not Verified' 
  AND Account_ID IS NOT NULL 
  AND Account_ID != '';