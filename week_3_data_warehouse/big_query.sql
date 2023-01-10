-- Query public available table
SELECT station_id, name FROM
    bigquery-public-data.new_york_citibike.citibike_stations
LIMIT 100;

--Create table referring to gcs path
CREATE OR REPLACE TABLE `ny-rides-franklynes.ny_taxi.yellow_tripdata`
OPTIONS (
    format = 'parquet',
    uris = [
        'gs://dtc_data_lake_ny-rides-franklynes/raw/yellow_tripdata/2019/*',
        'gs://dtc_data_lake_ny-rides-franklynes/raw/yellow_tripdata/2020/*'
    ]
)

-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `ny-rides-franklynes.ny_taxi.external_yellow_tripdata`
OPTIONS (
    format = 'parquet',
    uris = [
        'gs://dtc_data_lake_ny-rides-franklynes/raw/yellow_tripdata/2019/*',
        'gs://dtc_data_lake_ny-rides-franklynes/raw/yellow_tripdata/2020/*'
    ]
);

-- Check external yellow trip data
SELECT * FROM ny-rides-franklynes.ny_taxi.external_yellow_tripdata LIMIT 10;

-- Create a Non-Partitioned table from external table
CREATE OR REPLACE TABLE ny-rides-franklynes.ny_taxi.yellow_tripdata_non_partitioned AS 
SELECT * FROM ny-rides-franklynes.ny_taxi.external_yellow_tripdata;

-- Create a Partitioned Table from External Table
CREATE OR REPLACE TABLE ny-rides-franklynes.ny_taxi.yellow_tripdata_partitioned
PARTITION BY
    DATE(tpep_pickup_datetime) AS
SELECT * FROM ny-rides-franklynes.ny_taxi.external_yellow_tripdata;

-- Impact of partition
-- Scanning 1.6GB of data
SELECT DISTINCT(VendorID)
FROM ny-rides-franklynes.ny_taxi.yellow_tripdata_non_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

--Scanning ~106 MB of Data
SELECT DISTINCT(VendorID)
FROM ny-rides-franklynes.ny_taxi.yellow_tripdata_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

--lets look into partition
SELECT table_name, partition_id, total_rows
FROM `ny_taxi.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'yellow_tripdata_partitioned'
ORDER BY total_rows DESC;

-- Creating a partition and cluster table
CREATE OR REPLACE TABLE ny-rides-franklynes.ny_taxi.yellow_tripdata_partitioned_clustered
PARTITION BY DATE(tpep_pickup_datetime)
CLUSTER BY VendorID AS 
SELECT * FROM ny-rides-franklynes.ny_taxi.external_yellow_tripdata;

-- Query scans 1.1 GB
SELECT count(*) AS trips
FROM ny-rides-franklynes.ny_taxi.yellow_tripdata_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
    AND VendorID=1;

-- Query scans 864.5 MB
SELECT count(*) AS trips
FROM ny-rides-franklynes.ny_taxi.yellow_tripdata_partitioned_clustered
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
    AND VendorID=1;