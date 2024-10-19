SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @sqlstatement VARCHAR(1000)

SET @sqlstatement = 'USE [?] SELECT ''[?]'', db_id(parsename(base_object_name, 3)) AS dbid
     , object_id(base_object_name) AS objid
     , base_object_name
from sys.synonyms;'

EXEC sys.sp_MSforeachdb @sqlstatement
