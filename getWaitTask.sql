SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT 'Waiting_tasks' AS [Information],
	owt.session_id,
	owt.wait_duration_ms,
	owt.wait_type,
	owt.blocking_session_id,
	owt.resource_description,
	es.program_name,
	est.TEXT,
	est.dbid,
	eqp.query_plan,
	er.database_id,
	es.cpu_time,
	es.memory_usage * 8 AS memory_usage_KB
FROM sys.dm_os_waiting_tasks owt
INNER JOIN sys.dm_exec_sessions es ON owt.session_id = es.session_id
INNER JOIN sys.dm_exec_requests er ON es.session_id = er.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) est
OUTER APPLY sys.dm_exec_query_plan(er.plan_handle) eqp
WHERE es.is_user_process = 1
ORDER BY owt.session_id;



