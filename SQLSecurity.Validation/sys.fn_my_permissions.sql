USE WideWorldImportersSECURITY
GO

SELECT *
FROM sys.fn_my_permissions(NULL,'Server')
GO

SELECT *
FROM sys.fn_my_permissions(NULL,'Database')
GO



EXECUTE AS USER = 'vendorUser'
GO

SELECT *
FROM sys.fn_my_permissions(NULL,'Server')
GO

SELECT *
FROM sys.fn_my_permissions(NULL,'Database')
GO

SELECT *
FROM sys.fn_my_permissions('Vendor','Schema')
GO

REVERT
GO
