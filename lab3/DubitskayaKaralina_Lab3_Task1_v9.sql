/* �������� ��������, ��.651001, ������� 9 
   ������������ ������ 3, ������� 1 */

USE AdventureWorks2012;
GO

/*a) �������� � ������� dbo.StateProvince ���� AddressType ���� nvarchar(50);  */

ALTER TABLE dbo.StateProvince
ADD AddressType NVARCHAR(50);
GO

/*b) �������� ��������� ���������� � ����� �� ���������� ��� dbo.StateProvince 
	� ��������� �� ������� �� dbo.StateProvince. ���� AddressType ��������� �������	
	�� ������� Person.AddressType ���� Name; */

DECLARE @StateProvince TABLE
(
	StateProvinceID INT NOT NULL,
	StateProvinceCode NCHAR(3) NOT NULL,
	CountryRegionCode NVARCHAR(3) NOT NULL,
	IsOnlyStateProvinceFlag SMALLINT NULL,
	Name dbo.Name NOT NULL,
	TerritoryID INT NOT NULL,
	ModifiedDate DATETIME NOT NULL,
	AddressType NVARCHAR(50) NULL
);

INSERT INTO @StateProvince 
SELECT 
	sp.StateProvinceID,
	sp.StateProvinceCode, 
	sp.CountryRegionCode, 
	sp.IsOnlyStateProvinceFlag,
	sp.Name,
	sp.TerritoryID,
	sp.ModifiedDate, 
	addressType.Name
FROM dbo.StateProvince AS sp
	INNER JOIN Person.Address pAddress 
		ON pAddress.StateProvinceID = sp.StateProvinceID	
	INNER JOIN Person.BusinessEntityAddress eAddress 
		ON eAddress.AddressID = pAddress.AddressID
	INNER JOIN Person.AddressType addressType 
		ON addressType.AddressTypeID = eAddress.AddressTypeID;

--SELECT * FROM @StateProvince;
--GO

/* c) �������� ���� AddressType � dbo.StateProvince ������� �� ��������� ����������, 
	�������� � ������ �������� ������� ����� � ���� Name �������� ������� 
	�� Person.CountryRegion; */

UPDATE dbo.StateProvince
SET dbo.StateProvince.AddressType = sp.AddressType,
	dbo.StateProvince.Name = CONCAT(reg.Name, ' ', sp.Name)
FROM @StateProvince AS sp
	INNER JOIN Person.CountryRegion AS reg 
		ON reg.CountryRegionCode = sp.CountryRegionCode
WHERE 
	sp.StateProvinceID = dbo.StateProvince.StateProvinceID 
	AND sp.StateProvinceCode = dbo.StateProvince.StateProvinceCode;

SELECT * FROM dbo.StateProvince;
GO

/* d) ������� ������ �� dbo.StateProvince, ������� �� ����� ������ 
	��� ������� �������� �� AddressType � ������������ StateProvinceID; */

WITH rankedSP AS
(
	SELECT *, RANK() OVER(PARTITION BY sp.AddressType ORDER BY sp.StateProvinceID DESC) AS RankNumber
	FROM dbo.StateProvince AS sp
)
DELETE 
FROM rankedSP
WHERE rankedSP.RankNumber > 1;
GO

SELECT * FROM dbo.StateProvince;
GO


/* e) ������� ���� AddressType �� �������, ������� ��� ��������� ����������� � �������� �� ���������.
	����� ����������� �� ������ ����� � ����������. ����� �������� �� ��������� ������� ��������������, 
	��������� ���, ������� ������������ ��� ������; */

ALTER TABLE dbo.StateProvince DROP COLUMN AddressType;

SELECT *
FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'StateProvince';

ALTER TABLE dbo.StateProvince DROP CONSTRAINT CheckTerritoryID;
ALTER TABLE dbo.StateProvince DROP CONSTRAINT DF_TerritoryID;
ALTER TABLE dbo.StateProvince DROP CONSTRAINT FK__StateProv__Count__297722B6;
ALTER TABLE dbo.StateProvince DROP CONSTRAINT FK__StateProv__Terri__2A6B46EF;
ALTER TABLE dbo.StateProvince DROP CONSTRAINT PK_StateProvince;

SELECT default_constraints.name
FROM sys.all_columns
	INNER JOIN sys.tables
        ON all_columns.object_id = tables.object_id
	INNER JOIN sys.schemas
        ON tables.schema_id = schemas.schema_id
	INNER JOIN sys.default_constraints
        ON all_columns.default_object_id = default_constraints.object_id
WHERE schemas.name = 'dbo'
    AND tables.name = 'StateProvince';

/* f) ������� ������� dbo.StateProvince. */

DROP TABLE dbo.StateProvince;