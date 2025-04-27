SELECT * FROM Airbnb_Open_Data;

--Data type control
SELECT 
    COLUMN_NAME, 
    DATA_TYPE 
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'Airbnb_Open_Data';

ALTER TABLE Airbnb_Open_Data
ALTER COLUMN service_fee INT;


-- Check total record count and number of NULLs for important columns to assess data completeness
SELECT 
    COUNT(*) AS total_records,
    SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls,
    SUM(CASE WHEN host_identity_verified IS NULL THEN 1 ELSE 0 END) AS host_identity_verified_nulls,
    SUM(CASE WHEN host_name IS NULL THEN 1 ELSE 0 END) AS host_name_nulls,
    SUM(CASE WHEN neighbourhood_group IS NULL THEN 1 ELSE 0 END) AS neighbourhood_group_nulls,
    SUM(CASE WHEN neighbourhood IS NULL THEN 1 ELSE 0 END) AS neighbourhood_nulls,
    SUM(CASE WHEN lat IS NULL THEN 1 ELSE 0 END) AS lat_nulls,
    SUM(CASE WHEN long IS NULL THEN 1 ELSE 0 END) AS long_nulls,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN country_code IS NULL THEN 1 ELSE 0 END) AS country_code_nulls,
    SUM(CASE WHEN instant_bookable IS NULL THEN 1 ELSE 0 END) AS instant_bookable_nulls,
    SUM(CASE WHEN cancellation_policy IS NULL THEN 1 ELSE 0 END) AS cancellation_policy_nulls,
    SUM(CASE WHEN room_type IS NULL THEN 1 ELSE 0 END) AS room_type_nulls,
    SUM(CASE WHEN construction_year IS NULL THEN 1 ELSE 0 END) AS construction_year_nulls,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_nulls,
    SUM(CASE WHEN service_fee IS NULL THEN 1 ELSE 0 END) AS service_fee_nulls,
    SUM(CASE WHEN minimum_nights IS NULL THEN 1 ELSE 0 END) AS minimum_nights_nulls,
    SUM(CASE WHEN number_of_reviews IS NULL THEN 1 ELSE 0 END) AS number_of_reviews_nulls,
    SUM(CASE WHEN last_review IS NULL THEN 1 ELSE 0 END) AS last_review_nulls,
    SUM(CASE WHEN reviews_per_month IS NULL THEN 1 ELSE 0 END) AS reviews_per_month_nulls,
    SUM(CASE WHEN review_rate_number IS NULL THEN 1 ELSE 0 END) AS review_rate_number_nulls,
    SUM(CASE WHEN calculated_host_listings_count IS NULL THEN 1 ELSE 0 END) AS calculated_host_listings_count_nulls,
    SUM(CASE WHEN availability_365 IS NULL THEN 1 ELSE 0 END) AS availability_365_nulls,
    SUM(CASE WHEN house_rules IS NULL THEN 1 ELSE 0 END) AS house_rules_nulls,
    SUM(CASE WHEN license IS NULL THEN 1 ELSE 0 END) AS license_nulls
FROM Airbnb_Open_Data;

-- Fill missing categorical (text) fields with default placeholder values
UPDATE Airbnb_Open_Data SET name = 'Unknown' WHERE name IS NULL;
UPDATE Airbnb_Open_Data SET host_identity_verified = 'Unverified' WHERE host_identity_verified IS NULL;
UPDATE Airbnb_Open_Data SET host_name = 'Unknown' WHERE host_name IS NULL;
UPDATE Airbnb_Open_Data SET neighbourhood_group = 'Not specified' WHERE neighbourhood_group IS NULL;
UPDATE Airbnb_Open_Data SET neighbourhood = 'Not specified' WHERE neighbourhood IS NULL;
UPDATE Airbnb_Open_Data SET country = 'Unknown' WHERE country IS NULL;
UPDATE Airbnb_Open_Data SET country_code = 'Unknown' WHERE country_code IS NULL;
UPDATE Airbnb_Open_Data SET cancellation_policy = 'Not specified' WHERE cancellation_policy IS NULL;
UPDATE Airbnb_Open_Data SET house_rules = 'Not Provided' WHERE house_rules IS NULL;
UPDATE Airbnb_Open_Data SET license = 'Unknown' WHERE license IS NULL;

-- Fill missing numeric and boolean fields with logical default values
UPDATE Airbnb_Open_Data SET instant_bookable = 0 WHERE instant_bookable IS NULL;
UPDATE Airbnb_Open_Data SET reviews_per_month = 0.0 WHERE reviews_per_month IS NULL;
UPDATE Airbnb_Open_Data SET number_of_reviews = 0 WHERE number_of_reviews IS NULL;

-- Remove records with missing latitude or longitude values (18 data)
DELETE FROM Airbnb_Open_Data
WHERE lat IS NULL OR long IS NULL;

--construction year 214
--price	247
--availability_365	448	
--service_fee	273	
--review_rate_number	326
--calculated_host_listings_count	319
--last_review 15892
--min nights 1?


-- Detect duplicate records based on all relevant fields
SELECT 
    *, COUNT(*) AS duplicate_count
FROM Airbnb_Open_Data
GROUP BY 
    id, name, host_id, host_name, neighbourhood_group, neighbourhood, lat, long,
    country, country_code, instant_bookable, cancellation_policy, room_type,
    construction_year, price, service_fee, minimum_nights, number_of_reviews,
    last_review, reviews_per_month, review_rate_number, calculated_host_listings_count,
    availability_365, house_rules, license, host_identity_verified
HAVING COUNT(*) > 1;

