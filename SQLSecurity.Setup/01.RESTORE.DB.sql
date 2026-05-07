--https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
USE master
GO

IF (SELECT name FROM sys.databases WHERE name = 'WideWorldImportersSECURITY') IS NOT NULL
BEGIN
	ALTER DATABASE WideWorldImportersSECURITY SET SINGLE_USER WITH ROLLBACK IMMEDIATE
END
GO

RESTORE DATABASE WideWorldImportersSECURITY 
FROM  DISK = N'C:\Temp\SQLPass.2026\WideWorldImporters-Full.bak' 
WITH  FILE = 1
	,MOVE N'WWI_Primary' TO N'C:\SQLData\WideWorldImportersSECURITY.mdf'
	,MOVE N'WWI_UserData' TO N'C:\SQLData\WideWorldImportersSECURITY_UserData.ndf'
	,MOVE N'WWI_Log' TO N'C:\SQLLog\WideWorldImportersSECURITY.ldf'
	,MOVE N'WWI_InMemory_Data_1' TO N'C:\SQLData\WideWorldImportersSECURITY_InMemory_Data_1'
	,NOUNLOAD
	,REPLACE
	,STATS = 5
GO

ALTER DATABASE WideWorldImportersSECURITY SET MULTI_USER
GO

--Allows wrapping the system function
ALTER DATABASE WideWorldImportersSECURITY
SET TRUSTWORTHY ON
GO

ALTER AUTHORIZATION ON DATABASE::WideWorldImportersSECURITY TO sa
GO

