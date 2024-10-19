SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT name,
	size / 128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT) / 128.0 AS AvailableSpaceInMB,
	physical_name
FROM sys.database_files;

SELECT database_name = DB_NAME(database_id),
	log_size_mb = CAST(SUM(CASE 
				WHEN type_desc = 'LOG'
					THEN size
				END) * 8. / 1024 AS DECIMAL(20, 2)),
	row_size_mb = CAST(SUM(CASE 
				WHEN type_desc = 'ROWS'
					THEN size
				END) * 8. / 1024 AS DECIMAL(20, 2)),
	total_size_mb = CAST(SUM(size) * 8. / 1024 AS DECIMAL(20, 2))
FROM sys.master_files WITH (NOWAIT)
WHERE database_id = DB_ID()
GROUP BY database_id
