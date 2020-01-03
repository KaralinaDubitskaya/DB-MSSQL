/* Дубицкая Каролина, гр.651001, Вариант 9 
   Лабораторная работа 3, Задание 2 */

USE AdventureWorks2012;
GO

/* a) выполните код, созданный во втором задании второй лабораторной работы. 
	Добавьте в таблицу dbo.StateProvince поля TaxRate SMALLMONEY, CurrencyCode NCHAR(3) 
	и AverageRate MONEY. Также создайте в таблице вычисляемое поле IntTaxRate, округляющее 
	значение в поле TaxRate в большую сторону до ближайшего целого. */

ALTER TABLE dbo.StateProvince
ADD 
	TaxRate SMALLMONEY, 
	CurrencyCode NCHAR(3), 
	AverageRate MONEY, 
	IntTaxRate AS CEILING(TaxRate)
GO

/*b) создайте временную таблицу #StateProvince, с первичным ключом по полю StateProvinceID. 
	Временная таблица должна включать все поля таблицы dbo.StateProvince за исключением 
	поля IntTaxRate. */

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

/* c) заполните временную таблицу данными из dbo.StateProvince. 
	Поле CurrencyCode заполните данными из таблицы Sales.Currency. 
	Поле TaxRate заполните значениями налоговой ставки к розничным сделкам (TaxType = 1) 
	из таблицы Sales.SalesTaxRate. Если для какого-то штата налоговая ставка не найдена, 
	заполните TaxRate нулем. Определите максимальное значение курса обмена валюты (AverageRate) 
	в таблице Sales.CurrencyRate для каждой валюты (указанной в поле ToCurrencyCode) 
	и заполните этими значениями поле AverageRate. Определение максимального курса для каждой 
	валюты осуществите в Common Table Expression (CTE). */

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

/* d) удалите из таблицы dbo.StateProvince строки, где CountryRegionCode=’CA’ */

DELETE 
FROM dbo.StateProvince 
WHERE CountryRegionCode = 'CA';

/* e) напишите Merge выражение, использующее dbo.StateProvince как target, 
	а временную таблицу как source. Для связи target и source используйте StateProvinceID. 
	Обновите поля TaxRate, CurrencyCode и AverageRate, если запись присутствует в source и target. 
	Если строка присутствует во временной таблице, но не существует в target, добавьте строку в dbo.StateProvince. 
	Если в dbo.StateProvince присутствует такая строка, которой не существует во временной таблице, 
	удалите строку из dbo.StateProvince. */

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