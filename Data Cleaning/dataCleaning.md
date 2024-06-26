# A SQL Data Cleaning Project
---
An SQL exercise for practicing data cleaning by Liew Wen Yen liewwenyen@gmail.com
 
## Original Data
This is a snippet from the data. 
```sql
SELECT * 
FROM layoffs 
LIMIT 10;
```
#### Results:

| company         | location      | industry       | total_laid_off | percentage_laid_off | date       | stage      | country       | funds_raised_millions   |
|-----------------|---------------|----------------|----------------|---------------------|------------|------------|---------------|-------------------------|
| Atlassian       | Sydney        | Other          | 500            | 0.05                | 3/6/2023   | Post-IPO   | Australia     | 210                     |
| SiriusXM        | New York City | Media          | 475            | 0.08                | 3/6/2023   | Post-IPO   | United States | 525                     |
| Alerzo          | Ibadan        | Retail         | 400            |                     | 3/6/2023   | Series B   | Nigeria       | 16                      |
| UpGrad          | Mumbai        | Education      | 120            |                     | 3/6/2023   | Unknown    | India         | 631                     |
| Loft            | Sao Paulo     | Real Estate    | 340            | 0.15                | 3/3/2023   | Unknown    | Brazil        | 788                     |
| Embark Trucks   | SF Bay Area   | Transportation | 230            | 0.7                 | 3/3/2023   | Post-IPO   | United States | 317                     |
| Lendi           | Sydney        | Real Estate    | 100            |                     | 3/3/2023   | Unknown    | Australia     | 59                      |
| UserTesting     | SF Bay Area   | Marketing      | 63             |                     | 3/3/2023   | Acquired   | United States | 152                     |
| Airbnb          | SF Bay Area   |                | 30             |                     | 3/3/2023   | Post-IPO   | United States | 6400                    |
| Accolade        | Seattle       | Healthcare     |                |                     | 3/3/2023   | Post-IPO   | United States | 458                     |


## Creating A Staging Table
A staging table is a temporary table created where the data can be manipulated and restructured without altering the original/raw table. A staging table is used because there will be many changes made towards its, and if somehow there is a mistake made, we would still have the raw data available to revert back and refer to. This is a best practice. 
```sql 
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;
```

## 1.Removing Duplicates
*Mircosoft SQL Server actually is easier for removing duplicates as it would have another extra columns containing unique identifiers, allowing for easier removal of duplicates. THus, in mySQL, there is another method to remove duplicates*

Using a windows function "row_number()" allows us to identify the records that has duplicates by showing a number more than 1. Here, in a section of the results generated, we can see that there is a duplicate by seeing the 2 in "row_num" column. 
```sql
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY
company,industry,total_laid_off,percentage_laid_off,`date`)AS row_num
FROM layoffs_staging;
```
#### Result 
| company           | location      | industry      | total_laid_off | percentage_laid_off | date       | stage      | country       | funds_raised_millions   | row_num |
|-------------------|----------------|--------------|----------------|---------------------|------------|------------|---------------|-------------------------|---------|
| Casavo            | Milan          | Real Estate  |                | 0.3                 | 2/13/2023  | Unknown    | Italy         | 708                     | 1       |
| Cashfree Payments | Bengaluru      | Finance      | 100            |                     | 1/12/2023  | Series B   | India         | 41                      | 1       |
| Casper            | New York City  | Retail       |                |                     | 9/14/2021  | Post-IPO   | United States | 339                     | 1       |
| Casper            | New York City  | Retail       |                |                     | 9/14/2021  | Post-IPO   | United States | 339                     | 2       |


###  Selecting the Duplicates
Once we are able to properly use the windows function to identify the duplicates, we can use the code below to select only the duplicates
```sql
WITH duplicate_cte AS
(SELECT * ,
ROW_NUMBER() OVER(PARTITION BY
company,industry,total_laid_off,percentage_laid_off,"date")AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num>1;
```
#### Result
| company      | location      | industry      | total_laid_off | percentage_laid_off | date       | stage    | country       | funds_raised_millions   | row_num | 
|--------------|---------------|---------------|----------------|---------------------|------------|----------|---------------|-------------------------|---------|
| Akerna       | Denver        | Logistics     |                |                     | 9/2/2020   | Post-IPO | United States |                         | 2       |
| Better.com   | New York City | Real Estate   |                |                     | 4/19/2022  | Unknown  | United States | 905                     | 2       |
| Bytedance    | Shanghai      | Consumer      | 1800           |                     | 8/5/2021   | Unknown  | China         | 9400                    | 2       |
| Casper       | New York City | Retail        |                |                     | 9/14/2021  | Post-IPO | United States | 339                     | 2       |
| Cazoo        | London        | Transportation| 750            | 0.15                | 6/7/2022   | Post-IPO | United Kingdom| 2000                    | 2       |

