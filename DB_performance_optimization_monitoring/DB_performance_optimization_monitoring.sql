SELECT TOP 10 * FROM Airbnb_Cleaned_Final;

CREATE TABLE DMV_Performance_Initial (
    execution_count INT,
    total_logical_reads BIGINT,
    total_worker_time BIGINT,
    total_elapsed_time BIGINT,
    query_text NVARCHAR(MAX)
);

INSERT INTO DMV_Performance_Initial
SELECT TOP 10
    qs.execution_count,
    qs.total_logical_reads,
    qs.total_worker_time,
    qs.total_elapsed_time,
    SUBSTRING(qt.text, qs.statement_start_offset/2,
       (CASE WHEN qs.statement_end_offset = -1
        THEN LEN(CONVERT(nvarchar(MAX), qt.text)) * 2
        ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) AS query_text
FROM 
    sys.dm_exec_query_stats qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY 
    qs.total_worker_time DESC;


CREATE TABLE DMV_Performance_Log (
    sorgu_adi NVARCHAR(100),
    execution_count INT,
    total_logical_reads BIGINT,
    total_worker_time BIGINT,
    total_elapsed_time BIGINT,
    query_text NVARCHAR(MAX),
    kayit_zamani DATETIME DEFAULT GETDATE()
);

-- SORGUNUN KENDİSİ (manuel çalıştırılmalı)
SELECT *
FROM Airbnb_Cleaned_Final
WHERE house_rules LIKE '%smoking%';


-- SADECE İLGİLİ SORGUNUN DMV VERİSİ
INSERT INTO DMV_Performance_Log (sorgu_adi, execution_count, total_logical_reads, total_worker_time, total_elapsed_time, query_text)
SELECT TOP 1
    'Sorgu_1_LIKE',
    qs.execution_count,
    qs.total_logical_reads,
    qs.total_worker_time,
    qs.total_elapsed_time,
    SUBSTRING(qt.text, qs.statement_start_offset/2,
       (CASE WHEN qs.statement_end_offset = -1
        THEN LEN(CONVERT(nvarchar(MAX), qt.text)) * 2
        ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)
FROM 
    sys.dm_exec_query_stats qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) qt
WHERE 
    qt.text LIKE '%house_rules%' AND qt.text LIKE '%smoking%'
ORDER BY 
    qs.total_worker_time DESC;


-- SORGUNUN KENDİSİ (manuel çalıştırılmalı)
SELECT neighbourhood_group, AVG(price) AS average_price
FROM Airbnb_Cleaned_Final
GROUP BY neighbourhood_group;


-- SADECE İLGİLİ SORGUNUN DMV VERİSİ
INSERT INTO DMV_Performance_Log (sorgu_adi, execution_count, total_logical_reads, total_worker_time, total_elapsed_time, query_text)
SELECT TOP 1
    'Sorgu_2_GROUPBY',
    qs.execution_count,
    qs.total_logical_reads,
    qs.total_worker_time,
    qs.total_elapsed_time,
    SUBSTRING(qt.text, qs.statement_start_offset/2,
       (CASE WHEN qs.statement_end_offset = -1
        THEN LEN(CONVERT(nvarchar(MAX), qt.text)) * 2
        ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)
FROM 
    sys.dm_exec_query_stats qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) qt
WHERE 
    qt.text LIKE '%neighbourhood_group%' AND qt.text LIKE '%AVG(price)%'
ORDER BY 
    qs.total_worker_time DESC;


-- SORGUNUN KENDİSİ (manuel çalıştırılmalı)
SELECT TOP 100 *
FROM Airbnb_Cleaned_Final
ORDER BY price DESC;


-- SADECE İLGİLİ SORGUNUN DMV VERİSİ
INSERT INTO DMV_Performance_Log (sorgu_adi, execution_count, total_logical_reads, total_worker_time, total_elapsed_time, query_text)
SELECT TOP 1
    'Sorgu_3_ORDERBY',
    qs.execution_count,
    qs.total_logical_reads,
    qs.total_worker_time,
    qs.total_elapsed_time,
    SUBSTRING(qt.text, qs.statement_start_offset/2,
       (CASE WHEN qs.statement_end_offset = -1
        THEN LEN(CONVERT(nvarchar(MAX), qt.text)) * 2
        ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)
FROM 
    sys.dm_exec_query_stats qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) qt
WHERE 
    qt.text LIKE '%ORDER BY%' AND qt.text LIKE '%price%'
ORDER BY 
    qs.total_worker_time DESC;


-- SORGUNUN KENDİSİ (manuel çalıştırılmalı)
SELECT *
FROM Airbnb_Cleaned_Final
WHERE price > (
    SELECT AVG(price) FROM Airbnb_Cleaned_Final
);


-- SADECE İLGİLİ SORGUNUN DMV VERİSİ
INSERT INTO DMV_Performance_Log (sorgu_adi, execution_count, total_logical_reads, total_worker_time, total_elapsed_time, query_text)
SELECT TOP 1
    'Sorgu_4_SUBQUERY',
    qs.execution_count,
    qs.total_logical_reads,
    qs.total_worker_time,
    qs.total_elapsed_time,
    SUBSTRING(qt.text, qs.statement_start_offset/2,
       (CASE WHEN qs.statement_end_offset = -1
        THEN LEN(CONVERT(nvarchar(MAX), qt.text)) * 2
        ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)
FROM 
    sys.dm_exec_query_stats qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) qt
WHERE 
    qt.text LIKE '%SELECT AVG(price)%' AND qt.text LIKE '%price >%'
ORDER BY 
    qs.total_worker_time DESC;


-- SORGUNUN KENDİSİ (indeks OLMADAN çalıştır)
SELECT *
FROM Airbnb_Cleaned_Final
WHERE reviews_per_month > 1;


-- SORGUNUN PERFORMANS VERİSİNİ LOG TABLOSUNA EKLER (indexesiz hali)
INSERT INTO DMV_Performance_Log (sorgu_adi, execution_count, total_logical_reads, total_worker_time, total_elapsed_time, query_text)
SELECT TOP 1
    'Sorgu_5_INDEX_BEFORE',
    qs.execution_count,
    qs.total_logical_reads,
    qs.total_worker_time,
    qs.total_elapsed_time,
    SUBSTRING(qt.text, qs.statement_start_offset/2,
       (CASE WHEN qs.statement_end_offset = -1
        THEN LEN(CONVERT(nvarchar(MAX), qt.text)) * 2
        ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)
FROM 
    sys.dm_exec_query_stats qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) qt
WHERE 
    qt.text LIKE '%reviews_per_month%' AND qt.text LIKE '%> 1%'
ORDER BY 
    qs.total_worker_time DESC;



-- İNDEKS OLUŞTURMA
CREATE NONCLUSTERED INDEX idx_reviews_per_month
ON Airbnb_Cleaned_Final (reviews_per_month);


-- AYNI SORGUNUN İNDEKSLİ HALİ
SELECT *
FROM Airbnb_Cleaned_Final
WHERE reviews_per_month > 1;


-- PERFORMANS VERİSİ (İNDEKS SONRASI)
INSERT INTO DMV_Performance_Log (sorgu_adi, execution_count, total_logical_reads, total_worker_time, total_elapsed_time, query_text)
SELECT TOP 1
    'Sorgu_5_INDEX_AFTER',
    qs.execution_count,
    qs.total_logical_reads,
    qs.total_worker_time,
    qs.total_elapsed_time,
    SUBSTRING(qt.text, qs.statement_start_offset/2,
       (CASE WHEN qs.statement_end_offset = -1
        THEN LEN(CONVERT(nvarchar(MAX), qt.text)) * 2
        ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)
FROM 
    sys.dm_exec_query_stats qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) qt
WHERE 
    qt.text LIKE '%reviews_per_month%' AND qt.text LIKE '%> 1%'
ORDER BY 
    qs.total_worker_time DESC;


SELECT sorgu_adi, total_worker_time, total_logical_reads, total_elapsed_time
FROM DMV_Performance_Log
WHERE sorgu_adi IN ('Sorgu_5_INDEX_BEFORE', 'Sorgu_5_INDEX_AFTER');


-- Tüm sorgular için plan cache’i temizlenir (sunucu genelinde etkiler)
-- Test ortamındaysan güvenlidir
DBCC FREEPROCCACHE;

-- İNDEKSLE TEST
SELECT *
FROM Airbnb_Cleaned_Final
WHERE reviews_per_month > 1;


-- SADECE 1 kere çalıştırılmış versiyonu loga ekle
INSERT INTO DMV_Performance_Log (sorgu_adi, execution_count, total_logical_reads, total_worker_time, total_elapsed_time, query_text)
SELECT TOP 1
    'Sorgu_5_INDEX_AFTER_RETEST',
    qs.execution_count,
    qs.total_logical_reads,
    qs.total_worker_time,
    qs.total_elapsed_time,
    SUBSTRING(qt.text, qs.statement_start_offset/2,
       (CASE WHEN qs.statement_end_offset = -1
        THEN LEN(CONVERT(nvarchar(MAX), qt.text)) * 2
        ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)
FROM 
    sys.dm_exec_query_stats qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) qt
WHERE 
    qt.text LIKE '%reviews_per_month%' AND qt.text LIKE '%> 1%'
ORDER BY 
    qs.total_worker_time DESC;


SELECT sorgu_adi, execution_count, total_logical_reads, total_worker_time, total_elapsed_time
FROM DMV_Performance_Log
WHERE sorgu_adi LIKE 'Sorgu_5%';


-- SORGUNUN KENDİSİ
SELECT TOP 50 neighbourhood, price, number_of_reviews
FROM Airbnb_Cleaned_Final
WHERE availability_365 > 100 AND number_of_reviews > 50
ORDER BY price DESC;


-- DMV LOG (SORGUNUN PERFORMANSI)
INSERT INTO DMV_Performance_Log (sorgu_adi, execution_count, total_logical_reads, total_worker_time, total_elapsed_time, query_text)
SELECT TOP 1
    'Sorgu_6_MULTIFILTER_ORDER',
    qs.execution_count,
    qs.total_logical_reads,
    qs.total_worker_time,
    qs.total_elapsed_time,
    SUBSTRING(qt.text, qs.statement_start_offset/2,
       (CASE WHEN qs.statement_end_offset = -1
        THEN LEN(CONVERT(nvarchar(MAX), qt.text)) * 2
        ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)
FROM 
    sys.dm_exec_query_stats qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) qt
WHERE 
    qt.text LIKE '%availability_365%' AND qt.text LIKE '%number_of_reviews%' AND qt.text LIKE '%ORDER BY%'
ORDER BY 
    qs.total_worker_time DESC;


-- Tablo boyutunu ve satır sayısını gösterir
EXEC sp_spaceused 'Airbnb_Cleaned_Final';


-- 1. Yeni bir rol oluştur
CREATE ROLE RaporGormeYetkisi;

-- 2. Bu role sadece SELECT yetkisi ver (örnek tablo)
GRANT SELECT ON Airbnb_Cleaned_Final TO RaporGormeYetkisi;

-- Kullanıcıyı oluştur
CREATE USER ogr1 WITHOUT LOGIN;

-- 3. Mevcut bir kullanıcıyı bu role ata (örnek kullanıcı: ogrenci1)
EXEC sp_addrolemember 'RaporGormeYetkisi', 'ogr1';


-- RaporGormeYetkisi rolüne bu tablo için hangi yetki verilmiş?
-- ogr1 kullanıcısı tablodan veri okuyabilir mi?
SELECT HAS_PERMS_BY_NAME('Airbnb_Cleaned_Final', 'OBJECT', 'SELECT') AS ogr1_can_select;

