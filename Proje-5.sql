CREATE DATABASE Airbnb_DB1;
GO

CREATE DATABASE Airbnb_DB2;
GO


-- Airbnb_DB1'e kopyala
SELECT * INTO Airbnb_DB1.dbo.Airbnb_Open_Data
FROM ETL_project.dbo.Airbnb_Open_Data;

-- Airbnb_DB2'ye kopyala
SELECT * INTO Airbnb_DB2.dbo.Airbnb_Open_Data
FROM ETL_project.dbo.Airbnb_Open_Data;


USE Airbnb_DB1;
GO

CREATE VIEW CombinedAirbnbData AS
SELECT * FROM Airbnb_DB1.dbo.Airbnb_Open_Data
UNION ALL
SELECT * FROM Airbnb_DB2.dbo.Airbnb_Open_Data;


BEGIN TRY
    -- DB1 erişilebilir ise oradan veri çek
    SELECT TOP 10 * FROM Airbnb_DB1.dbo.Airbnb_Open_Data;
END TRY
BEGIN CATCH
    -- DB1 başarısızsa DB2'den veri çek
    SELECT TOP 10 * FROM Airbnb_DB2.dbo.Airbnb_Open_Data;
END CATCH;
