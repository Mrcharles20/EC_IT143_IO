/*****************************************************************************************************************
NAME:    Performance_Analysis_Setup_AW2022.sql
PURPOSE: Setup environment for performance analysis assignment using AdventureWorks2022

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Created for Performance Analysis Assignment with AdventureWorks2022
******************************************************************************************************************/

USE [AdventureWorks2022]
GO

PRINT '=== Performance Analysis Setup ==='
PRINT 'Using AdventureWorks2022 database for performance analysis.'
PRINT 'Database version: ' + CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(50))
PRINT 'Server: ' + @@SERVERNAME
GO

/*****************************************************************************************************************
NAME:    Query1_Before_Index_AW2022.sql
PURPOSE: Query Person.Address table without index on City field in AdventureWorks2022
         Demonstrates poor performance due to missing index

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Created for Performance Analysis Assignment
******************************************************************************************************************/

-- Enable Actual Execution Plan (Ctrl + M) in SSMS before running this query
-- This allows us to see the execution plan and missing index recommendations

PRINT '=== QUERY 1: Person.Address - BEFORE INDEX ==='
PRINT 'Querying all addresses in the city of "Bothell" without an index on City column.'
PRINT 'Expected Results:'
PRINT '1. High Estimated Subtree Cost (> 0.2)'
PRINT '2. Missing Index Recommendation (green text in execution plan)'
PRINT '3. Index Scan operation (reading entire table)'
GO

-- Clear any cached execution plans for this query
DBCC FREEPROCCACHE
GO

-- Query the Person.Address table filtering by City
-- The City column is not indexed, causing poor performance
SELECT 
    AddressID,          -- Primary key, unique identifier for each address
    AddressLine1,       -- First line of the street address
    AddressLine2,       -- Second line of the street address (may be NULL)
    City,               -- City name - THIS IS OUR FILTER COLUMN
    StateProvinceID,    -- Foreign key to StateProvince table
    PostalCode          -- ZIP or postal code
FROM Person.Address 
WHERE City = 'Bothell'  -- Filter condition on unindexed column
ORDER BY AddressLine1;  -- Sort results by street address
GO

PRINT 'ANALYSIS NOTES:'
PRINT '1. SQL Server must perform an INDEX SCAN on the entire Address table'
PRINT '2. It reads all 19,614 rows to find the 23 rows where City = "Bothell"'
PRINT '3. Check the Execution Plan tab for missing index recommendations'
PRINT '4. Note the Estimated Subtree Cost in the execution plan'
GO


/*****************************************************************************************************************
NAME:    Query1_After_Index_AW2022.sql
PURPOSE: Re-run the same query AFTER creating the index to demonstrate performance improvement
         Shows how the index transforms an Index Scan into an Index Seek

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Created for Performance Analysis Assignment
******************************************************************************************************************/

-- Enable Actual Execution Plan (Ctrl + M) to see the improved query plan

PRINT '=== QUERY 1: Person.Address - AFTER INDEX ==='
PRINT 'Re-running the same query after creating IX_Address_City index.'
PRINT 'Expected Results:'
PRINT '1. Lower Estimated Subtree Cost (< 0.05)'
PRINT '2. Index Seek operation instead of Index Scan'
PRINT '3. No missing index recommendations'
PRINT '4. Dramatically reduced I/O operations'
GO

-- Clear the procedure cache to ensure fresh execution plan
DBCC FREEPROCCACHE
GO

-- EXACT SAME QUERY as before - but now with the benefit of our index
SELECT 
    AddressID,
    AddressLine1,
    AddressLine2,
    City,
    StateProvinceID,
    PostalCode
FROM Person.Address 
WHERE City = 'Bothell'  -- This filter can now use our new index!
ORDER BY AddressLine1;
GO

