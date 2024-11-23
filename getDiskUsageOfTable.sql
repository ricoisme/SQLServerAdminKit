SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
  t.object_id,
  OBJECT_NAME(t.object_id) ObjectName,
  (sum(u.total_pages) * 8)/1024.0 Total_Reserved_mb,
  (sum(u.used_pages) * 8)/1024.0 Used_Space_mb,
  u.type_desc,
  max(p.rows) RowsCount
FROM
  sys.allocation_units u
  JOIN sys.partitions p on u.container_id = p.hobt_id
  JOIN sys.tables t on p.object_id = t.object_id
GROUP BY
  t.object_id,
  OBJECT_NAME(t.object_id),
  u.type_desc
ORDER BY
  Used_Space_mb desc,
  ObjectName;

