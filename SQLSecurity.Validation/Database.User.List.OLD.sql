USE WideWorldImportersSECURITY
GO

SET NOCOUNT ON

SELECT
	@@SERVERNAME							ServerName
	,DB_NAME()								DatabaseName
	,CONVERT(varchar(30),getdate(),120)		DateTimeChecked
	,SU.name								UserName
	,SU.hasdbaccess							HasDBAccess
	,SU.isntname							IsNTName
	,SU.issqluser							IsSQLUser
	,SU.islogin								IsLogin
	,SU.isntgroup							IsNTGroup
	,SU.isntuser							IsNTUser
	,SU.createdate							UserCreateDate
FROM sys.sysusers SU
WHERE SU.uid								< 16384
	--AND SU.UID								> 4
	AND SU.issqlrole						= 0
	AND SU.isapprole						= 0
ORDER BY 
	UserName
GO
