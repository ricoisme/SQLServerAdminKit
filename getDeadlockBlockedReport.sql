SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
;WITH events_cte
AS (
	SELECT DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP), xevents.event_data.value('(event/@timestamp)[1]', 'datetime2')) AS [event_time],
		xevents.event_data.query('(event[@name="blocked_process_report"]/data[@name="blocked_process"]/value/blocked-process-report)[1]') AS blocked_process_report,
		xevents.event_data.value('(event[@name="blocked_process_report"]/data[@name="blocked_process"]/value/blocked-process-report/blocking-process/process/@spid)[1]', 'int') AS blocking_spid,
		xevents.event_data.value('(event[@name="blocked_process_report"]/data[@name="blocked_process"]/value/blocked-process-report/blocking-process/process/@waitresource)[1]', 'nvarchar(max)') AS wait_resource
	FROM sys.fn_xe_file_target_read_file('/var/opt/mssql/data/blocked_process*.xel', '/var/opt/mssql/data/blocked_process*.xem', NULL, NULL)
	CROSS APPLY (
		SELECT CAST(event_data AS XML) AS event_data
		) AS xevents
	)
SELECT [event_time],
	blocked_process_report,
	blocking_spid,
	wait_resource
FROM events_cte
WHERE blocked_process_report.value('(blocked-process-report[@monitorLoop])[1]', 'nvarchar(max)') IS NOT NULL
ORDER BY [event_time] DESC;


-- only deadlock report
SELECT
CONVERT(xml,event_data).query('/event/data/value/deadlock') as DeadLockGraph ,
CONVERT(xml, event_data).value('(event[@name="xml_deadlock_report"]/@timestamp)[1]','datetime')  AS Execution_Time    
FROM sys.fn_xe_file_target_read_file('/var/opt/mssql/data/deadlock*.xel',
         '/var/opt/mssql/data/deadlock*.xem',
         null, null)
WHERE [object_name] = 'xml_deadlock_report'
ORDER BY timestamp_utc DESC
