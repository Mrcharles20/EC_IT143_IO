/*****************************************************************************************************************
NAME:    EC_IT143_W5.2_VideoGames_IO.sql
PURPOSE: Video Games Dataset Analysis - Answering 4 Community Questions
MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/02/2026   JJAUSSI       1. Built this script for EC IT143
RUNTIME: 
12s
NOTES: 
This script answers 4 analytical questions about the Video Games dataset.
Includes questions from classmates focusing on publisher performance and platform trends.
******************************************************************************************************************/

-- ===================================================================
-- QUESTION 1: My Question - Publisher Performance
-- Question Author: [Nhlanhla George Mazibuko]
-- "Which publishers have the highest average ratings?"
-- ===================================================================

-- Create sample video games data
IF OBJECT_ID('tempdb..#games_data') IS NOT NULL
    DROP TABLE #games_data;

CREATE TABLE #games_data (
    game_id INT PRIMARY KEY,
    title VARCHAR(100),
    publisher VARCHAR(50),
    platform VARCHAR(20),
    release_year INT,
    genre VARCHAR(30),
    rating DECIMAL(3,1)
);

-- Insert sample data
INSERT INTO #games_data VALUES
(1, 'Game A', 'Publisher X', 'PS4', 2018, 'Action', 9.0),
(2, 'Game B', 'Publisher X', 'PC', 2020, 'RPG', 8.5),
(3, 'Game C', 'Publisher Y', 'Switch', 2019, 'Adventure', 8.8),
(4, 'Game D', 'Publisher Y', 'PS4', 2021, 'Action', 7.5),
(5, 'Game E', 'Publisher Z', 'PC', 2017, 'Strategy', 9.2),
(6, 'Game F', 'Publisher Z', 'Switch', 2022, 'Adventure', 8.0),
(7, 'Game G', 'Publisher X', 'PC', 2021, 'RPG', 8.7),
(8, 'Game H', 'Publisher Y', 'PS4', 2020, 'Action', 8.3);

-- Query 1: Publisher Performance
SELECT 
    publisher,
    COUNT(game_id) AS games_published,
    ROUND(AVG(rating), 2) AS avg_publisher_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    ROUND(STDEV(rating), 3) AS rating_consistency
FROM #games_data
GROUP BY publisher
HAVING COUNT(game_id) >= 2
ORDER BY avg_publisher_rating DESC;
GO

-- ===================================================================
-- QUESTION 2: Classmate Question - Nhlanhla George Mazibuko
-- Question Author: Nhlanhla George Mazibuko
-- "How does player rating consistency vary by publisher across different platforms?"
-- ===================================================================

SELECT 
    publisher,
    platform,
    COUNT(game_id) AS games_count,
    ROUND(AVG(rating), 2) AS avg_platform_rating,
    ROUND(STDEV(rating), 3) AS rating_std_dev,
    CASE 
        WHEN STDEV(rating) <= 0.5 THEN 'Highly Consistent'
        WHEN STDEV(rating) <= 1.0 THEN 'Moderately Consistent'
        ELSE 'Variable Performance'
    END AS consistency_category
FROM #games_data
WHERE release_year >= 2017
GROUP BY publisher, platform
HAVING COUNT(game_id) >= 1
ORDER BY publisher, platform;
GO

-- ===================================================================
-- QUESTION 3: My Question - Platform Analysis
-- Question Author: [Nhlanhla George Mazibuko]
-- "Which platforms have the highest average game ratings?"
-- ===================================================================

SELECT 
    platform,
    COUNT(game_id) AS total_games,
    ROUND(AVG(rating), 2) AS avg_platform_rating,
    MIN(release_year) AS earliest_year,
    MAX(release_year) AS latest_year,
    COUNT(DISTINCT publisher) AS unique_publishers,
    COUNT(DISTINCT genre) AS unique_genres
FROM #games_data
GROUP BY platform
HAVING COUNT(game_id) >= 2
ORDER BY avg_platform_rating DESC;
GO

-- ===================================================================
-- QUESTION 4: Classmate Question - Genre Platform Trends
-- Question Author: Nhlanhla George Mazibuko
-- "What is the average rating for each genre on each platform?"
-- ===================================================================

SELECT 
    genre,
    platform,
    COUNT(game_id) AS genre_games_count,
    ROUND(AVG(rating), 2) AS avg_genre_rating,
    ROUND(AVG(release_year), 0) AS avg_release_year,
    STRING_AGG(title, ', ') AS game_titles
FROM #games_data
GROUP BY genre, platform
HAVING COUNT(game_id) >= 1
ORDER BY genre, avg_genre_rating DESC;
GO

-- Clean up
IF OBJECT_ID('tempdb..#games_data') IS NOT NULL
    DROP TABLE #games_data;
GO