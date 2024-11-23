SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT (
		CASE 
			WHEN mdh.runstatus = '1'
				THEN 'Start - ' + cast(mdh.runstatus AS VARCHAR)
			WHEN mdh.runstatus = '2'
				THEN 'Succeed - ' + cast(mdh.runstatus AS VARCHAR)
			WHEN mdh.runstatus = '3'
				THEN 'InProgress - ' + cast(mdh.runstatus AS VARCHAR)
			WHEN mdh.runstatus = '4'
				THEN 'Idle - ' + cast(mdh.runstatus AS VARCHAR)
			WHEN mdh.runstatus = '5'
				THEN 'Retry - ' + cast(mdh.runstatus AS VARCHAR)
			WHEN mdh.runstatus = '6'
				THEN 'Fail - ' + cast(mdh.runstatus AS VARCHAR)
			ELSE CAST(mdh.runstatus AS VARCHAR)
			END
		) [Run Status],
	mda.subscriber_db [Subscriber DB],
	mda.publication [PUB Name],
	right(left(mda.name, LEN(mda.name) - (len(mda.id) + 1)), LEN(left(mda.name, LEN(mda.name) - (len(mda.id) + 1))) - (
			10 + len(mda.publisher_db) + (
				CASE 
					WHEN mda.publisher_db = 'ALL'
						THEN 1
					ELSE LEN(mda.publication) + 2
					END
				)
			)) [SUBSCRIBER],
	CONVERT(VARCHAR(25), mdh.[time]) [LastSynchronized],
	und.UndelivCmdsInDistDB [UndistCom],
	mdh.comments [Comments],
	'select * from distribution.dbo.msrepl_errors (nolock) where id = ' + CAST(mdh.error_id AS VARCHAR(8)) [Query More Info],
	mdh.xact_seqno [SEQ_NO],
	(
		CASE 
			WHEN mda.subscription_type = '0'
				THEN 'Push'
			WHEN mda.subscription_type = '1'
				THEN 'Pull'
			WHEN mda.subscription_type = '2'
				THEN 'Anonymous'
			ELSE CAST(mda.subscription_type AS VARCHAR)
			END
		) [SUB Type],
	mda.publisher_db + ' - ' + CAST(mda.publisher_database_id AS VARCHAR) [Publisher DB],
	mda.name [Pub - DB - Publication - SUB - AgentID]
FROM distribution.dbo.MSdistribution_agents mda
LEFT JOIN distribution.dbo.MSdistribution_history mdh ON mdh.agent_id = mda.id
JOIN (
	SELECT s.agent_id,
		MaxAgentValue.[time],
		SUM(CASE 
				WHEN xact_seqno > MaxAgentValue.maxseq
					THEN 1
				ELSE 0
				END) AS UndelivCmdsInDistDB
	FROM distribution.dbo.MSrepl_commands t(NOLOCK)
	JOIN distribution.dbo.MSsubscriptions AS s(NOLOCK) ON (
			t.article_id = s.article_id
			AND t.publisher_database_id = s.publisher_database_id
			)
	JOIN (
		SELECT hist.agent_id,
			MAX(hist.[time]) AS [time],
			h.maxseq
		FROM distribution.dbo.MSdistribution_history hist(NOLOCK)
		JOIN (
			SELECT agent_id,
				ISNULL(MAX(xact_seqno), 0x0) AS maxseq
			FROM distribution.dbo.MSdistribution_history(NOLOCK)
			GROUP BY agent_id
			) AS h ON (
				hist.agent_id = h.agent_id
				AND h.maxseq = hist.xact_seqno
				)
		GROUP BY hist.agent_id,
			h.maxseq
		) AS MaxAgentValue ON MaxAgentValue.agent_id = s.agent_id
	GROUP BY s.agent_id,
		MaxAgentValue.[time]
	) und ON mda.id = und.agent_id
	AND und.[time] = mdh.[time]
WHERE mda.subscriber_db <> 'virtual' -- created when your publication has the immediate_sync property set to true. This property dictates whether snapshot is available all the time for new subscriptions to be initialized. This affects the cleanup behavior of transactional replication. If this property is set to true, the transactions will be retained for max retention period instead of it getting cleaned up as soon as all the subscriptions got the change.
	--and mdh.runstatus='6' --Fail
	--and mdh.runstatus<>'2' --Succeed
ORDER BY mdh.[time]


select distinct 
srv.srvname publication_server 
, a.publisher_db
, p.publication publication_name
, p.retention
, ss.srvname subscription_server
, s.subscriber_db
from MSArticles a 
join MSpublications p on a.publication_id = p.publication_id
join MSsubscriptions s on p.publication_id = s.publication_id
join master..sysservers ss on s.subscriber_id = ss.srvid
join master..sysservers srv on srv.srvid = p.publisher_id
join MSdistribution_agents da on da.publisher_id = p.publisher_id 
and da.subscriber_id = s.subscriber_id
ORDER BY p.retention
