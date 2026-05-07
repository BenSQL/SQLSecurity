USE master
GO

--Run the script to create the local Developers group first if you follow along
IF (SELECT name FROM sys.server_principals WHERE name = 'DOMAIN\Developers') IS NULL
BEGIN
CREATE LOGIN [DOMAIN\Developers] FROM WINDOWS WITH DEFAULT_DATABASE=WideWorldImportersSECURITY
END
GO

IF (SELECT name FROM sys.server_principals WHERE name = 'powerUserRole') IS NULL
BEGIN
	CREATE SERVER ROLE powerUserRole AUTHORIZATION sa
END
GO

ALTER SERVER ROLE powerUserRole ADD MEMBER [DOMAIN\Developers]
GO

--
GRANT VIEW SERVER STATE TO [powerUserRole]
GO

--On prem server only. Create / alter / stop trace (profiler)
--Move to EXTENDED EVENTS instead
--GRANT ALTER TRACE TO [powerUserRole]
GO

--Alternative (eventual replacement) to Profiler.
--Works in both Azure and on-prem
GRANT ALTER ANY EVENT SESSION TO [powerUserRole]			
GO

--View any object definition (views, procedures, functions, etc.)
GRANT VIEW ANY DEFINITION TO [powerUserRole]
GO

--Only needed if actively troubleshooting items
--in an administrative capacity
--kill spids blocking connections or running long, etc.
--More likely to be part of a non-prod security plan
GRANT ALTER ANY CONNECTION to [powerUserRole]
GO






--Change to database and apply role / user level permissions
USE WideWorldImportersSECURITY
GO

IF (SELECT name FROM sys.database_principals WHERE name = 'Developers') IS NULL
BEGIN
CREATE USER [Developers] FROM LOGIN [DOMAIN\Developers]
END
GO

IF (SELECT name FROM sys.database_principals WHERE name = 'developerRole') IS NULL
BEGIN
CREATE ROLE developerRole
AUTHORIZATION dbo
END
GO

ALTER ROLE developerRole
ADD MEMBER Developers
GO

GRANT SELECT, EXEC ON DATABASE::WideWorldImportersSECURITY TO developerRole
GO

GRANT SHOWPLAN TO developerRole
GO



--Azure focused permissions
--GRANT VIEW DATABASE STATE TO [developerRole]					--Needed for Azure databases. Server state and trace does not work.
--GRANT ALTER ANY DATABASE EVENT SESSION TO [developerRole]		--Event session
--GRANT KILL DATABASE CONNECTION TO [developerRole]				--Azure SQL alternative, more specific than ALTER ANY CONNECTION
