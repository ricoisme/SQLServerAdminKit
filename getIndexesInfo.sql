SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT ios.database_id,
	DB_Name(ios.database_id) AS DBName,
	ios.index_id,
	ios.object_id,
	OBJECT_NAME(ios.object_id) AS objectname,
	ius.last_user_seek AS last_seek_time,
	ius.last_user_scan AS last_scan_time,
	ius.last_user_lookup AS last_lookup_time,
	ius.last_user_update AS last_update_time
FROM sys.dm_db_index_operational_stats(NULL, NULL, NULL, NULL) AS ios
JOIN sys.indexes AS idx ON ios.object_id = idx.object_id
	AND ios.index_id = idx.index_id
JOIN sys.dm_db_index_usage_stats AS ius ON ios.object_id = ius.object_id
	AND ios.index_id = ius.index_id
WHERE ios.database_id >= 0
	AND (
		ios.leaf_delete_count > 0
		OR ios.leaf_insert_count > 0
		OR ios.leaf_update_count > 0
		OR ios.singleton_lookup_count > 0
		)