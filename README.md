# 🏦 Bank CRM Churn Analysis | SQL + Power BI

This project dives deep into customer churn behavior at a bank using structured SQL analysis and interactive Power BI dashboards. It segments customers across demographics, engagement levels, and financial indicators to uncover churn risk and drive actionable retention strategies.

---

## 🎯 Objective

- Understand churn patterns in the bank's customer base  
- Segment customers based on key demographics and behavior  
- Identify risk indicators for churn  
- Recommend retention strategies and future modeling plans

---

## 🧰 Tools & Technologies

- **SQL (MySQL)**: Data extraction, joins, churn segmentation
- **Power BI**: Data cleaning, transformation, dashboards with filters/slicers
- **Excel**: Quick insights, visual validation

---

## 🗃️ Dataset Overview

- 📦 Total Customers: 10,000
- 🗂️ Tables Used:  
  - `Bank_Churn`  
  - `CustomerInfo`  
  - `Gender`, `Geography`, `CreditCard`, `ExitCustomer`, `ActiveCustomer`
- 🔑 Key Fields: Age, Tenure, Balance, CreditScore, NumOfProducts, EstimatedSalary, Activity status, Exited

---

## 🔄 Data Cleaning & Transformation (Power BI)

- Checked for null/missing values using Power Query
- Created new fields:
  - `AgeBucket`, `TenureBucket`, `ChurnRiskFlag`
- Replaced nulls with:
  - Median (numeric), Mode/"Unknown" (categorical)
- Conditional formatting for churn risk:  
  🔴 High | 🟡 Moderate | 🟢 Low

---

## 🧮 SQL Segmentation & Analysis

A series of queries were written to extract churn insights:

```sql
-- Churn rate by gender for latest year
SELECT g.GenderCategory, 
       COUNT(CASE WHEN bc.Exited = 1 THEN 1 END) * 100.0 / COUNT(*) AS Churn_Rate
FROM bank_churn bc
JOIN customerinfo ci ON ci.CustomerId = bc.CustomerId
JOIN gender g ON ci.GenderID = g.GenderID
GROUP BY g.GenderCategory;

-- Segment by credit score buckets
SELECT 
  CASE
    WHEN CreditScore < 600 THEN 'Low'
    WHEN CreditScore BETWEEN 600 AND 750 THEN 'Medium'
    ELSE 'High'
  END AS Credit_Segment,
  COUNT(*) AS Customers,
  SUM(Exited) AS Churned
FROM bank_churn
GROUP BY Credit_Segment;

## 📊 Dashboard Preview

<p align="center">
  <img src="https://raw.githubusercontent.com/Ayushi-S13/Bank-CRM-Churn-Analysis/main/churn_dashboard_screenshot.png" width="700" alt="Churn Dashboard"/>
</p>

Features include:
- Churn rate by demographics
- Region-wise churn map
- High-risk customer segmentation
- Filters for Age, Tenure, Product count, etc.

