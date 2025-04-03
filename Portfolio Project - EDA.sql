-- SQL-код выполняет Exploratory Data Analysis (EDA) (разведочный анализ данных) на данных о массовых увольнениях 

SELECT * 
FROM world_layoffs.layoffs_staging2;

-- БОЛЕЕ ПРОСТЫЕ ЗАПРОСЫ

SELECT MAX(total_laid_off)
FROM world_layoffs.layoffs_staging2;






-- Посмотрите процент, чтобы увидеть, насколько масштабными были эти увольнения.

SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;

-- В каких компаниях было уволено 1, что по сути означает 100 процентов сотрудников компании?

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1;
--в основном это стартапы, которые все за это время обанкротились

-- если мы отсортируем по funcs_raised_millions, то увидим, насколько большими были некоторые из этих компаний
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;



-- Компании с крупнейшими единовременными увольнениями

SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging
ORDER BY 2 DESC
LIMIT 5;

-- и все это в одно время

-- Компании с наибольшим общим количеством увольнений

SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;



-- by location

SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

--  за последние 3 года 

SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(date), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 ASC;


SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;






-- Ранее мы рассматривали компании с наибольшим количеством увольнений. Теперь давайте посмотрим на это по годам. 

WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;




-- Общее количество увольнений за месяц

SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;

-- теперь используем его в CTE, чтобы мы могли делать из него запросы
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;



















































