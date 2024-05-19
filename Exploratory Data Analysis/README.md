# Performing EDA

## 1.to see which company has completely shut down due to 100% layoff

```sql
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
```
results:
| company             | location        | industry       |total_laid_off | percentage_laid_off | date         | stage          | country         | funds_raised_millions |
|---------------------|-----------------|----------------|---------------|---------------------|--------------|----------------|-----------------|-----------------------|
| Britishvolt         | London          | Transportation | 206           | 1                   | 2023-01-17   | Unknown        | United Kingdom  | 2400                  |
| Quibi               | Los Angeles     | Media          |               | 1                   | 2020-10-21   | Private Equity | United States   | 1800                  |
| Deliveroo Australia | Melbourne       | Food           | 120           | 1                   | 2022-11-15   | Post-IPO       | Australia       | 1700                  |
| Katerra             | SF Bay Area     | Construction   | 2434          | 1                   | 2021-06-01   | Unknown        | United States   | 1600                  |
| BlockFi             | New York City   | Crypto         |               | 1                   | 2022-11-28   | Series E       | United States   | 1000                  |


## 2.total layoffs based on companies
```sql
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
```

results:

| company     | total_layoffs_off |
|-------------|-------------------|
| Amazon      | 18150             |
| Google      | 12000             |
| Meta        | 11000             |
| Salesforce  | 10090             |
| Microsoft   | 10000             |

## 3.start and end date
```sql
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
```
results:

|MIN(`date`)| MAX(`date`)|
|-----------|------------|
|2020-03-11	|2023-03-06  |

## 4 to see which industry has the most company layoffs

```sql
SELECT industry, COUNT(company)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
```
results:
| industry       | COUNT(company)     |
|----------------|--------------------|
| Finance        | 239                |
| Healthcare     | 163                |
| Retail         | 163                |
| Transportation | 128                |
| Marketing      | 123                |

## 5 to see which industry has the most layoffs
```sql
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
```

results: 
| industry       |SUM(total_laid_off) |
|----------------|--------------------|
| Consumer       | 45182              |
| Retail         | 43613              |
| Other          | 36209              |
| Transportation | 33548              |
| Finance        | 28344              |


## 6 to see which company has the most laid off

```sql
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
```
results:

| company     | SUM(total_laid_off) |
|-------------|---------------------|
| Amazon      | 18150               |
| Google      | 12000               |
| Meta        | 11000               |
| Salesforce  | 10090               |
| Microsoft   | 10000               |

## Which country has the most layoffs

```sql
SELECT country, SUM(total_laid_off) as total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
```
results:
| country       | total_laid_off |
|---------------|----------------|
| United States | 256420         |
| India         | 35793          |
| Netherlands   | 17220          |
| Sweden        | 11264          |
| Brazil        | 10391          |

## 8 to see the layoffs based on year
```sql
SELECT YEAR(`date`) as `year`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
```
results:
| year | SUM(total_laid_off)  |
|------|----------------------|
| 2023 | 125677               |
| 2022 | 160322               |
| 2021 | 15823                |
| 2020 | 80998                |

## 9 to see the layoffs based on stage
```sql
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;
```
results:
| stage    | SUM(total_laid_off) |
|----------|----------------------|
| Post-IPO | 204073               |
| Unknown  | 40716                |
| Acquired | 27496                |
| Series C | 20017                |
| Series D | 19225                |

## 10 to see the total layoffs based on month & year
```sql
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;
```
results:
| month   | SUM(total_laid_off)  |
|---------|----------------------|
| 2020-03 | 9628                 |
| 2020-04 | 26710                |
| 2020-05 | 25804                |
| 2020-06 | 7627                 |
| 2020-07 | 7112                 |




