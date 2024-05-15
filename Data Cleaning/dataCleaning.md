# A SQL Data Cleaning Project
---
This is done by liewwenyen@gmail.com


## Original Data
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


## Creating A Temporary Table
A temporary table is created where the data can be manipulated and restructured without altering the original table. 
```sql 
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;
```

## Removing Duplicates

```sql
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY
company,industry,total_laid_off,percentage_laid_off,"date")AS row_num
FROM layoffs_staging;
```
#### Result 
| company           | location      | industry      | total_laid_off | percentage_laid_off | date       | stage      | country       | funds_raised_millions   | row_num |
|-------------------|----------------|--------------|----------------|---------------------|------------|------------|---------------|-------------------------|---------|
| Casavo            | Milan          | Real Estate  |                | 0.3                 | 2/13/2023  | Unknown    | Italy         | 708                     | 1       |
| Cashfree Payments | Bengaluru      | Finance      | 100            |                     | 1/12/2023  | Series B   | India         | 41                      | 1       |
| Casper            | New York City  | Retail       |                |                     | 9/14/2021  | Post-IPO   | United States | 339                     | 1       |
| Casper            | New York City  | Retail       |                |                     | 9/14/2021  | Post-IPO   | United States | 339                     | 2       |

**Explanation** Using a windows function "row_number()" allows us to identify the records that has duplicates by showing a number more than 1. Here, in a section of the results generated, we can see that there is a duplicate by seeing the 2 in "row_num" column. 

### Selecting the Duplicates
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
As the duplicates cannot be directly deleted from the cte, so we have to use another method to remove it. we will create another table "layoffs_staging2" and insert the data from "layoffs_staging"

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
The above create statement can be found by right-clicking "layoff_staging", under "copy to clipboard, "create statement". 
This will result with a table that contains the row_num data. 

```sql 
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- to check 
SELECT *
FROM layoffs_staging2
WHERE row_num > 1; 
```
this is to delete the duplicates 

## Standardizing Data
There are some companies with a empty space in front of the data, this can be solved quickly by using the code below. 
```sql
UPDATE layoffs_staging2
SET company = TRIM(company);
```
### 2. Removing names of the same meaning
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

### 3. Removing "."
There was some records with a "." placed at the end of the data, this can be done by using the following code.  
```sql
SELECT DISTINCT country , TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
WHERE country LIKE "United States%";

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE "United States%";

```











`hi`
**bold**
*italic*
![Picture1](https://github.com/UpperCaseWenYen/Data-Cleaning-EDA-Project-/assets/156862479/eb202dc9-0117-4944-951e-e4991efe114a)
