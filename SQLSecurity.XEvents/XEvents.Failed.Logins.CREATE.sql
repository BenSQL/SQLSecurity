IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='FailedLogins')
BEGIN
	DROP EVENT SESSION FailedLogins ON SERVER
END
GO
 

--DROP EVENT SESSION FailedLogins ON DATABASE
--DROP EVENT SESSION FailedLogins ON SERVER


CREATE EVENT SESSION FailedLogins
ON SERVER
--ON DATABASE
 ADD EVENT sqlserver.error_reported
 (
   ACTION 
   (
		sqlserver.client_app_name
		,sqlserver.client_connection_id
		,sqlserver.client_hostname
		,sqlserver.context_info
		,sqlserver.database_id
		,sqlserver.database_name
		,sqlserver.session_id
    )
    WHERE severity = 14
      AND error_number = 18456
      AND state > 1
  )
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

--ALTER EVENT SESSION FailedLogins ON DATABASE
ALTER EVENT SESSION FailedLogins ON SERVER
STATE = START;
GO