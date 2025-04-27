-- =============================================
-- Section 3: SQL Injection Test Cases
-- =============================================

-- ---------------------------------------------
-- 3.1: Vulnerable Search Simulation
-- ---------------------------------------------
-- This query simulates an unsafe search functionality where user input
-- is directly concatenated into the SQL query, making it vulnerable to SQL Injection.

DECLARE @searchName NVARCHAR(255);
SET @searchName = '<User Input>'; 

DECLARE @sql NVARCHAR(MAX);
SET @sql = 'SELECT * FROM Airbnb_Cleaned_Final WHERE name LIKE ''%' + @searchName + '%''';

-- Vulnerable query execution (DO NOT EXECUTE IN PRODUCTION)
-- EXEC (@sql);

-- ---------------------------------------------
-- 3.2: Normal Search Input
-- ---------------------------------------------
-- Simulating a normal search with a legitimate input (e.g., 'Luxury').

DECLARE @searchName_normal NVARCHAR(255);
SET @searchName_normal = 'Luxury';

DECLARE @sql_normal NVARCHAR(MAX);
SET @sql_normal = 'SELECT * FROM Airbnb_Cleaned_Final WHERE name LIKE ''%' + @searchName_normal + '%''';
EXEC (@sql_normal);
GO

-- The query returns all rows where 'name' contains 'Luxury'.

-- ---------------------------------------------
-- 3.3: Basic SQL Injection - ' OR '1'='1'
-- ---------------------------------------------
-- This test injects an always-true condition to retrieve all records.

DECLARE @searchName_injection1 NVARCHAR(255);
SET @searchName_injection1 = ''' OR ''1''=''1'' --';

DECLARE @sql_injection1 NVARCHAR(MAX);
SET @sql_injection1 = 'SELECT * FROM Airbnb_Cleaned_Final WHERE name LIKE ''%' + @searchName_injection1 + '%''';
EXEC (@sql_injection1);
GO

-- This query returns all records, demonstrating a successful SQL Injection attack.

-- ---------------------------------------------
-- 3.4: SQL Injection Using Comment
-- ---------------------------------------------
-- This test injects a comment symbol (--) to manipulate the WHERE clause.

DECLARE @searchName_injection2 NVARCHAR(255);
SET @searchName_injection2 = 'Luxury'' --';

DECLARE @sql_injection2 NVARCHAR(MAX);
SET @sql_injection2 = 'SELECT * FROM Airbnb_Cleaned_Final WHERE name LIKE ''%' + @searchName_injection2 + '%''';
EXEC (@sql_injection2);
GO

-- This query shows how a comment can disable parts of a SQL statement.

-- ---------------------------------------------
-- 3.5: Secure Search Using Parameterized Query
-- ---------------------------------------------
-- This example uses sp_executesql with parameters to prevent SQL Injection.

DECLARE @searchName_secure NVARCHAR(255);
SET @searchName_secure = ''' OR ''1''=''1'' --';

EXEC sp_executesql 
    N'SELECT * FROM Airbnb_Cleaned_Final WHERE name LIKE ''%'' + @searchName + ''%''',
    N'@searchName NVARCHAR(255)',
    @searchName = @searchName_secure;
GO

-- Even with malicious input, no injection occurs because parameters are treated as data.

-- ---------------------------------------------
-- 3.6: Secure Search With Normal Input
-- ---------------------------------------------
-- Testing the parameterized query with normal input.

DECLARE @searchName_secure_normal NVARCHAR(255);
SET @searchName_secure_normal = 'Luxury';

EXEC sp_executesql 
    N'SELECT * FROM Airbnb_Cleaned_Final WHERE name LIKE ''%'' + @searchName + ''%''',
    N'@searchName NVARCHAR(255)',
    @searchName = @searchName_secure_normal;
GO

-- This correctly returns rows where 'name' contains 'Luxury'.
