CREATE PROC dbo.uspGetServerInfo
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 'buffer_cache_hit_ratio' AS 'Name',
	cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Buffer cache　hit ratio'
	AND object_name LIKE '%Buffer Manager%'

UNION ALL

SELECT 'batch_requests_per_sec' AS 'Name',
	cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Batch　Requests/sec'

UNION ALL

SELECT 'buffer_page_life_expectancy' AS 'Name',
	cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Page life　expectancy'
	AND object_name LIKE '%Buffer Manager%'

UNION ALL

SELECT 're_compilations_per_sec' AS 'Name',
	cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'SQL Re-Compilations/sec'

UNION ALL

SELECT 'compilations_per_sec' AS 'Name',
	cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'SQL Compilations/sec'

UNION ALL

SELECT 'page_splits_per_sec' AS 'Name',
	cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Page splits/sec'

UNION ALL
	
	SELECT　 'Target Server Memory (MB)' AS 'Name',
	cntr_value / 1024
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Target Server Memory (KB)'
	AND object_name LIKE '%Memory Manage%'

UNION ALL
	
	SELECT　 'Total Server Memory (MB)' AS 'Name',
	cntr_value / 1024
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Total Server Memory (KB)'
	AND object_name LIKE '%Memory Manage%'
