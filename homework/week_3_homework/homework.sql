-- CREATE AN EXTERNAL TABLE
CREATE OR REPLACE EXTERNAL TABLE `ny-rides-franklyne.de_zoomcamp.external_fhv_tripdata`
OPTIONS
(
  format = "CSV",
  uris =[
    'gs://prefect-data-zoomcamp/data/fhv/*'
  ]
);
-- CREATE A TABLE
CREATE OR REPLACE TABLE `ny-rides-franklyne.de_zoomcamp.fhv_tripdata`
AS
SELECT * FROM `ny-rides-franklyne.de_zoomcamp.external_fhv_tripdata`;

-- 1.What is the count for fhv vehicle records for year 2019?
SELECT COUNT(*)
FROM `ny-rides-franklyne.de_zoomcamp.fhv_tripdata`;

-- 2. Count Distinct number of affiliated_base_number on both the tables
SELECT COUNT(DISTINCT(Affiliated_base_number))
FROM `ny-rides-franklyne.de_zoomcamp.fhv_tripdata`;
SELECT COUNT(DISTINCT(Affiliated_base_number))
FROM `ny-rides-franklyne.de_zoomcamp.external_fhv_tripdata`;

-- 3. How many records have both a blank (null) PUlocationID and DOlocationID in the entire dataset
SELECT COUNT(*) as blank, 
FROM `ny-rides-franklyne.de_zoomcamp.fhv_tripdata`
WHERE PUlocationID IS NULL AND DOlocationID IS NULL;

-- Create a Non-Partitioned table from external table
CREATE OR REPLACE TABLE `ny-rides-franklyne.de_zoomcamp.fhv_tripdata_non_partitioned`
AS SELECT * FROM `ny-rides-franklyne.de_zoomcamp.external_fhv_tripdata`;

-- Create a Partitioned table from external table
CREATE OR REPLACE TABLE `ny-rides-franklyne.de_zoomcamp.fhv_tripdata_partitioned`
PARTITION BY DATE(pickup_datetime) AS
SELECT *FROM `ny-rides-franklyne.de_zoomcamp.external_fhv_tripdata`;

-- Impact of Partitioning
-- Non-Partitioned Table Scanning of 647.87 MB
SELECT DISTINCT(Affiliated_base_number)
FROM `ny-rides-franklyne.de_zoomcamp.fhv_tripdata_non_partitioned`
WHERE DATE(pickup_datetime) BETWEEN '2019-03-01' AND '2019-03-31';

--Partitioned Table Scanning of 23.05MB
SELECT DISTINCT(Affiliated_base_number)
FROM `ny-rides-franklyne.de_zoomcamp.fhv_tripdata_partitioned`
WHERE DATE(pickup_datetime) BETWEEN '2019-03-01' AND '2019-03-31';

-- Creating a Partition and Cluster table
CREATE OR REPLACE TABLE `ny-rides-franklyne.de_zoomcamp.fhv_tripdata_partitioned_clustered`
PARTITION BY DATE(pickup_datetime)
CLUSTER BY Affiliated_base_number
AS
SELECT * FROM `ny-rides-franklyne.de_zoomcamp.external_fhv_tripdata`;

--Impact of Partition and Cluster
-- Partitioned-CLustered Table Query Scans 23.05
SELECT DISTINCT(Affiliated_base_number)
FROM `ny-rides-franklyne.de_zoomcamp.fhv_tripdata_partitioned_clustered`
WHERE DATE(pickup_datetime) BETWEEN '2019-03-01' AND '2019-03-31';
