# Data Cleaning and Analysis Using MySQL

This repository contains SQL scripts for data cleaning, transformation, and exploratory data analysis (EDA). The dataset used pertains to company layoffs, and the goal is to standardize, clean, and extract meaningful insights.

---

## Table of Contents

1. [Data Cleaning](#data-cleaning)
    - Removing Duplicates
    - Standardizing Data
    - Dealing with NULL Values

2. [Exploratory Data Analysis (EDA)](#exploratory-data-analysis)
    - Summary Metrics
    - Trends and Aggregations

3. [Scripts Overview](#scripts-overview)
    - Step-by-Step Explanation
---

## Data Cleaning

### Removing Duplicates

- **Step 1**: Copy data from the original table `layoffs` to a temporary table `dup` for further processing.
  ```sql
  CREATE TABLE dup LIKE layoffs;
  INSERT dup SELECT * FROM layoffs;
  ```

- **Step 2**: Identify duplicates using `ROW_NUMBER`.
  ```sql
  SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions, percentage_laid_off ) AS row_num
  FROM dup;
  ```

- **Step 3**: Remove duplicate rows.
  ```sql
  DELETE FROM dup2 WHERE row_num > 1;
  ```

---

### Standardizing Data

- Trim spaces from `company` names:
  ```sql
  UPDATE dup2 SET company = TRIM(company);
  ```
- Standardize `industry` and `country` names:
  ```sql
  UPDATE dup2 SET industry = 'Crypto' WHERE industry LIKE 'crypto%';
  UPDATE dup2 SET country = 'United States' WHERE country LIKE 'united states%';
  ```
- Convert `date` column to `DATE` type:
  ```sql
  UPDATE dup2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
  ALTER TABLE dup2 MODIFY COLUMN `date` DATE;
  ```

---

### Dealing with NULL Values

- Identify rows with NULL or empty values:
  ```sql
  SELECT * FROM dup2 WHERE industry IS NULL OR industry = '';
  ```

- Fill missing `industry` values based on matching `company` names:
  ```sql
  UPDATE dup2 t1
  JOIN dup2 t2 ON t1.company = t2.company
  SET t1.industry = t2.industry
  WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL;
  ```

- Remove rows with irreparable NULL values:
  ```sql
  DELETE FROM dup2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
  ```

---

## Exploratory Data Analysis

### Summary Metrics

- Calculate maximum layoffs and percentage laid off:
  ```sql
  SELECT MAX(total_laid_off), MAX(percentage_laid_off) FROM dup2;
  ```

- Identify top companies by layoffs:
  ```sql
  SELECT company, SUM(total_laid_off) FROM dup2 GROUP BY company ORDER BY 2 DESC;
  ```

### Trends and Aggregations

- Analyze layoffs by year and month:
  ```sql
  SELECT YEAR(`date`), SUM(total_laid_off) FROM dup2 GROUP BY YEAR(`date`) ORDER BY 1 DESC;
  SELECT SUBSTR(`date`, 1, 7) AS `month`, SUM(total_laid_off) FROM dup2 GROUP BY `month`;
  ```

- Regional analysis:
  ```sql
  SELECT country, SUM(total_laid_off) FROM dup2 GROUP BY country ORDER BY 2 DESC;
  ```

- Industry analysis:
  ```sql
  SELECT industry, SUM(total_laid_off) FROM dup2 GROUP BY industry ORDER BY 2 DESC;
  ```

---

## Scripts Overview

Each step in the data cleaning and analysis pipeline is represented in the SQL scripts provided. The code addresses common challenges such as:
- Removing duplicates.
- Handling NULL values.
- Standardizing inconsistent data.
- Generating insights through aggregation and trends.

---

