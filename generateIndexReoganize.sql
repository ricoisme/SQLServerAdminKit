--drop proc dbo.uspRebuildInexes @deBug=1
CREATE PROC [dbo].[uspRebuildInexes] (
	@dbName VARCHAR(30) = 'GCT_P003',
	@deBug BIT = 0
	)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @indexresult TABLE (
	Serial INT identity,
	[SchemaName] VARCHAR(20),
	[TableName] VARCHAR(64),
	[IndexName] VARCHAR(512),
	avg_fragmentation_in_percent FLOAT,
	page_count BIGINT
	)

INSERT INTO @indexresult
SELECT S.name AS 'Schema',
	T.name AS 'Table',
	I.name AS 'Index',
	0,
	0
FROM sys.tables T
INNER JOIN sys.schemas S ON T.schema_id = S.schema_id
INNER JOIN sys.indexes I ON I.object_id = t.object_id
WHERE I.name > ''

--select * from @indexresult
DECLARE @total INT,
	@step INT;

SET @total = (
		SELECT count(1)
		FROM @indexresult
		)
SET @step = 1

DECLARE @tablename VARCHAR(64)

WHILE (@step <= @total)
BEGIN
	SELECT TOP 1 @tablename = [SchemaName] + '.' + [TableName]
	FROM @indexresult
	WHERE Serial = @step

	UPDATE a
	SET avg_fragmentation_in_percent = b.avg_fragmentation_in_percent,
		a.page_count = b.page_count
	FROM @indexresult a
	JOIN (
		SELECT DDIPS.avg_fragmentation_in_percent,
			DDIPS.page_count,
			I.name,
			I.object_id
		FROM sys.dm_db_index_physical_stats(DB_ID(@dbName), OBJECT_ID(@dbName + '.' + @tablename), NULL, NULL, 'limited') AS DDIPS
		INNER JOIN sys.indexes I ON I.object_id = object_id(@tablename)
		WHERE DDIPS.object_id = object_id(@tablename)
		) b ON a.IndexName = b.name
	WHERE a.TableName = OBJECT_NAME(b.object_id)

	SET @step += 1
		--print @step
END

DECLARE @sqlresult TABLE (
	Serial INT identity,
	SqlStatement VARCHAR(max)
	)

SET @step = 1;

--ALTER INDEX IX_OrderTracking_SalesOrderID ON Sales.OrderTracking REORGANIZE
INSERT INTO @sqlresult
SELECT 'ALTER INDEX ' + IndexName + ' ON [' + SchemaName + '].[' + TableName + '] REORGANIZE ; GO;' AS 'sql'
FROM @indexresult
WHERE page_count > 100
	AND avg_fragmentation_in_percent > 40

IF @deBug = 1
BEGIN
	SELECT *
	FROM @sqlresult

	RETURN
END

DECLARE @sql VARCHAR(max) = ''

SELECT @total = count(*)
FROM @sqlresult

WHILE (@step <= @total)
BEGIN
	SELECT TOP 1 @sql = [SqlStatement]
	FROM @sqlresult
	WHERE Serial = @step

	EXECUTE sp_executesql @sql
	SET @step+=1
END
GO


