-- 1.Reviewing the data

SELECT * 
FROM layoffs_staging2;

SELECT MAX(total_laid_off),MAX(percentage_laid_off)
FROM layoffs_staging2;

-- 1.1 to see which company has completely shut down due to 100% layoff
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- 1.2 total layoffs based on companies
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- 1.3 start and end date
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- 1.4 to see which industry has the most company layoffs
SELECT industry, COUNT(company)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- 1.5 to see which industry has the most layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- 1.6 to see which company has the most laid off
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- 1.7 Which country has the most layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- 1.8 to see the layoffs based on year
SELECT YEAR(`date`) as `year`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- 1.9 to see the layoffs based on stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- 1.10 to see the total layoffs based on month & year
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- 1.11 rolling total layoffs month by month
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- 1.12 to see the rankings of total layoffs based on year by companies
WITH Company_Year (company,years,total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT * , 
DENSE_RANK() OVER ( PARTITION BY years ORDER BY total_laid_off DESC ) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
Select * 
FROM Company_Year_Rank
where Ranking<=5;




