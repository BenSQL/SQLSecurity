SET NOCOUNT ON

DECLARE @SQL varchar(max)
 
 DROP TABLE IF EXISTS #UserPermissions

CREATE TABLE #UserPermissions (
	UserPermissionsID				int					NOT NULL		PRIMARY KEY CLUSTERED		identity
	,ServerName						nvarchar(128)		NULL
	,DatabaseName					nvarchar(128)		NULL
	,ClassDescription				nvarchar(60)		NULL
	,GranteeName					sysname				NOT NULL
	,GrantorName					sysname				NOT NULL
	,PermissionType					char(4)				NOT NULL
	,PermissionName					nvarchar(128)		NULL
	,PermissionState				char(1)				NOT NULL
	,PermissionStateDescription		nvarchar(60)		NULL
	,SchemaName						sysname				NULL
	,SecurityObject					nvarchar(258)		NULL
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
	;
	WITH SECURITY_CTE AS (
		SELECT
			DP.class_desc						ClassDescription
			,SUGR.name							GranteeName
			,SUGO.name							GrantorName
			,DP.type							PermissionType                                                                       
			,DP.permission_name					PermissionName
			,DP.state							PermissionState
			,DP.state_desc						PermissionStateDescription
			--,SO.ObjectName
			,SO.SchemaName
			,CASE
				WHEN DP.class = 0 THEN ' + '''' + @Database + '''' + '
				WHEN DP.class = 1 AND DP.minor_id = 0 THEN SO.ObjectName
				WHEN DP.class = 1 AND DP.minor_id <> 0 THEN SO.ObjectName + ' + '''' + '(' + '''' + ' + SOC.ColumnName + ' + '''' + ')' + '''' + '
				WHEN DP.class = 3 THEN SS.name
				WHEN DP.class = 4 THEN SU.name
				WHEN DP.class = 5 THEN SA.name
				WHEN DP.class = 6 THEN ST.name
				WHEN DP.class = 10 THEN XL.name
				WHEN DP.class = 15 THEN  SMT.name
				WHEN DP.class = 16 THEN SC.name
				WHEN DP.class = 17 THEN S.name
				WHEN DP.class = 18 THEN RSB.name
				WHEN DP.class = 19 THEN SR.name
				WHEN DP.class = 23 THEN FTC.name
				WHEN DP.class = 24 THEN SK.name
				WHEN DP.class = 25 THEN CRT.name
				WHEN DP.class = 26 THEN AK.name
			END	COLLATE SQL_Latin1_General_CP1_CI_AS								SecurityObject
		
		FROM [' + @Database + '].sys.database_permissions DP
			INNER JOIN [' + @Database + '].sys.database_principals SUGR
				ON DP.grantee_principal_id		= SUGR.principal_id
			INNER JOIN [' + @Database + '].sys.database_principals SUGO
				ON DP.grantor_principal_id		= SUGO.principal_id
			LEFT JOIN (
				SELECT
					SS.name						SchemaName
					,SS.schema_id
					,SO.name					ObjectName
					,SO.object_id
				FROM [' + @Database + '].sys.schemas SS
					INNER JOIN [' + @Database + '].sys.objects SO
						ON SS.schema_id			= SO.schema_id

				UNION

				SELECT
					SS.name						SchemaName
					,SS.schema_id
					,SO.name					ObjectName
					,SO.object_id
				FROM [' + @Database + '].sys.schemas SS
					INNER JOIN [' + @Database + '].sys.system_objects SO
						ON SS.schema_id			= SO.schema_id
			) SO
				ON DP.major_id					= SO.object_id
				AND DP.class					= 1
			LEFT JOIN (
				SELECT
					SS.name						SchemaName
					,SS.schema_id
					,SO.name					ObjectName
					,SO.object_id
					,SC.column_id
					,SC.name					ColumnName
				FROM [' + @Database + '].sys.schemas SS
					INNER JOIN [' + @Database + '].sys.objects SO
						ON SS.schema_id			= SO.schema_id
					INNER JOIN [' + @Database + '].sys.columns SC
						ON SO.object_id			= SC.object_id

				UNION

				SELECT
					SS.name						SchemaName
					,SS.schema_id
					,SO.name					ObjectName
					,SO.object_id
					,SC.column_id
					,SC.name					ColumnName
				FROM [' + @Database + '].sys.schemas SS
					INNER JOIN [' + @Database + '].sys.system_objects SO
						ON SS.schema_id			= SO.schema_id
					INNER JOIN [' + @Database + '].sys.system_columns SC
						ON SO.object_id			= SC.object_id
			) SOC
				ON DP.major_id					= SOC.object_id
				AND DP.minor_id					= SOC.column_id
				AND DP.class					= 1
			LEFT JOIN [' + @Database + '].sys.schemas SS
				ON DP.major_id					= SS.schema_id
				AND DP.class					= 3
			LEFT JOIN [' + @Database + '].sys.sysusers SU
				ON DP.major_id					= SU.uid
				AND DP.class					= 4
			LEFT JOIN [' + @Database + '].sys.assemblies SA
				ON DP.major_id					= SA.assembly_id
				AND DP.class					= 5
			LEFT JOIN [' + @Database + '].sys.types ST
				ON DP.major_id					= ST.user_type_id		--VERIFY
				AND DP.class					= 6
			LEFT JOIN [' + @Database + '].sys.xml_schema_collections XL
				ON DP.major_id					= XL.xml_collection_id
				AND DP.class					= 10
			LEFT JOIN [' + @Database + '].sys.service_message_types SMT						--VERIFY
				ON DP.major_id					= SMT.message_type_id
				AND DP.class					= 15
			LEFT JOIN [' + @Database + '].sys.service_contracts SC
				ON DP.major_id					= SC.service_contract_id
				AND DP.class					= 16
			LEFT JOIN [' + @Database + '].sys.services S									--VERIFY
				ON DP.major_id					= S.service_id
				AND DP.class					= 17
			LEFT JOIN [' + @Database + '].sys.remote_service_bindings RSB
				ON DP.major_id					= RSB.remote_service_binding_id
				AND DP.class					= 18
			LEFT JOIN [' + @Database + '].sys.routes SR
				ON DP.major_id					= SR.route_id
				AND DP.class					= 19
			LEFT JOIN [' + @Database + '].sys.fulltext_catalogs FTC
				ON DP.major_id					= FTC.fulltext_catalog_id
				AND DP.class					= 23
			LEFT JOIN [' + @Database + '].sys.symmetric_keys SK
				ON DP.major_id					= SK.symmetric_key_id
				AND DP.class					= 24
			LEFT JOIN [' + @Database + '].sys.certificates CRT
				ON DP.major_id					= CRT.certificate_id
				AND DP.class					= 25
			LEFT JOIN [' + @Database + '].sys.asymmetric_keys AK
				ON DP.major_id					= AK.asymmetric_key_id
				AND DP.class					= 26
	)

	SELECT DISTINCT
		@@SERVERNAME		ServerName
		,' + '''' + @Database + '''' + '			DatabaseName
		,*
	FROM SECURITY_CTE SC
	WHERE SC.SecurityObject IS NOT NULL
	ORDER BY
		SC.ClassDescription
		,SC.GranteeName
		,SC.SchemaName
		,SC.SecurityObject
	'


