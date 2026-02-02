/*****************************************************************************************************************
NAME:    EC_IT143_W5.2_Movies_IO.sql
PURPOSE: Movies Dataset Analysis - Answering 4 Community Questions
MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/02/2026   JJAUSSI       1. Built this script for EC IT143
RUNTIME: 
15s
NOTES: 
This script answers 4 analytical questions about the Movies dataset.
Includes questions from classmates and demonstrates SQL translation skills.
******************************************************************************************************************/

-- ===================================================================
-- QUESTION 1: My Question - Genre Popularity Over Time
-- Question Author: [Nhlanhla George Mazibuko
-- "Which movie genres have shown the most consistent high ratings over the past decade?"
-- ===================================================================

-- Create sample data if needed
IF OBJECT_ID('tempdb..#movies_data') IS NOT NULL
    DROP TABLE #movies_data;

CREATE TABLE #movies_data (
    movie_id INT PRIMARY KEY,
    title VARCHAR(100),
    release_year INT,
    director_name VARCHAR(50),
    genre_name VARCHAR(50),
    rating DECIMAL(3,1),
    duration_minutes INT
);

-- Insert sample data
INSERT INTO #movies_data VALUES
(1, 'Movie A', 2015, 'Director 1', 'Action', 8.5, 120),
(2, 'Movie B', 2018, 'Director 2', 'Action', 7.8, 115),
(3, 'Movie C', 2020, 'Director 1', 'Drama', 9.0, 135),
(4, 'Movie D', 2019, 'Director 3', 'Comedy', 6.5, 95),
(5, 'Movie E', 2017, 'Director 2', 'Action', 8.2, 125),
(6, 'Movie F', 2021, 'Director 4', 'Drama', 8.8, 140);

-- Query 1: Genre Popularity Over Time
SELECT 
    genre_name,
    COUNT(movie_id) AS movie_count,
    AVG(rating) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    ROUND(STDEV(rating), 3) AS rating_consistency
FROM #movies_data
WHERE release_year >= 2015
GROUP BY genre_name
HAVING COUNT(movie_id) >= 2
ORDER BY rating_consistency ASC, avg_rating DESC;
GO

-- ===================================================================
-- QUESTION 2: Classmate Question - Movie Duration Analysis
-- Question Author: Nhlanhla George Mazibuko
-- "How has average movie duration changed across different genres?"
-- ===================================================================

WITH genre_decade_data AS (
    SELECT 
        genre_name,
        CASE 
            WHEN release_year BETWEEN 2015 AND 2017 THEN '2015-2017'
            WHEN release_year BETWEEN 2018 AND 2020 THEN '2018-2020'
            WHEN release_year BETWEEN 2021 AND 2023 THEN '2021-2023'
            ELSE 'Other'
        END AS time_period,
        AVG(duration_minutes) AS avg_duration,
        COUNT(*) AS movie_count
    FROM #movies_data
    WHERE release_year BETWEEN 2015 AND 2023
    GROUP BY genre_name, 
        CASE 
            WHEN release_year BETWEEN 2015 AND 2017 THEN '2015-2017'
            WHEN release_year BETWEEN 2018 AND 2020 THEN '2018-2020'
            WHEN release_year BETWEEN 2021 AND 2023 THEN '2021-2023'
            ELSE 'Other'
        END
)
SELECT 
    genre_name,
    MAX(CASE WHEN time_period = '2015-2017' THEN avg_duration END) AS avg_duration_2015_2017,
    MAX(CASE WHEN time_period = '2018-2020' THEN avg_duration END) AS avg_duration_2018_2020,
    MAX(CASE WHEN time_period = '2021-2023' THEN avg_duration END) AS avg_duration_2021_2023,
    SUM(movie_count) AS total_movies
FROM genre_decade_data
GROUP BY genre_name
ORDER BY genre_name;
GO

-- ===================================================================
-- QUESTION 3: My Question - Director Performance
-- Question Author: [Nhlanhla George Mazibuko]
-- "Which directors have the highest average ratings?"
-- ===================================================================

SELECT 
    director_name,
    COUNT(movie_id) AS movies_directed,
    AVG(rating) AS avg_director_rating,
    AVG(duration_minutes) AS avg_movie_length,
    MIN(release_year) AS first_year,
    MAX(release_year) AS last_year
FROM #movies_data
GROUP BY director_name
HAVING COUNT(movie_id) >= 2
ORDER BY avg_director_rating DESC;
GO

-- ===================================================================
-- QUESTION 4: Classmate Question - Genre Rating Analysis
-- Question Author: Nhlanhla George Mazibuko
-- "What is the average rating for each genre?"
-- ===================================================================

SELECT 
    genre_name,
    COUNT(movie_id) AS total_movies,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(duration_minutes), 0) AS average_duration,
    MIN(release_year) AS earliest_year,
    MAX(release_year) AS latest_year
FROM #movies_data
GROUP BY genre_name
ORDER BY average_rating DESC;
GO

-- Clean up
IF OBJECT_ID('tempdb..#movies_data') IS NOT NULL
    DROP TABLE #movies_data;
GO