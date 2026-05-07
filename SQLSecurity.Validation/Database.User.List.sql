USE WideWorldImportersSECURITY
GO

SET NOCOUNT ON

SELECT
	@@SERVERNAME							ServerName
	,DB_NAME()								DatabaseName
	,DBP.name								UserName
	,DBP.type_desc
	,DBP.default_schema_name
	,OP.name								OwningPrincipalName
	,DBP.is_fixed_role
	,DBP.authentication_type_desc
	,CONVERT(varchar(30),getdate(),120)		DateTimeChecked
	,SP.name								LoginName				--Comment out for Azure DB
FROM sys.database_principals DBP
	LEFT JOIN sys.database_principals OP
		ON DBP.owning_principal_id	= OP.principal_id
	--If using on an Azure DB, comment out the next two lines
	LEFT JOIN sys.server_principals SP
		ON DBP.sid					= SP.sid
WHERE
	DBP.is_fixed_role						= 0
ORDER BY
	DBP.name
GO
