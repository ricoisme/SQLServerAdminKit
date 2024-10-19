SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT TOP 10 [Average CPU used] = total_worker_time / qs.execution_count,
	[Total CPU used] = total_worker_time,
	[Execution count] = qs.execution_count,
	[Individual Query] = SUBSTRING(qt.TEXT, qs.statement_start_offset / 2, (
			CASE 
				WHEN qs.statement_end_offset = - 1
					THEN LEN(CONVERT(NVARCHAR(MAX), qt.TEXT)) * 2
				ELSE qs.statement_end_offset
				END - qs.statement_start_offset
			) / 2),
	[Parent Query] = qt.TEXT,
	DatabaseName = DB_NAME(qt.dbid)
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
ORDER BY [Average CPU used] DESC;