PRINT @SQL

	BEGIN TRY
		INSERT INTO #UserPermissions (
			ServerName
			,DatabaseName
			,ClassDescription
			,GranteeName
			,GrantorName
			,PermissionType
			,PermissionName
			,PermissionState
			,PermissionStateDescription
			,SchemaName
			,SecurityObject
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
FROM #UserPermissions
WHERE GranteeName NOT IN ('public')
ORDER BY
	ServerName
	,DatabaseName
	,GranteeName
	,SchemaName
	,SecurityObject

DROP TABLE IF EXISTS #UserPermissions
GO



/*

class	tinyint	Identifies class on which permission exists.

0 = Database
1 = Object or Column
3 = Schema
4 = Database Principal
5 = Assembly - Applies to: SQL Server 2008 through SQL Server 2017.
6 = Type
10 = XML Schema Collection - 
Applies to: SQL Server 2008 through SQL Server 2017.
15 = Message Type - Applies to: SQL Server 2008 through SQL Server 2017.
16 = Service Contract - Applies to: SQL Server 2008 through SQL Server 2017.
17 = Service - Applies to: SQL Server 2008 through SQL Server 2017.
18 = Remote Service Binding - Applies to: SQL Server 2008 through SQL Server 2017.
19 = Route - Applies to: SQL Server 2008 through SQL Server 2017.
23 =Full-Text Catalog - Applies to: SQL Server 2008 through SQL Server 2017.
24 = Symmetric Key - Applies to: SQL Server 2008 through SQL Server 2017.
25 = Certificate - Applies to: SQL Server 2008 through SQL Server 2017.
26 = Asymmetric Key - Applies to: SQL Server 2008 through SQL Server 2017.

*/

