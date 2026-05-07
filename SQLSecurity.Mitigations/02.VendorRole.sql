USE WideWorldImportersSECURITY
GO

 /***************************************
* Create a role for the vendor
* Example creates a user without login
* Grant basic authorization
****************************************/
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

GRANT SELECT, EXEC ON SCHEMA::vendor TO vendorRole
GO
