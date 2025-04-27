-- =============================================
-- Section 1: Access Management - User Creation and Authorization
-- =============================================

-- List all database users
SELECT name FROM sys.database_principals WHERE type_desc = 'SQL_USER';
-- List all database users
SELECT name FROM sys.server_principals WHERE type_desc = 'SQL_LOGIN';

-- Create a new server login
CREATE LOGIN airbnb_reader WITH PASSWORD = 'Airbnb@1234';
USE ETL_project;
-- Create a database user mapped to the login
CREATE USER airbnb_reader FOR LOGIN airbnb_reader;

-- Grant SELECT permission on the dbo schema to the user
GRANT SELECT ON SCHEMA::dbo TO airbnb_reader;

-- Check the current session's login name
SELECT SUSER_NAME();

-- List the roles assigned to the specific login
SELECT dp1.name AS LoginName, sp1.name AS RoleName
FROM sys.server_role_members rm
JOIN sys.server_principals sp1 ON rm.role_principal_id = sp1.principal_id
JOIN sys.server_principals dp1 ON rm.member_principal_id = dp1.principal_id
WHERE dp1.name = 'airbnb_reader';

-- The following query should succeed
SELECT TOP 10 * FROM Airbnb_Cleaned_Final;

-- The following query should fail due to restricted permissions
INSERT INTO Airbnb_Cleaned_Final(name) VALUES ('Test');

-- Revoke SELECT permission from the user
USE ETL_project;
REVOKE SELECT ON SCHEMA::dbo FROM airbnb_reader;
GO

-- Check database fixed roles
USE ETL_project;
SELECT name, type_desc FROM sys.database_principals WHERE is_fixed_role = 1;

-- Assign db_datareader role to the user
USE ETL_project;
ALTER ROLE db_datareader ADD MEMBER airbnb_reader;
GO

-- =============================================
-- Section 2: Data Encryption - Creating Master Key and Certificate
-- =============================================

-- Create Master Key (only if not already created)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'HusoMaster3414!';
GO

-- Create certificate for Transparent Data Encryption (TDE)
CREATE CERTIFICATE TDE_Cert WITH SUBJECT = 'TDE Database Encryption Certificate';
GO

USE master;
GO
SELECT *
FROM sys.symmetric_keys
WHERE name = '##MS_DatabaseMasterKey##';
GO

-- Create Database Encryption Key using the server certificate
USE ETL_project;
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE TDE_Cert;
GO

-- Backup the certificate and its private key
USE master;
GO
BACKUP CERTIFICATE TDE_Cert TO FILE = 'C:\\MSSQL_Backups\\TDECertBackup.cer'
WITH PRIVATE KEY (
    FILE = 'C:\\MSSQL_Backups\\TDECertPrivateKeyBackup.pvk',
    ENCRYPTION BY PASSWORD = 'CertificateBackupPassword!'
);
GO

-- Backup the master key
BACKUP MASTER KEY TO FILE = 'C:\\MSSQL_Backups\\MasterKeyBackup.mky'
ENCRYPTION BY PASSWORD = 'MasterKeyBackupPassword!';
GO
