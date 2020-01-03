/* �������� ��������, ��.651001, ������� 9 
   ������������ ������ 2, ������� 2 */

USE AdventureWorks2012;
GO

/*a) �������� ������� dbo.StateProvince � ����� �� ���������� ��� Person.StateProvince,
     ����� ���� uniqueidentifier, �� ������� �������, ����������� � ��������;  */

CREATE TABLE dbo.StateProvince (
	StateProvinceID INT NOT NULL,
	StateProvinceCode NCHAR(3) NOT NULL,
	CountryRegionCode NVARCHAR(3) NOT NULL
		REFERENCES Person.CountryRegion(CountryRegionCode),
	IsOnlyStateProvinceFlag dbo.Flag NOT NULL,
	Name dbo.Name NOT NULL,
	TerritoryID INT NOT NULL
		REFERENCES Sales.SalesTerritory(TerritoryID),
	ModifiedDate DATETIME NOT NULL
);

/*b) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.StateProvince 
     ��������� ��������� ���� �� ����� StateProvinceID � StateProvinceCode */

ALTER TABLE dbo.StateProvince
ADD CONSTRAINT PK_StateProvince PRIMARY KEY (StateProvinceID, StateProvinceCode);

/*c) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.StateProvince 
     ����������� ��� ���� TerritoryID, ����� �������� ���� ����� ��������� 
	 ������ ������ �����  */

ALTER TABLE dbo.StateProvince
ADD CONSTRAINT CheckTerritoryID CHECK (TerritoryID % 2 = 0);

/*d) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.StateProvince
     ����������� DEFAULT ��� ���� TerritoryID, ������� �������� �� ��������� 2;  */

ALTER TABLE dbo.StateProvince
ADD CONSTRAINT DF_TerritoryID DEFAULT 2 FOR TerritoryID;

/*e) ��������� ����� ������� ������� �� Person.StateProvince. �������� 
     ��� ������� ������ �� ������, ������� ����� ��� �Shipping� � ������� 
	 Person.AddressType. � ������� ������� ������� ��� ������ ������ �� ����� 
	 StateProvinceID � StateProvinceCode �������� ������ ������ � ������������ 
	 AddressID. ���� TerritoryID ��������� ���������� �� ���������;  */

INSERT INTO dbo.StateProvince (
	StateProvinceID, 
	StateProvinceCode, 
	CountryRegionCode, 
	IsOnlyStateProvinceFlag, 
	Name, 
	ModifiedDate)
SELECT 
	pr.StateProvinceID, 
	pr.StateProvinceCode, 
	pr.CountryRegionCode, 
	pr.IsOnlyStateProvinceFlag, 
	pr.Name,
	pr.ModifiedDate
FROM 
	(SELECT 
		sp.StateProvinceID, 
		sp.StateProvinceCode, 
		sp.CountryRegionCode, 
		sp.IsOnlyStateProvinceFlag, 
		sp.Name, 
		sp.ModifiedDate,
		RANK() OVER(PARTITION BY sp.StateProvinceID, sp.StateProvinceCode ORDER BY pAddress.AddressId DESC) province_rank
	FROM Person.StateProvince AS sp
	INNER JOIN Person.Address pAddress ON pAddress.StateProvinceID = sp.StateProvinceID
	INNER JOIN Person.BusinessEntityAddress eAddress ON eAddress.AddressID = pAddress.AddressID
	INNER JOIN Person.AddressType addressType ON addressType.AddressTypeID = eAddress.AddressTypeID
	WHERE addressType.Name = 'Shipping'
	) AS pr
WHERE province_rank = 1;

/*f) �������� ��� ���� IsOnlyStateProvinceFlag �� smallint, ��������� ���������� null ��������.  */
ALTER TABLE dbo.StateProvince
ALTER COLUMN IsOnlyStateProvinceFlag smallint NULL;