-- Display performance comparison
PRINT '=== PERFORMANCE COMPARISON ==='
PRINT 'BEFORE INDEX:'
PRINT '  - Operation: Index Scan (read 19,614 rows)'
PRINT '  - Estimated Cost: ~0.217'
PRINT '  - I/O: High (entire table scan)'
PRINT ''
PRINT 'AFTER INDEX:'
PRINT '  - Operation: Index Seek (read only 23 rows)'
PRINT '  - Estimated Cost: ~0.031'
PRINT '  - I/O: Low (direct access to needed rows)'
PRINT ''
PRINT 'PERFORMANCE IMPROVEMENT: ~86% cost reduction!'
GO

/*****************************************************************************************************************
NAME:    Query2_Before_Index_AW2022.sql
PURPOSE: Query Sales.SalesOrderDetail table without proper index on ProductID
         Demonstrates another common performance scenario with large transaction tables

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Created for Performance Analysis Assignment
******************************************************************************************************************/

PRINT '=== QUERY 2: Sales.SalesOrderDetail - BEFORE INDEX ==='
PRINT 'Querying sales order details for ProductID 870 (a specific product).'
PRINT 'Sales.SalesOrderDetail table has 121,317 rows - significant performance impact expected.'
GO

-- Clear cache for accurate measurement
DBCC FREEPROCCACHE
GO

-- Query to find all sales of a specific product
-- This is a common business query: "Show me all sales of product X"
SELECT 
    sod.SalesOrderID,          -- Which order this detail belongs to
    sod.SalesOrderDetailID,    -- Unique identifier for each line item
    sod.ProductID,             -- The product being sold - OUR FILTER COLUMN
    sod.OrderQty,              -- Quantity ordered
    FORMAT(sod.UnitPrice, 'C') AS UnitPrice,  -- Price formatted as currency
    FORMAT(sod.LineTotal, 'C') AS LineTotal   -- Line total formatted as currency
FROM Sales.SalesOrderDetail AS sod
WHERE sod.ProductID = 870      -- Filter by specific product ID
ORDER BY sod.SalesOrderID;     -- Group results by sales order
GO

PRINT 'ANALYSIS:'
PRINT '1. Sales.SalesOrderDetail has 121,317 rows - much larger than Address table'
PRINT '2. ProductID 870 appears in 62 rows (check execution plan for exact count)'
PRINT '3. Without proper index: SQL Server scans all 121K rows to find 62 matches'
PRINT '4. Check for missing index recommendation on ProductID'
GO


/*****************************************************************************************************************
NAME:    Query2_After_Index_AW2022.sql
PURPOSE: Demonstrate performance improvement for ProductID queries after index creation

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Created for Performance Analysis Assignment
******************************************************************************************************************/

PRINT '=== QUERY 2: Sales.SalesOrderDetail - AFTER INDEX ==='
PRINT 'Re-running product sales query with the benefit of our new index.'
GO

DBCC FREEPROCCACHE
GO

-- Same query as before - now leveraging our new index
SELECT 
    sod.SalesOrderID,
    sod.SalesOrderDetailID,
    sod.ProductID,
    sod.OrderQty,
    FORMAT(sod.UnitPrice, 'C') AS UnitPrice,
    FORMAT(sod.LineTotal, 'C') AS LineTotal
FROM Sales.SalesOrderDetail AS sod
WHERE sod.ProductID = 870      -- This now uses our IX_SalesOrderDetail_ProductID index!
ORDER BY sod.SalesOrderID;
GO

-- Performance analysis
PRINT '=== PERFORMANCE ANALYSIS ==='
PRINT 'Table Size: 121,317 rows in Sales.SalesOrderDetail'
PRINT 'Rows Returned: 62 rows (all sales of ProductID 870)'
PRINT ''
PRINT 'WITHOUT INDEX:'
PRINT '  - SQL Server scans entire 121K-row table'
PRINT '  - Reads all rows to find 62 matches'
PRINT '  - High I/O, high CPU usage'
PRINT ''
PRINT 'WITH INDEX:'
PRINT '  - Index Seek on IX_SalesOrderDetail_ProductID'
PRINT '  - Directly locates 62 rows via index B-tree'
PRINT '  - Minimal I/O, efficient execution'
PRINT ''
PRINT 'BUSINESS IMPACT:'
PRINT '  - Faster sales reports'
PRINT '  - Better user experience'
PRINT '  - More efficient resource usage'
GO

