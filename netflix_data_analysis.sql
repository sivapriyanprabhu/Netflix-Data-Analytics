DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix (
    show_id VARCHAR(10),
    type VARCHAR(20),
    title VARCHAR(255),
    director VARCHAR(255),
    `cast` TEXT,
    country VARCHAR(255),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(20),
    duration VARCHAR(50),
    listed_in VARCHAR(255),
    description TEXT
);
LOAD DATA LOCAL INFILE 'C:/Users/Admin/Downloads/archive (2)/netflix.csv'
INTO TABLE netflix
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

/*missing value*/

select count(*) as Total_Rows,
sum(director IS NULL OR director='') as missing_director,
sum(country IS NULL OR country='')as missing_country
from netflix;

/*removing blank value*/
update netflix
set director=NULL where director='';

/* Create Proper Date Column*/

ALTER TABLE netflix ADD COLUMN date_added_clean DATE;
update netflix set date_added_clean=str_to_date(date_added,'%M %d, %Y')
where date_added is not null and trim(date_added)<>'';

select count(date_added) from netflix where date_added='';

/*Total content*/

select count(*) from netflix;

/*Movies vs TV Shows*/

select type,count(*) as total_content,
round(count(*)*100/(select count(*) from netflix),2) as percentage
from netflix
group by type;

/*Top Content Producing Countries*/

update netflix set country=NULL where country='';

select country,count(*) as total_titles from netflix
 where country is not null 	
 group by country 
 order by total_titles desc
 LIMIT 10;

/*Netflix Growth Trend*/

select count(*) from netflix where date_added_clean is null;

select YEAR(date_added_clean) as year_added,count(*) as total_titles
from netflix 
where date_added_clean is not null
group by year_added
order by year_added;

/*Top Director Each Year*/

with top_director as(
select release_year,director,count(*) as total_titles,
row_number() over(partition by release_year order by count(*) desc) rn
from netflix 
where director is not null
group by release_year,director
)
select*from top_director where rn=1;

/*Fast Growing Year*/

with yearly_content as(
 select year(date_added_clean) as year_added,
 count(*) as total_titles
 from netflix
 group by year_added
 )
 select *,lag(total_titles) over(order by year_added) as previous_year,
 round((total_titles-lag(total_titles)over(order by year_added))*100.0/lag(total_titles)over(order by year_added),2) as growth_percent from yearly_content;
 
 /*Netflix Market Share By Country */
 
 select country,count(*) as total_titles,round(count(*)*100.0 / (select count(*) from netflix),2) as Market_Share
 from netflix where trim(country)<>'' and country is not null
 group by country
 order by market_share desc;
 
 /* Longest Duration Movies */
 
 select title,duration,director from netflix where type='Movie' 
 order by cast(
 substring_index(duration,' ',1) as 	UNSIGNED 
 )
 DESC LIMIT 10;
 
 /* Productive Directors */
 
 select director,count(*) as total_titles from netflix
 where director is not null
 group by director
 order by total_titles desc
 limit 10;
 
 /*Most Popular Genres */
 
 select listed_in,count(*) as total_count_of_genres
 from netflix 
 group by listed_in
 order by total_count_of_genres desc ;
 
 /* Top Genre Every Year */
 
WITH top_genre as(
 select release_year,listed_in,count(*) as total_titles,
 row_number()over(partition by release_year order by count(*) desc)rn
 from netflix
 where release_year is not null and listed_in is not null
 group  by release_year,listed_in
 )
 select*from top_genre where rn=1
 limit 10;
 
 
