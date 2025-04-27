-- Switch to the master database (required for server-level audit configuration)
USE master;
GO

-- Create a server-level audit named 'ServerAudit_ETL'
-- Log files will be written to the specified folder
-- MAXSIZE limits each log file to 100 MB
-- MAX_ROLLOVER_FILES = UNLIMITED allows unlimited log rotation
CREATE SERVER AUDIT ServerAudit_ETL
TO FILE 
(
    FILEPATH = 'C:\MSSQL\MSSQL_AuditLogs\', 
    MAXSIZE = 100 MB, 
    MAX_ROLLOVER_FILES = UNLIMITED
);
GO

-- Switch to the target user database where activity will be audited
USE [ETL_project]; 
GO

-- Create a database audit specification for SELECT operations
-- Applies to all users (public) on the current database
CREATE DATABASE AUDIT SPECIFICATION AuditSelectOnAirbnb
FOR SERVER AUDIT ServerAudit_ETL
ADD (SELECT ON DATABASE::ETL_Project BY [public])
WITH (STATE = ON);  -- Enables the audit specification
GO

-- Start the server audit to begin logging activity
ALTER SERVER AUDIT ServerAudit_ETL
WITH (STATE = ON);
GO

-- Test query: generate a SELECT event to verify audit logging
SELECT TOP 10 * FROM Airbnb_Cleaned_Final;

-- Read audit logs from the specified folder and display them
SELECT *
FROM sys.fn_get_audit_file('C:\MSSQL\MSSQL_AuditLogs\*.sqlaudit', DEFAULT, DEFAULT);
