CREATE VIEW tripdata_202202_to_202301 AS
SELECT * FROM tripdata_202202
UNION ALL
SELECT * FROM tripdata_202203
UNION ALL
SELECT * FROM tripdata_202204
UNION ALL
SELECT * FROM tripdata_202205
UNION ALL
SELECT * FROM tripdata_202206
UNION ALL
SELECT * FROM tripdata_202207
UNION ALL
SELECT * FROM tripdata_202208
UNION ALL
SELECT * FROM tripdata_202209
UNION ALL
SELECT * FROM tripdata_202210
UNION ALL
SELECT * FROM tripdata_202211
UNION ALL
SELECT * FROM tripdata_202212
UNION ALL
SELECT * FROM tripdata_202301
WHERE end_lat IS NOT NULL OR end_lng IS NOT NULL;