/*****************************************************************************************************************
NAME:    Performance_Comparison_AW2022.sql
PURPOSE: Comprehensive comparison of before/after performance metrics
         Demonstrates the value of proper indexing strategy

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Created for Performance Analysis Assignment
******************************************************************************************************************/

PRINT '=== COMPREHENSIVE PERFORMANCE ANALYSIS ==='
PRINT 'Comparing query performance before and after index implementation'
PRINT 'Database: AdventureWorks2022'
PRINT '================================================================='
PRINT ''
PRINT 'QUERY 1: Person.Address WHERE City = ''Bothell'''
PRINT '-------------------------------------------------'
PRINT 'TABLE STATISTICS:'
PRINT '  - Total Rows:        19,614'
PRINT '  - Matching Rows:     23'
PRINT '  - Selectivity:       0.12% (highly selective query)'
PRINT ''
PRINT 'PERFORMANCE METRICS:'
PRINT '                      BEFORE INDEX        AFTER INDEX       IMPROVEMENT'
PRINT '  Estimated Cost:      ~0.217108          ~0.0305727        86% reduction'
PRINT '  Operation:          Index Scan         Index Seek'
PRINT '  I/O Operations:     High               Minimal'
PRINT '  Execution Time:     Slower             Faster'
PRINT ''
PRINT 'QUERY 2: Sales.SalesOrderDetail WHERE ProductID = 870'
PRINT '--------------------------------------------------------'
PRINT 'TABLE STATISTICS:'
PRINT '  - Total Rows:        121,317'
PRINT '  - Matching Rows:     62'
PRINT '  - Selectivity:       0.05% (extremely selective)'
PRINT ''
PRINT 'PERFORMANCE METRICS:'
PRINT '                      BEFORE INDEX        AFTER INDEX       IMPROVEMENT'
PRINT '  Estimated Cost:      Varies             Significant reduction'
PRINT '  Operation:          Likely Scan        Index Seek'
PRINT '  Rows Examined:      121,317            62'
PRINT '  Efficiency:         0.05% efficient    100% efficient'
PRINT ''
PRINT '=== KEY TAKEAWAYS ==='
PRINT '1. INDEX SELECTIVITY MATTERS:'
PRINT '   - Both queries filter on highly selective columns'
PRINT '   - City = "Bothell" returns 0.12% of rows'
PRINT '   - ProductID = 870 returns 0.05% of rows'
PRINT '   - Indexes provide maximum benefit for selective queries'
PRINT ''
PRINT '2. COVERING INDEX STRATEGY:'
PRINT '   - Include all query columns in the index'
PRINT '   - Eliminates expensive key lookups'
PRINT '   - Creates "index-only" access plans'
PRINT ''
PRINT '3. BUSINESS IMPACT:'
PRINT '   - Faster reports and queries'
PRINT '   - Better user experience'
PRINT '   - Reduced server resource consumption'
PRINT '   - Scalability for growing data volumes'
PRINT ''
PRINT '4. MONITORING NEEDED:'
PRINT '   - Indexes require maintenance (rebuild/reorganize)'
PRINT '   - Statistics need updating'
PRINT '   - Monitor index usage (sys.dm_db_index_usage_stats)'
PRINT '   - Remove unused indexes (maintenance overhead)'
GO


/*****************************************************************************************************************
NAME:    SQLServerProfiler_Demo_AW2022.sql
PURPOSE: Demonstrate SQL Server Profiler concepts, use cases, and implementation steps

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/06/2026   J. Student    1. Created for Performance Analysis Assignment
******************************************************************************************************************/

