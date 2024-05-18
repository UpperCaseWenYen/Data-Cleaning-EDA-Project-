-- Data Cleaning 

SELECT DISTINCT INDUSTRY
FROM layoffs 
LIMIT 1000;

-- 1. Remove Duplicates 
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any Columns 

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

truncate table layoffs_staging;

SELECT * ,
ROW_NUMBER() OVER(PARTITION BY
company,industry,total_laid_off,percentage_laid_off,"date")AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(SELECT * ,
ROW_NUMBER() OVER(PARTITION BY
company,industry,total_laid_off,percentage_laid_off,"date")AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num>1;

WITH duplicate_cte AS
(SELECT * ,
ROW_NUMBER() OVER(PARTITION BY
company, location, industry,
total_laid_off, percentage_laid_off, "date",
stage, country, funds_raised_millions)AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num>1;

SELECT * 
FROM layoffs_staging
WHERE company = "Casper";

WITH duplicate_cte AS
(SELECT * ,
ROW_NUMBER() OVER(PARTITION BY
company, location, industry,
total_laid_off, percentage_laid_off, "date",
stage, country, funds_raised_millions)AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num>1;

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

SELECT * 
FROM layoffs_staging2;

INSERT INTO
layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY
company, location, industry,
total_laid_off, percentage_laid_off, `date`,
stage, country, funds_raised_millions)AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- to check 
SELECT *
FROM layoffs_staging2
WHERE row_num > 1; 

-- Standardizing data

SELECT company , (TRIM(company))
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2 
ORDER BY 1; -- order by first column

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE "Crypto%";

UPDATE layoffs_staging2
SET industry = "Crypto"
WHERE industry LIKE "Crypto%";


SELECT DISTINCT country , TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
WHERE country LIKE "United States%";

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE "United States%";

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

-- 3. Null Values or blank values

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- select first
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- translate to update

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry 
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 




