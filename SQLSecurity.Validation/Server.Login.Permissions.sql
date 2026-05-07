USE master
GO

SELECT
	@@SERVERNAME			ServerName
	,PERM.class_desc
	,PERM.major_id
	,PERM.minor_id
	,PERM.type
	,PERM.permission_name
	,PERM.state_desc
	,GNTE.name				GranteeName
	,GNTO.name				GrantorName
FROM sys.server_permissions PERM
	INNER JOIN sys.server_principals GNTE
		ON PERM.grantee_principal_id		= GNTE.principal_id
	INNER JOIN sys.server_principals GNTO
		ON PERM.grantor_principal_id		= GNTO.principal_id
ORDER BY
	GNTE.name
	,PERM.permission_name
GO