-- Create a backup copy of the table before making major changes
SELECT * INTO Airbnb_Open_Data_Backup FROM Airbnb_Open_Data;

-- Add a temporary row ID to uniquely identify each record
ALTER TABLE Airbnb_Open_Data ADD temp_row_id INT IDENTITY(1,1);

-- Remove duplicate records while keeping the first occurrence
WITH DuplicateCheck AS (
    SELECT temp_row_id,
           ROW_NUMBER() OVER (
               PARTITION BY 
                   id, name, host_id, host_name, neighbourhood_group, neighbourhood, lat, long,
                   country, country_code, instant_bookable, cancellation_policy, room_type,
                   construction_year, price, service_fee, minimum_nights, number_of_reviews,
                   last_review, reviews_per_month, review_rate_number, calculated_host_listings_count,
                   availability_365, house_rules, license, host_identity_verified
               ORDER BY temp_row_id
           ) AS rn
    FROM Airbnb_Open_Data
)
DELETE FROM Airbnb_Open_Data
WHERE temp_row_id IN (
    SELECT temp_row_id FROM DuplicateCheck WHERE rn > 1
);

-- Drop the temporary row ID column after removing duplicates
ALTER TABLE Airbnb_Open_Data DROP COLUMN temp_row_id;


-- Drop the license column as it contains mostly missing or irrelevant data
SELECT * FROM Airbnb_Open_Data
where license != 'Unknown';

ALTER TABLE Airbnb_Open_Data
DROP COLUMN license;

-- Drop country and country_code columns since all records are from the United States
SELECT * FROM Airbnb_Open_Data
where country != 'United States';

ALTER TABLE Airbnb_Open_Data
DROP COLUMN country, country_code;


-- Encode host_identity_verified as a binary field and rename it to host_verified_flag
SELECT DISTINCT host_identity_verified FROM Airbnb_Open_Data;

SELECT * INTO Airbnb_Open_Data_Backup2 FROM Airbnb_Open_Data;

UPDATE Airbnb_Open_Data
SET host_identity_verified = 
    CASE 
        WHEN host_identity_verified = 'verified' THEN '1'
        ELSE '0'
    END;

ALTER TABLE Airbnb_Open_Data
ALTER COLUMN host_identity_verified BIT;

EXEC sp_rename 'Airbnb_Open_Data.host_identity_verified', 'host_verified_flag', 'COLUMN';


-- Fix Excel-related errors in the house_rules column
SELECT * FROM Airbnb_Open_Data
WHERE house_rules = '#NAME?';

UPDATE Airbnb_Open_Data
SET house_rules = 'Not Provided'
WHERE house_rules = '#NAME?';



--Feature derivation - creating total price column
ALTER TABLE Airbnb_Open_Data
ADD total_price INT;

UPDATE Airbnb_Open_Data
SET total_price = price + service_fee;


-- Remove records with unrealistic minimum_nights values greater than 366 (handling outliers)
SELECT * FROM Airbnb_Open_Data
WHERE minimum_nights > 366;

DELETE FROM Airbnb_Open_Data
WHERE minimum_nights > 366;


--Feature derivation - creating price category
SELECT DISTINCT
    PERCENTILE_CONT(0.33) WITHIN GROUP (ORDER BY price) OVER () AS p33,
    PERCENTILE_CONT(0.66) WITHIN GROUP (ORDER BY price) OVER () AS p66
FROM Airbnb_Open_Data
WHERE price IS NOT NULL;

ALTER TABLE Airbnb_Open_Data
ADD price_category VARCHAR(20);

UPDATE Airbnb_Open_Data
SET price_category =
    CASE 
        WHEN price IS NULL THEN 'unknown'
        WHEN price < 400 THEN 'cheap'
        WHEN price BETWEEN 400 AND 800 THEN 'medium'
        ELSE 'expensive'
    END;


-- Correct invalid availability_365 and minimum_nights values to ensure logical consistency
SELECT *
FROM Airbnb_Open_Data
WHERE availability_365 > 365;

UPDATE Airbnb_Open_Data
SET availability_365 = 365
WHERE availability_365 > 365;

SELECT *
FROM Airbnb_Open_Data
WHERE availability_365 < 0;

UPDATE Airbnb_Open_Data
SET availability_365 = 0
WHERE availability_365 < 0;

SELECT *
FROM Airbnb_Open_Data
WHERE minimum_nights is NULL or minimum_nights < 1;

UPDATE Airbnb_Open_Data
SET minimum_nights = 1
WHERE minimum_nights IS NULL or minimum_nights < 1;


-- Add data validation constraints to enforce logical value ranges
ALTER TABLE Airbnb_Open_Data
ADD CONSTRAINT chk_availability_range
CHECK (availability_365 BETWEEN 0 AND 365);

ALTER TABLE Airbnb_Open_Data
ADD CONSTRAINT chk_review_rate_range
CHECK (review_rate_number BETWEEN 1 AND 5);

ALTER TABLE Airbnb_Open_Data
ADD CONSTRAINT chk_price_nonnegative
CHECK (price >= 0);

ALTER TABLE Airbnb_Open_Data
ADD CONSTRAINT chk_minimum_nights
CHECK (minimum_nights >= 1);

ALTER TABLE Airbnb_Open_Data
ADD CONSTRAINT chk_service_fee_nonnegative
CHECK (service_fee >= 0);

ALTER TABLE Airbnb_Open_Data
ADD CONSTRAINT chk_reviews_per_month
CHECK (reviews_per_month >= 0);


--Load
SELECT * INTO Airbnb_Cleaned_Final
FROM Airbnb_Open_Data;
