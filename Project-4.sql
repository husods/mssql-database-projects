-- 🔐 SQL Server – Backup and Disaster Recovery Script

-- 🔹 Step 1: Full Backup
BACKUP DATABASE ETL_project
TO DISK = 'C:\MSSQL\MSSQL_Backups\ETL_project_Full.bak'
WITH INIT, COMPRESSION, STATS = 10;
-- Takes a full backup of the database, overwriting any existing backup file.
-- Compression reduces file size, and STATS displays progress.

-- 🔹 Step 2: Differential Backup
BACKUP DATABASE ETL_project
TO DISK = 'C:\MSSQL\MSSQL_Backups\ETL_project_Diff.bak'
WITH DIFFERENTIAL, INIT, COMPRESSION, STATS = 10;
-- Creates a differential backup since the last full backup.

-- 🔹 Step 3: Set Recovery Model to FULL
ALTER DATABASE ETL_project SET RECOVERY FULL;
-- Enables transaction log backups and point-in-time restore capability.

-- 🔹 Step 4: Transaction Log Backup
BACKUP LOG ETL_project
TO DISK = 'C:\MSSQL\MSSQL_Backups\ETL_project_Log.trn'
WITH INIT, STATS = 10;
-- Backs up the transaction log. Required for point-in-time recovery.

-- 🔹 Step 5: Simulate Disaster – Drop the Database
ALTER DATABASE ETL_project
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
-- Disconnects all users and rolls back running transactions.

DROP DATABASE ETL_project;
-- Deletes the database to simulate data loss.

-- 🔹 Step 6: Restore Full Backup (No Recovery Mode)
RESTORE DATABASE ETL_project
FROM DISK = 'C:\MSSQL\MSSQL_Backups\ETL_project_Full.bak'
WITH NORECOVERY;
-- Restores the full backup, but leaves the database in restoring state.

-- 🔹 Step 7: Restore Differential Backup (No Recovery Mode)
RESTORE DATABASE ETL_project
FROM DISK = 'C:\MSSQL\MSSQL_Backups\ETL_project_Diff.bak'
WITH NORECOVERY;
-- Applies the differential backup on top of the full backup.

-- 🔹 Step 8: Restore Transaction Log Backup (Complete Recovery)
RESTORE LOG ETL_project
FROM DISK = 'C:\MSSQL\MSSQL_Backups\ETL_project_Log.trn'
WITH RECOVERY;
-- Completes the restore process and brings the database online.

-- 🔹 Step 9: Verify Backup Integrity
RESTORE VERIFYONLY
FROM DISK = 'C:\MSSQL\MSSQL_Backups\ETL_project_Full.bak';
-- Checks the physical integrity of the backup file without restoring it.
