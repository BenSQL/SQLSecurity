DECLARE @EVENT_DATA XML 

SELECT @EVENT_DATA = CONVERT(xml,target_data)
FROM sys.dm_xe_sessions S
	INNER JOIN sys.dm_xe_session_targets ST
		ON S.address = st.event_session_address
WHERE S.name				= 'Logins'
	AND ST.target_name		= 'ring_buffer'

;
WITH LOGIN_CTE AS (
SELECT 
	n.value('(event/action[@name="session_id"]/value)[1]', 'int')													session_id
	,n.value('(event/@name)[1]', 'varchar(50)')																		EventName
	,n.value('(event/action[@name="server_instance_name"]/value)[1]', 'varchar(8000)')								ServerInstance
	,n.value('(event/action[@name="client_hostname"]/value)[1]', 'varchar(255)')									ClientHostname
	,n.value('(event/action[@name="nt_username"]/value)[1]', 'varchar(8000)')										NTUserName
	,n.value('(event/action[@name="username"]/value)[1]', 'varchar(8000)')											UserName
	,n.value('(event/action[@name="server_principal_name"]/value)[1]', 'varchar(8000)')								server_principal_name
	,n.value('(event/@timestamp)[1]', 'datetime2')																	DateTimeUTC
	,DATEADD(hh,DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP),n.value('(event/@timestamp)[1]', 'datetime2'))		DateTimeLocal
FROM
(
	SELECT td.query('.') as n
	FROM @EVENT_DATA.nodes('//RingBufferTarget/event') AS q(td)
) TAB
--Excluding this currently running query.
WHERE n.value('(event/action[@name="session_id"]/value)[1]', 'int') <> @@SPID
	OR n.value('(event/action[@name="session_id"]/value)[1]', 'int') IS NULL
)

SELECT *
FROM LOGIN_CTE
WHERE UserName IS NOT NULL
