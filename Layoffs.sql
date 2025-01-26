-- DATA CLEANING MYSQL

select *
from layoffs;

-- REMOVING DUPLICATES

create table dup
like layoffs;

select *
from dup;

insert dup
select *
from layoffs;

select *,
row_number() over(
PARTITION BY company, industry,`date`,percentage_laid_off ) as row_num
from dup;


with duplicate_cte as (
select *,
row_number() over(
PARTITION BY company, location,industry,total_laid_off,`date`,stage,country,funds_raised_millions,percentage_laid_off ) as row_num
from dup
)
select *
from duplicate_cte
where row_num=2;


select *
from dup
where company='yahoo';


CREATE TABLE `dup2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert dup2
select *,
row_number() over(
PARTITION BY company, location,industry,total_laid_off,`date`,stage,country,funds_raised_millions,percentage_laid_off ) as row_num
from dup;

select *
from dup2
where row_num>1;

set sql_safe_updates=0;

delete
from dup2
where row_num>1;

select *
from dup2;

-- STANDARDIZING THE DATA

select company,trim(company)
from dup2;

update dup2
set company=trim(company);

SELECT DISTINCT(INDUSTRY)
FROM DUP2
ORDER BY INDUSTRY;

SELECT *
FROM DUP2
WHERE INDUSTRY LIKE 'crypto%';

UPDATE dup2
set industry='Crypto'
where industry like 'crypto%';

SELECT DISTINCT(location)
from dup2
ORDER BY 1;

SELECT DISTINCT(country)
from dup2
order by 1;

update dup2
set country = 'United States'
WHERE country like 'united states%';

SELECT `date`,str_to_date(`date`,'%m/%d/%Y')
from dup2;

UPDATE dup2
set `date`= str_to_date(`date`,'%m/%d/%Y');

SELECT `date`
from dup2;

ALTER TABLE dup2
MODIFY COLUMN `date` DATE;

-- DEALING WITH NULL VALUES

SELECT *
FROM dup2
where total_laid_off is null and percentage_laid_off is null;

SELECT *
from dup2
WHERE industry is null or industry = '';

UPDATE dup2
set industry = null
where industry = '';

SELECT *
from dup2 t1
join dup2 t2
on t1.company=t2.company
	where (t1.industry is null or t1.industry = '') AND 
    t2.industry is not null;
     
UPDATE dup2 t1
join dup2 t2
on t1.company=t2.company
set t1.industry = t2.industry
where (t1.industry is null or t1.industry = '') AND 
    t2.industry is not null;
    
SELECT *
from dup2
WHERE industry is null or industry = '';

SELECT *
FROM dup2
where total_laid_off is null and percentage_laid_off is null;

DELETE
FROM dup2
where total_laid_off is null and percentage_laid_off is null;

SELECT *
from dup2;

ALTER TABLE dup2
DROP COLUMN row_num;

-- EXPLORATORY DATA ANALYSIS

SELECT *
 FROM dup2;
 
 SELECT MAX(total_laid_off),MAX(percentage_laid_off)
 FROM dup2;
 
 SELECT *
 FROM dup2
 where percentage_laid_off=1
 order by total_laid_off desc;
 
 SELECT company,SUM(total_laid_off)
 from dup2
 GROUP BY company
 order by 2 desc;
 
 SELECT MIN(`date`),MAX(`date`)
 from dup2;
 
  SELECT industry,SUM(total_laid_off)
 from dup2
 GROUP BY industry					
 order by 2 desc;
 
  SELECT country,SUM(total_laid_off)
 from dup2
 GROUP BY country
 order by 2 desc;
 
SELECT `date`,SUM(total_laid_off)
from dup2
GROUP BY `date`
order by 1 desc;

SELECT year(`date`),SUM(total_laid_off)
from dup2
GROUP BY year(`date`)
order by 1 desc;

SELECT stage,SUM(total_laid_off)
from dup2
GROUP BY stage
order by 2 desc;

SELECT substr(`date`,1,7) as `month`, SUM(total_laid_off)
FROM dup2
where substr(`date`,1,7) is not NULL
GROUP BY `month`
ORDER BY 1 ;

with cte AS 
(
SELECT substr(`date`,1,7) as `month`, SUM(total_laid_off) as total_off
FROM dup2
where substr(`date`,1,7) is not NULL
GROUP BY `month`
ORDER BY 1 
)
SELECT `month`,total_off,sum(total_off) over(order by `month`) 
FROM cte;

SELECT company,year(`date`), SUM(total_laid_off)
from dup2
group by company,year(`date`)
order by 3 desc;


with cte (company,years,total_laid_off) AS 
(
SELECT company,year(`date`), SUM(total_laid_off)
from dup2
group by company,year(`date`)
), cte2 as
(
SELECT *,DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) as ranks	
from cte
WHERE years is not NULL

)
SELECT *
FROM cte2
where ranks <=5
;
