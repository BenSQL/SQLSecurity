USE WideWorldImportersSECURITY
GO

IF (SELECT name FROM sys.schemas WHERE name = 'personnel') IS NULL
BEGIN
	EXEC('CREATE SCHEMA personnel AUTHORIZATION dbo')
END
GO

IF (SELECT name FROM sys.schemas WHERE name = 'shipping') IS NULL
BEGIN
	EXEC('CREATE SCHEMA shipping AUTHORIZATION dbo')
END
GO

IF (SELECT name FROM sys.schemas WHERE name = 'RLS') IS NULL
BEGIN
	EXEC('CREATE SCHEMA RLS AUTHORIZATION dbo')
END
GO

IF (SELECT name FROM sys.schemas WHERE name = 'stage') IS NULL
BEGIN
	EXEC('CREATE SCHEMA stage AUTHORIZATION dbo')
END
GO

IF (SELECT name FROM sys.schemas WHERE name = 'etl') IS NULL
BEGIN
	EXEC('CREATE SCHEMA etl AUTHORIZATION dbo')
END
GO

IF (SELECT name FROM sys.schemas WHERE name = 'application') IS NULL
BEGIN
	EXEC('CREATE SCHEMA application AUTHORIZATION dbo')
END
GO

IF (SELECT name FROM sys.schemas WHERE name = 'vendor') IS NULL
BEGIN
	EXEC('CREATE SCHEMA vendor AUTHORIZATION dbo')
END
GO
