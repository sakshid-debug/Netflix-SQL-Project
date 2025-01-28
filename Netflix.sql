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

SELECT COUNT(*) FROM netflix ;

-- BUSINESS PROBLEMS

-- Q.1. Count the Number of Movies vs TV Shows.
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1 ;

-- Q.2. Find the Most Common Rating for Movies and TV Shows.
SELECT 
    type, 
	rating
FROM 
    (SELECT type, 
       rating,
       COUNT(*) AS count,
       RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
     FROM netflix 
	 GROUP BY type, rating
	) AS t1
WHERE ranking = 1 ;

-- Q.3. List All Movies Released in a Specific Year (e.g., 2020).
SELECT *
FROM netflix
WHERE 
type = 'Movie' AND release_year = '2020' ;

-- Q.4. Find the Top 5 Countries with the Most Content on Netflix. 
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC 
LIMIT 5;

-- Q.5. Identify the Longest Movie.
SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND 
		duration = (SELECT MAX(duration) FROM netflix) ;

-- Q.6. Find Content Added in the Last 5 Years.
SELECT *
FROM netflix
WHERE 				
	TO_DATE (date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 Years' ;

SELECT CURRENT_DATE - INTERVAL '5 Years' ;

-- Q.7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'.
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%' ;

-- Q.8. List All TV Shows with More Than 5 Seasons.
SELECT *
FROM netflix
WHERE 
	type = 'TV Show'
	AND SPLIT_PART(duration, ' ', 1)::INT > 5 ;	
		-- duration > '5 Seasons' ; 

-- Q.9. Count the Number of Content Items in Each Genre.
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1 ;

-- Q.10. Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5 ;

-- Q.11. List All Movies that are Documentaries.
SELECT * 
FROM netflix
WHERE listed_in ILIKE '%Documentaries%' ;

-- Q.12. Find All Content Without a Director.
SELECT * 
FROM netflix
WHERE director IS NULL ;

-- Q.13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 12 Years.
SELECT * 
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 12 ;

-- Q.14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India.
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Q.15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords.
SELECT 
    category,
    COUNT(*) AS content_count
FROM
	(
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
	) AS categorized_content
GROUP BY category;



