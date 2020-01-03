/* �������� ��������, ��.651001, ������� 9 
   ������������ ������ 3, ������� 2 */

USE AdventureWorks2012;
GO

/* a) ��������� ���, ��������� �� ������ ������� ������ ������������ ������. 
	�������� � ������� dbo.StateProvince ���� TaxRate SMALLMONEY, CurrencyCode NCHAR(3) 
	� AverageRate MONEY. ����� �������� � ������� ����������� ���� IntTaxRate, ����������� 
	�������� � ���� TaxRate � ������� ������� �� ���������� ������. */

ALTER TABLE dbo.StateProvince
ADD 
	TaxRate SMALLMONEY, 
	CurrencyCode NCHAR(3), 
	AverageRate MONEY, 
	IntTaxRate AS CEILING(TaxRate)
GO

/*b) �������� ��������� ������� #StateProvince, � ��������� ������ �� ���� StateProvinceID. 
	��������� ������� ������ �������� ��� ���� ������� dbo.StateProvince �� ����������� 
	���� IntTaxRate. */

CREATE TABLE dbo.#StateProvince (
	StateProvinceID INT,
	StateProvinceCode NCHAR(3),
	CountryRegionCode NVARCHAR(3),
	IsOnlyStateProvinceFlag SMALLINT,
	Name NVARCHAR(50),		
	TerritoryID INT,
	ModifiedDate DATETIME,
	TaxRate SMALLMONEY,
	CurrencyCode NCHAR(3),
	AverageRate MONEY,
	PRIMARY KEY (StateProvinceID)
);

/* c) ��������� ��������� ������� ������� �� dbo.StateProvince. 
	���� CurrencyCode ��������� ������� �� ������� Sales.Currency. 
	���� TaxRate ��������� ���������� ��������� ������ � ��������� ������� (TaxType = 1) 
	�� ������� Sales.SalesTaxRate. ���� ��� ������-�� ����� ��������� ������ �� �������, 
	��������� TaxRate �����. ���������� ������������ �������� ����� ������ ������ (AverageRate) 
	� ������� Sales.CurrencyRate ��� ������ ������ (��������� � ���� ToCurrencyCode) 
	� ��������� ����� ���������� ���� AverageRate. ����������� ������������� ����� ��� ������ 
	������ ����������� � Common Table Expression (CTE). */

WITH avrgCurrency AS (
	SELECT 
		cr.ToCurrencyCode AS CurrencyCode, 
		MAX(cr.AverageRate) AS AverageRate
	FROM Sales.CurrencyRate AS cr
	GROUP BY ToCurrencyCode
)	
INSERT INTO dbo.#StateProvince (
	StateProvinceID, 
	StateProvinceCode, 
	CountryRegionCode,
	IsOnlyStateProvinceFlag,
	Name,
	TerritoryID,
	ModifiedDate,
	TaxRate,
	CurrencyCode,
	AverageRate )
SELECT 
	sp.StateProvinceID, 
	sp.StateProvinceCode,
	sp.CountryRegionCode,
	sp.IsOnlyStateProvinceFlag,
	sp.Name,
	sp.TerritoryID,
	sp.ModifiedDate,
	CASE tr.TaxType
		WHEN 1 THEN tr.TaxRate
		ELSE 0
	END AS TaxRate,
	crc.CurrencyCode,
	ac.AverageRate
FROM dbo.StateProvince AS sp
INNER JOIN Sales.SalesTaxRate AS tr 
	ON tr.StateProvinceID = sp.StateProvinceID
INNER JOIN Sales.CountryRegionCurrency AS crc 
	ON crc.CountryRegionCode = sp.CountryRegionCode
INNER JOIN avrgCurrency AS ac 
	ON ac.CurrencyCode = crc.CurrencyCode
WHERE tr.TaxType = 1 OR tr.TaxType IS NULL;

SELECT * FROM dbo.#StateProvince;
GO

/* d) ������� �� ������� dbo.StateProvince ������, ��� CountryRegionCode=�CA� */

DELETE 
FROM dbo.StateProvince 
WHERE CountryRegionCode = 'CA';

/* e) �������� Merge ���������, ������������ dbo.StateProvince ��� target, 
	� ��������� ������� ��� source. ��� ����� target � source ����������� StateProvinceID. 
	�������� ���� TaxRate, CurrencyCode � AverageRate, ���� ������ ������������ � source � target. 
	���� ������ ������������ �� ��������� �������, �� �� ���������� � target, �������� ������ � dbo.StateProvince. 
	���� � dbo.StateProvince ������������ ����� ������, ������� �� ���������� �� ��������� �������, 
	������� ������ �� dbo.StateProvince. */

MERGE dbo.StateProvince AS t_target
USING dbo.#StateProvince AS t_source
ON t_target.StateProvinceID = t_source.StateProvinceID
WHEN MATCHED THEN UPDATE SET	
	t_target.TaxRate = t_source.TaxRate,
	t_target.CurrencyCode = t_source.CurrencyCode,
	t_target.AverageRate = t_source.AverageRate
WHEN NOT MATCHED BY TARGET THEN	INSERT 
(
	StateProvinceID, 
	StateProvinceCode, 
	CountryRegionCode,
	IsOnlyStateProvinceFlag,
	Name,
	TerritoryID,
	ModifiedDate,
	TaxRate,
	CurrencyCode,
	AverageRate
)
VALUES
(
	t_source.StateProvinceID, 
	t_source.StateProvinceCode, 
	t_source.CountryRegionCode,
	t_source.IsOnlyStateProvinceFlag,
	t_source.Name,
	t_source.TerritoryID,
	t_source.ModifiedDate,
	t_source.TaxRate,
	t_source.CurrencyCode,
	t_source.AverageRate
)
WHEN NOT MATCHED BY SOURCE THEN DELETE;

SELECT * FROM dbo.StateProvince;
GO