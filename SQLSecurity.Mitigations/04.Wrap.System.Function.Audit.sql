/***************************************
*	Create the audit that will be used
****************************************/
USE [master]
GO

IF (SELECT name FROM sys.server_audits WHERE name = 'SQLSecurity') IS NULL
BEGIN

CREATE SERVER AUDIT [SQLSecurity]
TO FILE (
	FILEPATH = N'C:\Temp\SQLPass.2026\Audit'
	,MAXSIZE = 10 MB
	,MAX_ROLLOVER_FILES = 10
	,RESERVE_DISK_SPACE = OFF
) WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE)
END
GO

IF (SELECT name FROM sys.server_audit_specifications WHERE name = 'FAILED_LOGIN_SPECIFICATION') IS NULL
BEGIN

CREATE SERVER AUDIT SPECIFICATION FAILED_LOGIN_SPECIFICATION  
FOR SERVER AUDIT SQLSecurity  
ADD (FAILED_LOGIN_GROUP)  
WITH (STATE=ON)
END
GO  

ALTER SERVER AUDIT SQLSecurity WITH (STATE = ON);
GO


/***************************************
*	Database audit spec
****************************************/
USE [WideWorldImportersSECURITY]
GO

IF (SELECT name FROM sys.database_audit_specifications WHERE name = 'DATABASE_AUDIT_SPECIFICATION_CHANGES') IS NULL
BEGIN
CREATE DATABASE AUDIT SPECIFICATION DATABASE_AUDIT_SPECIFICATION_CHANGES
FOR SERVER AUDIT [SQLSecurity]
ADD (DATABASE_OBJECT_CHANGE_GROUP)
WITH (STATE = ON)
END
GO

ALTER DATABASE AUDIT SPECIFICATION DATABASE_AUDIT_SPECIFICATION_CHANGES
WITH (STATE = ON)
GO

DROP VIEW IF EXISTS vendor.vw_Orders
GO

CREATE OR ALTER VIEW vendor.vw_Orders

AS

SELECT
	SO.OrderID
	,SO.CustomerID
	,SO.OrderDate
FROM Sales.Orders SO
GO
 

 /***************************************
* Create a role for the vendor
* Example creates a user without login
****************************************/
USE WideWorldImportersSECURITY
GO

IF (SELECT name FROM sys.database_principals WHERE name = 'vendorRole') IS NULL
BEGIN
	CREATE ROLE vendorRole
END

IF (SELECT name FROM sys.database_principals WHERE name = 'vendorUser') IS NULL
BEGIN
	CREATE USER vendorUser WITHOUT LOGIN
END
GO

ALTER ROLE vendorRole ADD MEMBER vendorUser
GO

GRANT SELECT ON sys.sql_expression_dependencies to vendorRole
GO

GRANT SELECT, VIEW DEFINITION ON SCHEMA::Sales TO vendorRole
GO

GRANT SHOWPLAN TO vendorRole
GO

GRANT SELECT, EXEC ON SCHEMA::vendor TO vendorRole
GO

REVOKE CONTROL ON DATABASE::WideWorldImportersSECURITY TO vendorRole
GO

REVOKE CONTROL ON DATABASE::WideWorldImportersSECURITY TO vendorUser
GO

/*Certificate */
--If the database is not set to trustworthy, you can use a certificate to sign the procedure
--IF(SELECT name FROM sys.certificates WHERE name = 'VendorCert') IS NULL
--BEGIN
--	CREATE CERTIFICATE VendorCert
--	ENCRYPTION BY PASSWORD = ''
--	WITH SUBJECT = 'Certificate for elevated execution'
--END
--GO  


 /***************************************
* Wrap a system function that normally 
* requires CONTROL SERVER / CONTROL DATABASE
* (SQL 2022 now has VIEW SERVER SECURITY AUDIT)
****************************************/
DECLARE @BlobLocation varchar(max)

SELECT @BlobLocation = 'C:\Temp\SQLPass.2026\Audit\*.sqlaudit'

DECLARE @SQL VARCHAR(max) = '
CREATE OR ALTER FUNCTION vendor.fn_GetAuditFile (

)
RETURNS @Values TABLE (
	userName				nvarchar(4000)		NULL
	,startTime				datetime2			NOT NULL
	,queryString			nvarchar(4000)		NULL
	,sessionId				smallint			NOT NULL
	,sessionStartTime		datetime2			NOT NULL
	,milliSeconds			bigint				NOT NULL
	,cancelled				varchar(1)			NOT NULL
	,defaultDatabases		nvarchar(128)		NULL
)
WITH EXECUTE AS OWNER
AS
BEGIN
	INSERT INTO @Values (
		userName
		,startTime
		,queryString
		,sessionId
		,sessionStartTime
		,milliSeconds
		,cancelled
		,defaultDatabases
	)
	SELECT
		server_principal_name		userName
		,event_time					startTime
		,[statement]				queryString
		,session_id					sessionId
		,event_time					sessionStartTime
		,duration_milliseconds		milliSeconds
		,' + '''' + 'N' + '''' + '	cancelled
		,database_name				defaultDatabases
	FROM sys.fn_get_audit_file(' + '''' + @BlobLocation + '''' + ',default,default)
	RETURN
END
'
PRINT @SQL
EXEC(@SQL)
GO

--If a cert is used
--ADD SIGNATURE TO vendor.fn_GetAuditFile
--BY CERTIFICATE VendorCert  
--WITH PASSWORD = 'abc123'
--GO  

ALTER TABLE Purchasing.PurchaseOrders
ADD NewColumn int NULL
GO

EXECUTE AS USER = 'vendorUser'
GO

SELECT
	userName
	,startTime
	,queryString
	,sessionId
	,sessionStartTime
	,milliSeconds
	,cancelled
	,defaultDatabases
FROM vendor.fn_GetAuditFile()
GO


SELECT *
FROM fn_get_audit_file('C:\Temp\SQLPass.2026\Audit\*.sqlaudit', DEFAULT, DEFAULT)
ORDER BY event_time
GO

REVERT
GO
