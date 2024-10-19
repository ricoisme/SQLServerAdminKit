SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT TOP 10 t.TEXT,
	(qs.total_elapsed_time / 1000) / qs.execution_count AS avg_elapsed_time,
	(qs.total_worker_time / 1000) / qs.execution_count AS avg_cpu_time,
	((qs.total_elapsed_time / 1000) / qs.execution_count) - ((qs.total_worker_time / 1000) / qs.execution_count) AS avg_wait_time,
	qs.total_logical_reads / qs.execution_count AS avg_logical_reads,
	qs.total_logical_writes / qs.execution_count AS avg_writes,
	(qs.total_elapsed_time / 1000) AS cumulative_elapsed_time_all_executions
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(sql_handle) t
ORDER BY (qs.total_elapsed_time / qs.execution_count) DESC