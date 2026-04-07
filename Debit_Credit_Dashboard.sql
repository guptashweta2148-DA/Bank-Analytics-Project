create database debit_credit;

#SHOW VARIABLES LIKE "secure_file_priv";
-- 1. Create and use the database
CREATE DATABASE IF NOT EXISTS DebitAndCredit;
USE DebitAndCredit;

DROP TABLE IF EXISTS transactions;
-- 2. Create the table
DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
    Customer_ID VARCHAR(100),
    Customer_Name VARCHAR(100),
    Account_Number VARCHAR(50),
    Transaction_Date DATE,
    Transaction_Type VARCHAR(20),
    Amount DOUBLE,
    Balance DOUBLE,
    Description VARCHAR(255),
    Branch VARCHAR(100),
    Transaction_Method VARCHAR(100),
    Currency VARCHAR(10),
    Bank_Name VARCHAR(100)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Debit_Credit.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;




USE DebitAndCredit;

SELECT 
    SUM(Amount) AS Total_Credit_Amount
FROM transactions
WHERE Transaction_Type = 'Credit';

USE DebitAndCredit;

-- KPI's
-- 1-Total Credit Amount:

SELECT 
    CONCAT(ROUND(SUM(Amount) / 1000000, 2), 'M') AS Total_Credit_Amount
FROM transactions
WHERE Transaction_Type = 'Credit';

-- 2-Total Debit Amount:

SELECT 
    CONCAT(ROUND(SUM(Amount) / 1000000, 2), 'M') AS Total_Debit_Amount
FROM transactions
WHERE Transaction_Type = 'Debit';

-- 3-Credit to Debit Ratio:

SELECT 
    ROUND(
        (SELECT SUM(Amount) FROM transactions WHERE Transaction_Type = 'Credit') / 
        (SELECT SUM(Amount) FROM transactions WHERE Transaction_Type = 'Debit'), 
    6) AS Credit_to_Debit_Ratio;
    
-- 4-Net Transaction Amount:

SELECT 
    CONCAT(
        ROUND(
            (SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END) - 
             SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END)) 
        / 1000000, 2), 
    'M') AS Net_Transaction_Amount_Millions
FROM transactions;

-- 5-Account Activity Ratio:

SELECT 
    ROUND(COUNT(*) / SUM(Balance), 6) AS Account_Activity_Ratio
FROM transactions;

-- 6-Transactions per Day/Week/Month:

### Transactions per Day

SELECT 
    Transaction_Date, 
    COUNT(*) AS Transaction_Count
FROM transactions
GROUP BY Transaction_Date
ORDER BY Transaction_Date;

### Transactions per Week

SELECT 
    YEAR(Transaction_Date) AS Year, 
    WEEK(Transaction_Date) AS Week_Number, 
    COUNT(*) AS Transaction_Count
FROM transactions
GROUP BY Year, Week_Number
ORDER BY Year, Week_Number;

### Transactions per Month

SELECT 
    DATE_FORMAT(Transaction_Date, '%Y-%m') AS Month, 
    COUNT(*) AS Transaction_Count
FROM transactions
GROUP BY Month
ORDER BY Month;

-- 7-Total Transaction Amount by Branch

SELECT 
    Branch, 
    CONCAT(ROUND(SUM(Amount) / 1000000, 2), 'M') AS Total_Amount_Millions
FROM transactions
GROUP BY Branch
ORDER BY SUM(Amount) DESC;