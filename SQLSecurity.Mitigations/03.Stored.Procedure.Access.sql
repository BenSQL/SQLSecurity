USE WideWorldImportersSECURITY
GO

CREATE OR ALTER PROCEDURE vendor.Cities

AS
SET NOCOUNT ON

SELECT
	C.CityID
	,C.CityName
	,C.StateProvinceID
	,C.Location
	,C.LatestRecordedPopulation
FROM Application.Cities C
GO

--Execute as dbo
EXEC vendor.Cities

--Execute as the vendorUser
EXECUTE AS USER = 'vendorUser'
GO

SELECT SUSER_NAME(), USER_NAME()
GO

--Query the Cities table directly
SELECT *
FROM Application.Cities
GO

--Execute the new stored procedure, in the vendor schema
EXEC vendor.Cities
GO

REVERT
GO