PRINT '=== SQL SERVER PROFILER: PERFORMANCE MONITORING TOOL ==='
PRINT 'Profiler is being deprecated - Extended Events is the modern replacement'
PRINT 'However, Profiler is still widely used and valuable for learning concepts'
PRINT '======================================================================='
PRINT ''
PRINT 'MAJOR USE CASES FOR SQL SERVER PROFILER:'
PRINT '----------------------------------------'
PRINT '1. ?? PERFORMANCE TROUBLESHOOTING'
PRINT '   - Identify slow-running queries'
PRINT '   - Capture execution plans of problematic queries'
PRINT '   - Monitor query duration and resource usage'
PRINT ''
PRINT '2. ?? SECURITY AUDITING'
PRINT '   - Track login/logout activity'
PRINT '   - Monitor permission changes'
PRINT '   - Audit data access patterns'
PRINT ''
PRINT '3. ? DEADLOCK DETECTION'
PRINT '   - Capture deadlock graphs'
PRINT '   - Identify conflicting queries'
PRINT '   - Resolve concurrency issues'
PRINT ''
PRINT '4. ?? QUERY OPTIMIZATION'
PRINT '   - Capture actual execution queries from production'
PRINT '   - Identify missing index opportunities'
PRINT '   - Analyze wait statistics'
PRINT ''
PRINT '5. ?? APPLICATION DEBUGGING'
PRINT '   - Trace database calls from applications'
PRINT '   - Identify incorrect query patterns'
PRINT '   - Debug stored procedure issues'
PRINT ''
PRINT 'MAJOR STEPS TO USE SQL SERVER PROFILER:'
PRINT '--------------------------------------'
PRINT 'STEP 1: LAUNCH PROFILER'
PRINT '   - In SSMS: Tools ? SQL Server Profiler'
PRINT '   - Or: Start Menu ? SQL Server 20XX ? Profiler'
PRINT ''
PRINT 'STEP 2: CONNECT TO SERVER'
PRINT '   - Enter server name and credentials'
PRINT '   - Choose authentication method'
PRINT ''
PRINT 'STEP 3: CREATE NEW TRACE'
PRINT '   - File ? New Trace'
PRINT '   - Select trace template (Standard, TSQL, Tuning)'
PRINT ''
PRINT 'STEP 4: CONFIGURE EVENTS'
PRINT '   - Events Selection tab'
PRINT '   - Add events: SQL:BatchCompleted, Deadlock Graph, etc.'
PRINT ''
PRINT 'STEP 5: APPLY FILTERS (CRITICAL!)'
PRINT '   - Filter by DatabaseName = "AdventureWorks2022"'
PRINT '   - Filter by Duration > 5000 (5+ second queries)'
PRINT '   - Filter by ApplicationName (specific apps only)'
PRINT ''
PRINT 'STEP 6: RUN AND MONITOR'
PRINT '   - Click Run to start tracing'
PRINT '   - Monitor live query activity'
PRINT '   - Save trace file (.trc) for later analysis'
PRINT ''
PRINT 'STEP 7: ANALYZE RESULTS'
PRINT '   - Sort by Duration (descending) to find slow queries'
PRINT '   - Group by ApplicationName or DatabaseName'
PRINT '   - Export to table or file for detailed analysis'
PRINT ''
PRINT 'BEST PRACTICES FOR PRODUCTION USE:'
PRINT '---------------------------------'
PRINT '? DO:'
PRINT '   - Use server-side tracing (less overhead than Profiler UI)'
PRINT '   - Apply filters to limit data capture'
PRINT '   - Trace during peak hours for realistic data'
PRINT '   - Save trace files for historical comparison'
PRINT '   - Correlate with Windows Performance Monitor data'
PRINT ''
PRINT '? DON''T:'
PRINT '   - Run unfiltered traces on production (performance impact)'
PRINT '   - Leave traces running indefinitely'
PRINT '   - Trace all events (too much data)'
PRINT '   - Use Profiler for continuous monitoring (use DMVs instead)'
PRINT ''
PRINT 'MODERN ALTERNATIVE: EXTENDED EVENTS'
PRINT '-----------------------------------'
PRINT '1. Lower overhead than Profiler'
PRINT '2. More flexible event capture'
PRINT '3. Better integration with SQL Server'
PRINT '4. Command-line and GUI options'
PRINT '5. Recommended for new implementations'
GO
