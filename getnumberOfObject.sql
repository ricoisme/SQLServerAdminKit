SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 'WideWorldImporters'　as dbname,
	CASE TYPE
		WHEN 'U'
			THEN 'User Defined Tables'
		WHEN 'S'
			THEN 'System Tables'
		WHEN 'IT'
			THEN 'Internal Tables'
		WHEN 'P'
			THEN 'Stored Procedures'
		WHEN 'PC'
			THEN 'CLR Stored Procedures'
		WHEN 'X'
			THEN 'Extended Stored Procedures'
		WHEN 'TF'
			THEN 'TVF'
		WHEN 'FN'
			THEN 'SQL Value Function'
		WHEN 'SN'
			THEN 'Synonym'
		WHEN 'V'
			THEN 'View'
		WHEN 'SO'
			THEN 'Sequence'
		END AS 'Object Name',
	COUNT(*) AS 'Count'
FROM sys.objects
WHERE TYPE IN ('U', 'P', 'PC', 'X', 'FN', 'TF', 'SN', 'SO', 'V')
	AND is_ms_shipped = 0
GROUP BY TYPE
