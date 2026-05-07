USE master
GO

SELECT
	@@SERVERNAME						ServerName
	,SP.name							LoginName
	,SP.type							LoginType
	,SP.type_desc						LoginTypeDescription
	,SP.is_disabled						LoginIsDisabled
	,SP.default_database_name			LoginDefaultDatabaseName
	,SP.default_language_name			LoginDefaultLanguageName
	,CONVERT(date,GETDATE())			ReportDate
FROM master.sys.server_principals SP
--WHERE sp.type							IN ('U','G','S')
ORDER BY 
	SP.type
	,SP.name