### Delete the Duplicates
As the duplicates cannot be directly deleted from the cte, so we have to use another method to remove it. We will create another table "layoffs_staging2" and insert the data from "layoffs_staging" while also adding another column "row_num".

```sql
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int -- additional column
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO
layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY
company, location, industry,
total_laid_off, percentage_laid_off, "date",
stage, country, funds_raised_millions)AS row_num
FROM layoffs_staging;

```
*The above create statement can be found by right-clicking "layoff_staging", under "copy to clipboard, "create statement". 
This will result with a table that contains the row_num data.*

To delete the duplicates: 
```sql 
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- to check 
SELECT *
FROM layoffs_staging2
WHERE row_num > 1; 
```

## 2.Standardizing Data
Standardizing data means finding issues in the data and fixing it. 

### a. Removing Unwanted Spacing
There are some companies with a empty space in front of the data, this can be solved quickly by using the code below. 
```sql
UPDATE layoffs_staging2
SET company = TRIM(company);
```
### b. Removing Names of the Same Meaning
while reviewing the table, such as performing these queries: 
```sql
SELECT DISTINCT industry
FROM layoffs_staging2 
ORDER BY 1; -- order by first column
```
there were records that were using "Crypto" , "Crypto Currency", "CryptoCurrency". These should be categorized under the same name, else it would later pose problems during data visualization. 
```sql
UPDATE layoffs_staging2
SET industry = "Crypto"
WHERE industry LIKE "Crypto%";
```

### c. Removing "."
There was some records with a "." placed at the end of the data, this can be done by using the following code.  
```sql
SELECT DISTINCT country , TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
WHERE country LIKE "United States%";

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE "United States%";

```

### d. Changing the Format of "date" from Text to Date
During the import of data, the application register the data from "date" column as text, this will pose future issues when perform time series analysis. 

Before we make any changes, we will first use select to make sure we are using the right query. Then we will make the necessary changes based on the first query, and then later check again. 

```sql
-- to check if we are writing the right query
SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

-- make changes 
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- to check
SELECT `date`
FROM layoffs_staging2;

```

## Handling Null Values

### a. Start from identifying Null Values

```sql
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';
```
result:
# Layoffs Data

| company              | location       | industry   | total_laid_off | percentage_laid_off | date       | stage    | country       | funds_raised_millions   | row_num |
|----------------------|----------------|------------|----------------|---------------------|------------|----------|---------------|-------------------------|---------|
| Airbnb               | SF Bay Area    |            | 30             |                     | 2023-03-03 | Post-IPO | United States | 6400                    | 1       |
| Bally's Interactive  | Providence     |            |                | 0.15                | 2023-01-18 | Post-IPO | United States | 946                     | 1       |
| Carvana              | Phoenix        |            | 2500           | 0.12                | 2022-05-10 | Post-IPO | United States | 1600                    | 1       |
| Juul                 | SF Bay Area    |            | 400            | 0.3                 | 2022-11-10 | Unknown  | United States | 1500                    | 1       |

So we can try to populate the record by searching for the same company, as there might be multiple layoffs.
```sql
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';
```
result:
| company | location    | industry | total_laid_off | percentage_laid_off | date       | stage          | country       | funds_raised_millions   | row_num |
|---------|-------------|----------|----------------|---------------------|------------|----------------|---------------|-------------------------|---------|
| Airbnb  | SF Bay Area |          | 30             |                     | 2023-03-03 | Post-IPO       | United States | 6400                    | 1       |
| Airbnb  | SF Bay Area | Travel   | 1900           | 0.25                | 2020-05-05 | Private Equity | United States | 5400                    | 1       |

*Here we can see that there is also another record of the same company that contains a value for industry.*

so we will now write a query to join itself
```sql
-- select first
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
	AND t1.location = t2.location 
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- translate to update
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry 
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;
```
## 1.Delete Any Columns or Rows
When running the query to find records that are both null in "total_laid_off" and "percentage_laid_off", it seems that there are number of records that do not have any values in both these columns. When doing EDA later on, these records will not be of use. As such, these records will not serve any value, and will be deleted. 

```sql
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
'''





