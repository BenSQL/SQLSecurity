SET NOCOUNT ON

DECLARE @SQL varchar(max)

DROP TABLE IF EXISTS #DatabaseUserRoles

CREATE TABLE #DatabaseUserRoles(
	DatabaseUserRolesID			int					NOT NULL		PRIMARY KEY CLUSTERED		identity
	,ServerName					nvarchar(128)		NULL
	,DatabaseName				nvarchar(128)		NULL
	,DateTimeChecked			datetime			NOT NULL
	,UserName					sysname				NOT NULL
	,RoleName					sysname				NOT NULL
	,authentication_type_desc	sysname				NULL

)

DECLARE @Database				varchar(255)

DECLARE crsDATABASES CURSOR FOR
SELECT
	name
FROM sys.databases
ORDER BY name

OPEN crsDATABASES

FETCH NEXT FROM crsDATABASES
INTO @Database

WHILE @@FETCH_STATUS = 0
BEGIN

SELECT @SQL = '
	SELECT
		@@SERVERNAME				ServerName
		,' + '''' + @Database + '''' + '					DatabaseName
		,getdate()								DateTimeChecked
		,SU.name								UserName
		,SR.name								RoleName
		,SU.authentication_type_desc
	FROM [' + @Database + '].sys.database_role_members DRM
		INNER JOIN [' + @Database + '].sys.database_principals SU
			ON DRM.member_principal_id			= SU.principal_id
		INNER JOIN [' + @Database + '].sys.database_principals SR
			ON DRM.role_principal_id			= SR.principal_id
	ORDER BY 
		SU.name
		,SR.name
'

PRINT @SQL

	BEGIN TRY
		INSERT INTO #DatabaseUserRoles (
			ServerName
			,DatabaseName
			,DateTimeChecked
			,UserName
			,RoleName
			,authentication_type_desc
		)
		EXEC (@SQL)
	END TRY
	BEGIN CATCH
		PRINT 'Failed on database ' + @Database
	END CATCH

	FETCH NEXT FROM crsDATABASES
	INTO @Database
END

CLOSE crsDATABASES
DEALLOCATE crsDATABASES

SELECT *
FROM #DatabaseUserRoles
ORDER BY 
	ServerName
	,DatabaseName
	,UserName
	,RoleName

DROP TABLE IF EXISTS #DatabaseUserRoles
GO
