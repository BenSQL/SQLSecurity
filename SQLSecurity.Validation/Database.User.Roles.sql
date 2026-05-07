SELECT
	@@SERVERNAME							ServerName
	,DB_NAME()								DatabaseName
	,CONVERT(varchar(30),getdate(),120)		DateTimeChecked
	,SU.name								UserName
	,SR.name								RoleName
	,SU.authentication_type_desc
FROM sys.database_role_members DRM
	INNER JOIN sys.database_principals SU
		ON DRM.member_principal_id			= SU.principal_id
	INNER JOIN sys.database_principals SR
		ON DRM.role_principal_id			= SR.principal_id
ORDER BY 
	SU.name
	,SR.name
GO
