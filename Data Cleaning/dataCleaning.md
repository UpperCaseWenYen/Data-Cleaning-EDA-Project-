# A SQL Data Cleaning Project
by liewwenyen@gmail.com

## Creating A Temporary Table
A temporary table is created where the data can be manipulated and restructured without altering the original table. 

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

## Removing Duplicates
