

SELECT
	@@SERVERNAME						ServerName
	,SP.name							LoginName
	,SP.type							LoginType
	,SP.type_desc						LoginTypeDescription
	,SP.is_disabled						LoginIsDisabled
	,SP.default_database_name			LoginDefaultDatabaseName
	,SP.default_language_name			LoginDefaultLanguageName
	,ROL.name							RoleName
	,ROL.type							RoleType
	,ROL.type_desc						RoleTypeDescription
	,ROL.is_disabled					RoleIsDisabled
	,ROL.is_fixed_role					RoleIsFixed
	,SP.create_date
	,CONVERT(date,GETDATE())			ReportDate
FROM master.sys.server_role_members SRM
	INNER JOIN master.sys.server_principals SP
		ON SRM.member_principal_id			= SP.principal_id
	INNER JOIN master.sys.server_principals ROL
		ON SRM.role_principal_id			= ROL.principal_id
ORDER BY
	SP.name
GO
