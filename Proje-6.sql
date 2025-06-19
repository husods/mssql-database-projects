-- Yeni sürüm için ayrı bir veritabanı oluşturuyoruz
CREATE DATABASE Airbnb_V2;
GO


-- Airbnb_V2 veritabanını kullanıyoruz
USE Airbnb_V2;
GO

-- Tabloyu silip yeniden oluşturuyorsan:
DROP TABLE AirbnbData;

-- Ardından yeniden oluştur:
CREATE TABLE AirbnbData (
    id INT,
    name NVARCHAR(255),
    host_id BIGINT,  -- ✅ INT yerine BIGINT
    host_name NVARCHAR(100),
    neighbourhood NVARCHAR(100),
    latitude FLOAT,
    longitude FLOAT,
    room_type NVARCHAR(50),
    price DECIMAL(10,2),
    minimum_nights INT,
    number_of_reviews INT,
    last_review DATE,
    reviews_per_month FLOAT,
    calculated_host_listings_count INT,
    availability_365 INT,
    house_rules NVARCHAR(MAX),
    updated_at DATETIME
);


-- Airbnb_Open_Data tablosundan doğru sütun adlarıyla veri aktarımı yapılıyor
-- Airbnb_V2 veritabanındaki AirbnbData tablosuna yazılır
INSERT INTO Airbnb_V2.dbo.AirbnbData (
    id, name, host_id, host_name, neighbourhood,
    latitude, longitude, room_type, price, minimum_nights,
    number_of_reviews, last_review, reviews_per_month,
    calculated_host_listings_count, availability_365,
    house_rules, updated_at
)
-- host_id artık BIGINT olduğu için dönüştürmeye gerek yok
SELECT 
    id, 
    name, 
    host_id,               -- dönüşüm kaldırıldı
    host_name, 
    neighbourhood,
    lat AS latitude,       
    long AS longitude,     
    room_type, 
    TRY_CAST(price AS DECIMAL(10,2)), 
    minimum_nights, 
    number_of_reviews, 
    last_review,
    reviews_per_month, 
    calculated_host_listings_count,
    availability_365, 
    house_rules, 
    GETDATE()
FROM ETL_project.dbo.Airbnb_Open_Data;


USE Airbnb_V2;
GO

-- DDL işlemlerini kaydedeceğimiz log tablosu
CREATE TABLE DDL_Audit (
    id INT IDENTITY(1,1) PRIMARY KEY,
    event_type NVARCHAR(100),
    object_name NVARCHAR(255),
    object_type NVARCHAR(100),
    command_text NVARCHAR(MAX),
    event_time DATETIME DEFAULT GETDATE()
);


-- Veritabanı seviyesinde DDL olaylarını dinleyen trigger
CREATE TRIGGER trg_DDL_Audit
ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS
AS
BEGIN
    INSERT INTO Airbnb_V2.dbo.DDL_Audit (
        event_type, object_name, object_type, command_text
    )
    SELECT 
        EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
        EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(255)'),
        EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)'),
        EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)');
END;


-- Test amaçlı yeni tablo oluştur
CREATE TABLE TestDDL (
    id INT
);


SELECT * FROM Airbnb_V2.dbo.DDL_Audit ORDER BY event_time DESC;


USE Airbnb_V2;
GO

-- En pahalı 5 East Harlem kaydı
SELECT TOP 5 name, neighbourhood, price
FROM AirbnbData
WHERE neighbourhood = 'East Harlem'
ORDER BY price DESC;


BACKUP DATABASE Airbnb_V2
TO DISK = 'C:\MSSQL\MSSQL_Backups\Airbnb_V2.bak';


USE ETL_project;
GO
EXEC sp_help 'Airbnb_Open_Data';


USE Airbnb_V2;
GO
EXEC sp_help 'AirbnbData';


-- V1 yapısı
EXEC sp_help 'ETL_project.dbo.Airbnb_Open_Data';

-- V2 yapısı
USE Airbnb_V2;
EXEC sp_help 'AirbnbData';


SELECT * FROM Airbnb_V2.dbo.DDL_Audit ORDER BY event_time DESC;
