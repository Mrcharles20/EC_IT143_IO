/*****************************************************************************************************************
NAME:    EC_IT143_6.3_fwf_s1_io.sql
PURPOSE: Step 1 - Start with a question for Functions exercise

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Built this script for EC IT143

RUNTIME: 
< 1s

NOTES: 
First step: Define the simplest, most focused question.
******************************************************************************************************************/

-- Q1: How to extract first name from Contact Name?

/*****************************************************************************************************************
NAME:    EC_IT143_6.3_fwf_s2_js.sql
PURPOSE: Step 2 - Begin creating an answer

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Built this script for EC IT143

RUNTIME: 
< 1s

NOTES: 
Second step: Start the journey to find the answer.
******************************************************************************************************************/

-- Q1: How to extract first name from Contact Name?
-- A1: Well, here is your problem...
-- CustomerName = Alejandra Camino -> Alejandra
-- I need to separate the first word from the full name.

/*****************************************************************************************************************
NAME:    EC_IT143_6.3_fwf_s3_js.sql
PURPOSE: Step 3 - Create an ad hoc SQL query

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Built this script for EC IT143

RUNTIME: 
< 1s

NOTES: 
Third step: Create initial query to understand the data.
******************************************************************************************************************/

-- First look at the ContactName data we need to parse
SELECT 
    t.ContactName,
    'We need everything before the first space' AS Analysis
FROM [dbo].[t_w3_schools_customers] AS t
ORDER BY t.ContactName;

/*****************************************************************************************************************
NAME:    EC_IT143_6.3_fwf_s4_js.sql
PURPOSE: Step 4 - Research and test a solution

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Built this script for EC IT143

RUNTIME: 
< 1s

NOTES: 
Fourth step: Find and test a parsing solution.
Research source: https://stackoverflow.com/questions/5145791/extracting-first-name-and-last-name
******************************************************************************************************************/

-- Testing solution found through research:
-- Use LEFT() function with CHARINDEX() to find space position
SELECT 
    t.ContactName,
    -- LEFT gets characters from left side
    -- CHARINDEX finds position of space character  
    -- We add + ' ' to handle names without spaces
    -- Subtract 1 to exclude the space itself
    LEFT(t.ContactName, CHARINDEX(' ', t.ContactName + ' ') - 1) AS first_name
FROM [dbo].[t_w3_schools_customers] AS t
ORDER BY t.ContactName;

/*****************************************************************************************************************
NAME:    EC_IT143_6.3_fwf_s5_js.sql
PURPOSE: Step 5 - Create a user-defined scalar function

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Built this script for EC IT143

RUNTIME: 
< 1s

NOTES: 
Fifth step: Package the solution into a reusable function.
******************************************************************************************************************/

-- Drop function if it exists (clean start)
DROP FUNCTION IF EXISTS [dbo].[udf_parse_first_name]
GO

CREATE FUNCTION [dbo].[udf_parse_first_name]
    (@v_combined_name AS VARCHAR(500))  -- Input parameter: full name
RETURNS VARCHAR(100)                     -- Output: first name only
AS
BEGIN
    -- Function logic: Same as our tested solution
    DECLARE @v_first_name AS VARCHAR(100)
    
    SET @v_first_name = LEFT(@v_combined_name, 
                            CHARINDEX(' ', @v_combined_name + ' ') - 1)
    
    RETURN @v_first_name
END
GO

PRINT 'Function [dbo].[udf_parse_first_name] created successfully.'
GO

/*****************************************************************************************************************
NAME:    EC_IT143_6.3_fwf_s6_js.sql
PURPOSE: Step 6 - Compare UDF results to ad hoc query results

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Built this script for EC IT143

RUNTIME: 
< 1s

NOTES: 
Sixth step: Validate that function produces same results as manual query.
******************************************************************************************************************/

-- Compare side-by-side: manual extraction vs function call
SELECT 
    t.ContactName AS FullName,
    -- Manual method from Step 4
    LEFT(t.ContactName, CHARINDEX(' ', t.ContactName + ' ') - 1) AS first_name_manual,
    -- Function call from Step 5  
    [dbo].[udf_parse_first_name](t.ContactName) AS first_name_function,
    -- Validation: Do they match?
    CASE 
        WHEN LEFT(t.ContactName, CHARINDEX(' ', t.ContactName + ' ') - 1) = 
             [dbo].[udf_parse_first_name](t.ContactName)
        THEN '✓ MATCH'
        ELSE '✗ MISMATCH - NEEDS FIXING'
    END AS Validation_Result
FROM [dbo].[t_w3_schools_customers] AS t
ORDER BY t.ContactName;

/*****************************************************************************************************************
NAME:    EC_IT143_6.3_fwf_s7_js.sql
PURPOSE: Step 7 - Perform a "0 results expected" test

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Built this script for EC IT143

RUNTIME: 
< 1s

NOTES: 
Seventh step: Formal test that should return ZERO rows if function works.
Uses Common Table Expression (CTE).
******************************************************************************************************************/

-- Create CTE to compare manual vs function results
WITH ComparisonCTE AS (
    SELECT 
        t.ContactName,
        LEFT(t.ContactName, CHARINDEX(' ', t.ContactName + ' ') - 1) AS manual_result,
        [dbo].[udf_parse_first_name](t.ContactName) AS function_result
    FROM [dbo].[t_w3_schools_customers] AS t
)
-- Select ONLY rows where results DON'T match
SELECT *
FROM ComparisonCTE
WHERE manual_result <> function_result  -- Looking for mismatches
    OR (manual_result IS NULL AND function_result IS NOT NULL)  -- Handle NULL cases
    OR (manual_result IS NOT NULL AND function_result IS NULL)   -- Handle NULL cases
-- If function works: ZERO rows returned
-- If function fails: Shows problematic rows

/*****************************************************************************************************************
NAME:    EC_IT143_6.3_fwf_s8_js.sql
PURPOSE: Step 8 - Ask the next question

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Built this script for EC IT143

RUNTIME: 
< 1s

NOTES: 
Eighth step: Continue the process with next logical question.
******************************************************************************************************************/

-- Q1: How to extract first name from Contact Name? ✓ SOLVED
-- Function created: [dbo].[udf_parse_first_name]

-- Q2: How to extract LAST name from Contact Name?
-- A2: Now I need the part AFTER the space...

-- Show current incomplete solution:
SELECT 
    t.CustomerID,
    t.CustomerName,
    t.ContactName,
    dbo.udf_parse_first_name(t.ContactName) AS ContactName_first_name,
    '' AS ContactName_last_name,  -- EMPTY - Need to solve this!
    t.Address,
    t.City,
    t.Country
FROM [dbo].[t_w3_schools_customers] AS t
ORDER BY t.ContactName;

