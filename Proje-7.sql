BACKUP DATABASE ETL_project
TO DISK = 'C:\MSSQL\MSSQL_Backups\ETL_project.bak'
WITH FORMAT, INIT, NAME = 'ETL Full Backup';


SELECT 
    database_name, 
    backup_start_date, 
    backup_finish_date, 
    backup_size / 1024 / 1024 AS Size_MB,
    physical_device_name
FROM msdb.dbo.backupset bs
JOIN msdb.dbo.backupmediafamily bmf
    ON bs.media_set_id = bmf.media_set_id
WHERE database_name = 'ETL_project'
ORDER BY backup_finish_date DESC;
