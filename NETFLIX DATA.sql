CREATE TABLE netflix (
    show_id VARCHAR(6),
    type VARCHAR(10),
    title VARCHAR(150),
    director VARCHAR(250),
    casts VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT, 
    rating VARCHAR(10),
    duration VARCHAR(15),
    listed_in VARCHAR(100),
    description VARCHAR(250)
);


SELECT*FROM netflix;

SELECT COUNT(*) AS total_content
FROM netflix

SELECT DISTINCT type
FROM netflix;

--15 Business Problems

1. Count the number of Movies vs TV Shows

SELECT type , COUNT(*) AS total_shows
FROM netflix
GROUP BY type;
---------------------------------------------------------------------------------------------------
2.Find the most common rating for movies and TV shows

WITH Rank_rating AS
		(SELECT type,rating, COUNT(*),
				RANK () OVER(PARTITION BY type ORDER BY COUNT(*) DESC ) AS Ranking
				FROM netflix
				GROUP BY 1 , 2)

SELECT type , rating
FROM Rank_rating
WHERE Ranking = 1

--------------------------------------------------------------------------------------------------------                              


3.List All Movies Released in a Specific Year (e.g., 2021)

SELECT *
FROM netflix
WHERE release_year = 2021 AND type = 'Movie'
-----------------------------------------------------------------------------------------------------------
4.Find the Top 5 Countries with the Most Content on Netflix

SELECT 
		 UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
		 COUNT(show_id) AS total_content,
		 RANK() OVER(ORDER BY COUNT(show_id) DESC) AS Ranking
		 FROM netflix
		 GROUP BY 1
		 LIMIT 5
-------------------------------------------------------------------------------------------------------------
5. Identify the longest movie.

SELECT type,title
FROM netflix
WHERE CAST(split_part(duration, ' ', 1) AS INTEGER)= (SELECT MAX(CAST(split_part(duration, ' ', 1) AS INTEGER)) AS max_duration
						FROM netflix
						WHERE type = 'Movie')

-----------------------------------------------------------------------------------------------------------------------
6.find content added in the last 5 years

SELECT *

FROM netflix
WHERE 
       TO_DATE(date_added,'Month DD,YYYY')>= (SELECT CURRENT_DATE - INTERVAL '5 years')
--------------------------------------------------------------------------------------------------------------------------
7.Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT*
FROM netflix n
WHERE n.director ILIKE '%Rajiv Chilaka%'


----------------------------------------------------------------------------------------------------------------------------
8.List all TV Shows with more than 5 seasons.

SELECT*
FROM netflix n
WHERE type='TV Show' AND split_part(duration,' ',1)::numeric  > 5
----------------------------------------------------------------------------------------------------------------------------

9.Count the number of content items in each genre

SELECT 
UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
COUNT(show_id) AS no_of_contents
FROM netflix n
GROUP BY genre
ORDER BY 2 DESC
------------------------------------------------------------------------------------------------------------------------------
10.Find each year and the average content relese in India on netflix,
return top 5 with highest avg content release


SELECT  EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) AS year,
			COUNT(*) AS yearly_content,
			ROUND(
			COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100 ,2)
			AS avg_content_per_year
       FROM netflix
			WHERE country = 'India'
			GROUP BY 1
			ORDER BY yearly_content DESC
			LIMIT 5

------------------------------------------------------------------------------------------------------------------------------------
11.List all movies that are documentaries

SELECT*
FROM netflix
WHERE type='Movie' AND listed_in ILIKE '%Documentaries%'

---------------------------------------------------------------------------------------------------------------------------------------
12.Find all content without a director

SELECT*
FROM netflix
WHERE director IS NULL
-------------------------------------------------------------------------------------------------------------------------------------------
13.Find how many movies actor 'Salamn Khan' appeared in last 10 years

SELECT*
FROM netflix
WHERE release_year >= EXTRACT(YEAR FROM(SELECT CURRENT_DATE - INTERVAL '10 years'))
      AND casts ILIKE '%Salman Khan%'
-----------------------------------------------------------------------------------------------------------------------------------------
14.Find the top 10 actors who have appeared in the highest number of movies produced in India

WITH movie_india AS( SELECT*
			FROM netflix
			WHERE type = 'Movie' AND country ILIKE '%India%'),
            movies AS(
				SELECT
				  UNNEST(STRING_TO_ARRAY(casts,',')) AS actors,
				  UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre
				  FROM movie_india)

SELECT actors,
        COUNT(*) AS no_of_movies
		FROM movies
WHERE actors IS NOT NULL 
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 10
	
--------------------------------------------------------------------------------------------------------------------------------------------  
15.Categorize the content based on the prsesence of the keywords 'kill' and 'violence' in
the description field.Label content containing these keywords as 'Bad' and all other
content as 'Good'.Count how many items fall into each category.

WITH new_table AS (SELECT *,
			   CASE 
			      WHEN description ILIKE '%kill%' OR  description ILIKE '%violence%' THEN 'Bad'
			      ELSE 'Good'  
			   END AS content
			FROM netflix)

SELECT content,
    COUNT(*) AS total_content
FROM new_table
GROUP BY 1
---------------------------------------------------------------------------------------------------------------------------------------------------


