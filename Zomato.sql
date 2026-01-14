create database Zomato;
use zomato;
SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

CREATE TABLE Zomato_source (
  RestaurantID INT,
  RestaurantName VARCHAR(255),
  CountryCode INT,
  Country VARCHAR(100),
  City VARCHAR(100),
  Address TEXT,
  Locality VARCHAR(255),
  LocalityVerbose VARCHAR(255),
  Longitude DOUBLE,
  Latitude DOUBLE,
  Cuisines VARCHAR(255),
  Currency VARCHAR(50),
  Has_Table_booking VARCHAR(10),
  Has_Online_delivery VARCHAR(10),
  Is_delivering_now VARCHAR(10),
  Switch_to_order_menu VARCHAR(10),
  Price_range INT,
  Votes INT,
  Average_Cost_for_two INT,
  Rating VARCHAR(20),
  Datekey date
);

LOAD DATA LOCAL INFILE 'C:\\Users\\LENOVO\\Desktop\\Zomato\\Excel\\Source.csv'
INTO TABLE zomato_source
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

show tables;
DESCRIBE zomato_source;
SELECT COUNT(*) FROM zomato_source;

-- 1
-- Create Country Map Table
CREATE TABLE country_table AS
SELECT DISTINCT CountryCode, Country
FROM zomato_source;

select * from country_table;

-- 2 
-- Build Calendar Table (Using Datekey)
CREATE TABLE calendar_table AS
SELECT 
    Datekey,
    YEAR(Datekey) AS Years,
    MONTH(Datekey) AS Monthno,
    DATE_FORMAT(Datekey,'%M') AS Monthfullname,
    CONCAT('Q', QUARTER(Datekey)) AS Quarters,
    DATE_FORMAT(Datekey,'%Y-%b') AS YearMonth,
    DAYOFWEEK(Datekey) AS Weekdayno,
    DATE_FORMAT(Datekey,'%W') AS Weekdayname,

    /* Financial Month (April – March) */
    CASE
        WHEN MONTH(Datekey) >= 4 THEN MONTH(Datekey) - 3
        ELSE MONTH(Datekey) + 9
    END AS FinancialMonth,

    /* Financial Quarter */
    CASE
        WHEN MONTH(Datekey) BETWEEN 4 AND 6 THEN 'FQ1'
        WHEN MONTH(Datekey) BETWEEN 7 AND 9 THEN 'FQ2'
        WHEN MONTH(Datekey) BETWEEN 10 AND 12 THEN 'FQ3'
        ELSE 'FQ4'
    END AS FinancialQuarter
FROM zomato_source;

Select * from calendar_table;

-- 3 Restaurants by City & Country
SELECT
    Country,
    City,
    COUNT(RestaurantID) AS Total_Restaurants
FROM Zomato_source
GROUP BY Country, City
ORDER BY Total_Restaurants DESC;

SELECT Country,
       COUNT(*) AS total_restaurants
FROM zomato_source
GROUP BY Country
order by total_restaurants desc;

-- 4 Restaurants Opening by Year / Quarter / Month
-- Year
SELECT YEAR(Datekey) AS Years, 
COUNT(*) AS Openings
FROM zomato_source
GROUP BY YEAR(Datekey)
order by years;

-- Quarter
SELECT CONCAT('Q', QUARTER(Datekey)) AS Quarters, COUNT(*) as Total_Restaurants
FROM zomato_source
GROUP BY Quarters
order by Quarters;

SELECT
    YEAR(Datekey) AS Years,
    CONCAT('Q', QUARTER(Datekey)) AS Quarters,
    COUNT(RestaurantID) AS Restaurant_Count
FROM Zomato_source
GROUP BY Years, Quarters
order by years;

-- Month
Select Month_name,Total_restaurants from(
select Month(datekey)Mno, monthname(datekey) as Month_Name,
COUNT(*) AS Total_restaurants
from zomato_source
group by mno,Month_name 
order by mno)z; 

-- 5 Count of Restaurants by Average Ratings
SELECT rating, COUNT(*) Total_Restaurants
FROM zomato_source
GROUP BY rating
order by rating;

-- 6 Average Price Buckets
SELECT 
 CASE
  WHEN Average_Cost_For_Two <= 500 THEN '0-500'
  WHEN Average_Cost_For_Two <= 1000 THEN '501-1000'
  WHEN Average_Cost_For_Two <= 2000 THEN '1001-2000'
  ELSE '2000+'
 END AS PriceBucket,
 COUNT(*) AS Restaurants
FROM zomato_source
GROUP BY PriceBucket
order by Restaurants desc;

-- 7 % Restaurants with Table Booking
SELECT Has_Table_booking,
ROUND( (COUNT(*) / (SELECT COUNT(*) FROM zomato_source)) * 100 ,2) AS Percentage
FROM zomato_source
GROUP BY Has_Table_booking;

-- 8 % Restaurants with Online Delivery
SELECT Has_Online_delivery,
ROUND( (COUNT(*) / (SELECT COUNT(*) FROM zomato_source)) * 100 ,2) AS Percentage
FROM zomato_source
GROUP BY Has_Online_delivery;

-- 9
-- A. Cuisine-wise
SELECT Cuisines, COUNT(*) as Total_Restaurants
FROM zomato_source 
GROUP BY Cuisines
order by Total_Restaurants desc;

-- B. City-wise
SELECT City,COUNT(*) AS Total_Restaurants
FROM Zomato_source
GROUP BY City
ORDER BY Total_Restaurants DESC;

-- C.Rating-wise
SELECT Rating, COUNT(*) AS Total_Restaurants
FROM Zomato_source
GROUP BY Rating
order by rating;
