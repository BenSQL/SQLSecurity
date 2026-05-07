SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE 
	@SQL			varchar(max)
	,@Print			bit				= 0
	,@DropTemp		bit				= 0
	,@ExcludeDB		varchar(max)	= 'model'

DROP TABLE IF EXISTS #DatabasePrincipals

CREATE TABLE #DatabasePrincipals(
	DatabasePrincipalID						int				 NOT NULL		PRIMARY KEY CLUSTERED		identity
	,ServerName                             nvarchar(128)    NULL
	,DatabaseName                           nvarchar(128)    NULL
	,UserName                               sysname          NOT NULL
	,DateTimeChecked                        varchar(30)      NULL
	,default_schema_name                    sysname          NULL
	,OwningPrincipalName                    sysname          NULL
	,is_fixed_role                          bit              NOT NULL
	,authentication_type_desc               nvarchar(60)     NULL
)

DECLARE @Database				varchar(255)

DECLARE crsDATABASES CURSOR FOR
SELECT
	DB.name
FROM sys.databases DB
	LEFT JOIN string_split(@ExcludeDB,',') EX
		ON DB.name		= EX.value
WHERE EX.value			IS NULL
ORDER BY DB.name

OPEN crsDATABASES

FETCH NEXT FROM crsDATABASES
INTO @Database

WHILE @@FETCH_STATUS = 0
BEGIN

SELECT @SQL = '
	SELECT
		@@SERVERNAME				ServerName
		,' + '''' + @Database + '''' + '					DatabaseName
		,DBP.name								UserName
		,CONVERT(varchar(30),getdate(),120)		DateTimeChecked
		,DBP.default_schema_name
		,OP.name								OwningPrincipalName
		,DBP.is_fixed_role
		,DBP.authentication_type_desc
	FROM [' + @Database + '].sys.database_principals DBP
		LEFT JOIN [' + @Database + '].sys.database_principals OP
			ON DBP.owning_principal_id	= OP.principal_id
	WHERE
		DBP.is_fixed_role						= 0
	ORDER BY 
		DBP.name
'

IF @Print = 1
BEGIN
	PRINT @SQL
END

	BEGIN TRY
		INSERT INTO #DatabasePrincipals (
			ServerName
			,DatabaseName
			,UserName
			,DateTimeChecked
			,default_schema_name
			,OwningPrincipalName
			,is_fixed_role
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

SELECT
	DBP.DatabasePrincipalID
	,DBP.ServerName
	,DBP.UserName
	,DBP.default_schema_name
	,DBP.OwningPrincipalName
	,DBP.is_fixed_role
	,DBP.authentication_type_desc
	,DBP.DateTimeChecked
FROM #DatabasePrincipals DBP
ORDER BY 
	UserName
	,DatabasePrincipalID

IF @DropTemp = 1
BEGIN
	DROP TABLE IF EXISTS #DatabasePrincipals
END
GO
