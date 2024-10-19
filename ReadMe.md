# This repo provides some sql statement and ps script to handle sql server ,such as performance tunning,maintains and troubleshooting.
* top10highIO.sql - Get Top 10 high I/O statements.
* top10highCPU.sql - Get Top 10 high CPU statements.
* top10highFrequency.sql - Get Top 10 high Frequency query statements.
* top10WorstSP.sql - Get Top 10 worst stored procedure.
* top10highDuration.sql - Get Top 10 high duration statements.
* getIndexesInfo.sql - Get index usage statistics.
* getnumberOfObject.sql - Get Number of specific objects.
* getOpenTransacton.sql - Get current open transaction.
* getExecutionPlans.sql - Find execution plans
* getWaitTask.sql - Get current wait tasks inclued blocking session id.
* getDeadlockBlockedReport.sql - Get deadlock and blocked report from xel file.
* getWaitstats.sql - Get Wait statistics
* getDatabaseFileSize.sql - Get database file size.
* getParallelPlan.sql - Get parallel plan.
* getConnection.sql - Get Connectoins.
* getOldStat.sql - Get Old Statistics.
* getServerInfo.sql - Get SQL Server information.
* getSynonyms.sql - Get each database synonyms.
* getReplicationInfo.sql - Get replicaton information.
* freePROCCACHE.sql - delete specific proc cache.
* generateIndexReoganize.sql - Generate alter Index with reoganize sql statements for indexes with fragmentation greater than 40%.
* exportbojectofsqlserver.ps1 - Export sql script of object, such as table,trigger,view...