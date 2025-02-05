# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type , COUNT(*) AS total_shows
FROM netflix
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
WITH Rank_rating AS
		(SELECT type,rating, COUNT(*),
				RANK () OVER(PARTITION BY type ORDER BY COUNT(*) DESC ) AS Ranking
				FROM netflix
				GROUP BY 1 , 2)

SELECT type , rating
FROM Rank_rating
WHERE Ranking = 1
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2021)

```sql
SELECT *
FROM netflix
WHERE release_year = 2021 AND type = 'Movie'
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT 
		 UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
		 COUNT(show_id) AS total_content,
		 RANK() OVER(ORDER BY COUNT(show_id) DESC) AS Ranking
		 FROM netflix
		 GROUP BY 1
		 LIMIT 5

```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT type,title
FROM netflix
WHERE CAST(split_part(duration, ' ', 1) AS INTEGER)= (SELECT MAX(CAST(split_part(duration, ' ', 1) AS INTEGER)) AS max_duration
						FROM netflix
						WHERE type = 'Movie')
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *

FROM netflix
WHERE 
       TO_DATE(date_added,'Month DD,YYYY')>= (SELECT CURRENT_DATE - INTERVAL '5 years')
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT*
FROM netflix n
WHERE n.director ILIKE '%Rajiv Chilaka%'
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT*
FROM netflix n
WHERE type='TV Show' AND split_part(duration,' ',1)::numeric  > 5
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
COUNT(show_id) AS no_of_contents
FROM netflix n
GROUP BY genre
ORDER BY 2 DESC
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average content relese in India on netflix,
return top 5 with highest avg content release

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT*
FROM netflix
WHERE type='Movie' AND listed_in ILIKE '%Documentaries%'
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT*
FROM netflix
WHERE director IS NULL
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT*
FROM netflix
WHERE release_year >= EXTRACT(YEAR FROM(SELECT CURRENT_DATE - INTERVAL '10 years'))
      AND casts ILIKE '%Salman Khan%'
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
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
	
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize the content based on the prsesence of the keywords 'kill' and 'violence' in
the description field.Label content containing these keywords as 'Bad' and all other
content as 'Good'.Count how many items fall into each category.

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.


