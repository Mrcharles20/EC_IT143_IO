/*****************************************************************************************************************
NAME:    EC_IT143_6.3_fwt_s1_io.sql
PURPOSE: Step 1 - Start with a question for Triggers exercise

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Built this script for EC IT143

RUNTIME: 
< 1s

NOTES: 
First step: Define the simplest, most focused trigger question.
******************************************************************************************************************/

-- Q1: How to keep track of when a record was last modified?

/*****************************************************************************************************************
NAME:    EC_IT143_6.3_fwt_s2_io.sql
PURPOSE: Step 2 - Begin creating an answer for trigger problem

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Built this script for EC IT143

RUNTIME: 
< 1s

NOTES: 
Second step: Start exploring trigger solution.
******************************************************************************************************************/

-- Q1: How to keep track of when a record was last modified?
-- A1: First attempt - add column with DEFAULT constraint

ALTER TABLE [dbo].[t_hello_world]
ADD last_modified_date DATETIME DEFAULT GETDATE();

PRINT 'Column added, but DEFAULT only works for INSERT operations...'
PRINT 'Question: How to make it work for UPDATE operations too?'

/*****************************************************************************************************************
NAME:    EC_IT143_6.3_fwt_s3_io.sql
PURPOSE: Step 3 - Research and test trigger solution

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Built this script for EC IT143

RUNTIME: 
< 1s

NOTES: 
Third step: Research trigger implementation.
Research sources: 
- https://stackoverflow.com/questions/9522982/t-sql-trigger-update
- https://stackoverflow.com/questions/4574010/how-to-create-trigger-to-keep-track-of-last-changed-data
******************************************************************************************************************/

-- Q1: How to keep track of when a record was last modified?
-- A1: DEFAULT constraint only works for INSERT (tried in Step 2)

-- Q2: How to make it work for UPDATE?
-- A2: Research shows "AFTER UPDATE trigger" is the solution

-- Research findings:
-- 1. Triggers automatically execute when data changes
-- 2. AFTER UPDATE trigger fires AFTER update completes
-- 3. Special tables: "inserted" has new values, "deleted" has old values
-- 4. Need to join on primary key to update correct rows

PRINT 'Solution identified: Create an AFTER UPDATE trigger'
PRINT 'Trigger will: 1. Fire after updates 2. Set last_modified_date = GETDATE()'

/*****************************************************************************************************************
NAME:    EC_IT143_6.3_fwt_s4_io.sql
PURPOSE: Step 4 - Create an after-update trigger

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Built this script for EC IT143

RUNTIME: 
< 1s

NOTES: 
Fourth step: Implement the trigger solution.
******************************************************************************************************************/

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS [dbo].[trg_t_hello_world_update_date]
GO

CREATE TRIGGER [dbo].[trg_t_hello_world_update_date]
ON [dbo].[t_hello_world]                -- Table this trigger watches
AFTER UPDATE                           -- Timing: AFTER update operation
AS
BEGIN
    -- Update the last_modified_date for all changed rows
    UPDATE t
    SET last_modified_date = GETDATE()  -- Set to current date/time
    FROM [dbo].[t_hello_world] AS t    -- Target table
    INNER JOIN inserted AS i           -- "inserted" has NEW values
        ON t.my_message = i.my_message -- Match on primary key column
END
GO

PRINT 'Trigger [dbo].[trg_t_hello_world_update_date] created successfully.'
PRINT 'It will automatically update last_modified_date on EVERY update.'
GO

/*****************************************************************************************************************
NAME:    EC_IT143_6.3_fwt_s5_io.sql
PURPOSE: Step 5 - Test results to see if trigger works as expected

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Built this script for EC IT143

RUNTIME: 
< 1s

NOTES: 
Fifth step: Test the trigger functionality.
******************************************************************************************************************/

-- Display BEFORE state
PRINT '=== BEFORE UPDATE ==='
SELECT * FROM [dbo].[t_hello_world]
ORDER BY my_message
GO

-- Perform an UPDATE operation (should fire trigger)
PRINT 'Performing UPDATE operation...'
UPDATE [dbo].[t_hello_world]
SET my_message = 'Hello World Updated'
WHERE my_message = 'Hello World2'
GO

-- Display AFTER state
PRINT '=== AFTER UPDATE ==='
PRINT 'Notice: last_modified_date should be updated automatically by trigger'
SELECT * FROM [dbo].[t_hello_world]
ORDER BY my_message
GO

-- Additional test: Update multiple rows
PRINT 'Testing multiple row update...'
UPDATE [dbo].[t_hello_world]
SET my_message = my_message + ' (checked)'
WHERE my_message LIKE '%World%'
GO

PRINT '=== FINAL STATE ==='
SELECT 
    my_message,
    last_modified_date,
    'Updated by trigger' AS Update_Source
FROM [dbo].[t_hello_world]
ORDER BY last_modified_date DESC
GO

/*****************************************************************************************************************
NAME:    EC_IT143_6.3_fwt_s6_io.sql
PURPOSE: Step 6 - Ask the next question for trigger enhancement

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Built this script for EC IT143

RUNTIME: 
< 1s

NOTES: 
Sixth step: Continue process with enhanced trigger question.
******************************************************************************************************************/

-- Q1: How to keep track of when a record was last modified? ✓ SOLVED
-- Trigger created: [dbo].[trg_t_hello_world_update_date]

-- Q2: How to keep track of WHO last modified a record?
-- A2: Also capture the user name who made the change

-- Show current state (has timestamp but no user):
PRINT 'Current trigger tracks WHEN but not WHO...'
SELECT 
    my_message,
    last_modified_date AS WhenModified,
    last_modified_by AS WhoModified  -- NULL - need to fix!
FROM [dbo].[t_hello_world]
ORDER BY last_modified_date DESC
GO

-- Next step: Modify trigger to also set last_modified_by = USER_NAME()
-- Need to: 
-- 1. Add last_modified_by column if not exists
-- 2. Update trigger to set both date AND user
-- 3. Test enhanced functionality

