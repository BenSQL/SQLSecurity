IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='Logins')
DROP EVENT SESSION Logins ON SERVER
GO

CREATE EVENT SESSION Logins ON SERVER 
ADD EVENT sqlserver.login(SET collect_options_text=(1)
	ACTION(
		sqlserver.client_app_name
		,sqlserver.client_connection_id
		,sqlserver.client_hostname
		,sqlserver.context_info
		,sqlserver.database_id
		,sqlserver.database_name
		,sqlserver.nt_username
		,sqlserver.username
		,sqlserver.server_instance_name
		,sqlserver.server_principal_name
		,sqlserver.session_id
		,sqlserver.username
		)
	--WHERE sqlserver.username <> ''
	--	AND sqlserver.username <> ''
	)
--,ADD EVENT sqlserver.logout(
--    ACTION(
--		sqlserver.client_app_name
--		,sqlserver.client_connection_id
--		,sqlserver.client_hostname
--		,sqlserver.context_info
--		,sqlserver.database_id
--		,sqlserver.database_name
--		,sqlserver.nt_username
--		,sqlserver.username
--		,sqlserver.server_instance_name
--		,sqlserver.server_principal_name
--		,sqlserver.session_id
--		,sqlserver.username
--		)
--	)
ADD TARGET package0.ring_buffer(SET max_events_limit=(10000))
WITH (
	MAX_MEMORY=4096 KB
	,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS
	,MAX_DISPATCH_LATENCY=30 SECONDS
	,MAX_EVENT_SIZE=0 KB
	,MEMORY_PARTITION_MODE=NONE
	,TRACK_CAUSALITY=ON
	,STARTUP_STATE=OFF
)
GO

-- Enable Event
ALTER EVENT SESSION Logins ON SERVER
STATE=START
GO

