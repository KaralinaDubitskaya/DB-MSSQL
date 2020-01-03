/* Дубицкая Каролина, гр.651001, Вариант 9 
   Лабораторная работа 2, Задание 2 */

USE AdventureWorks2012;
GO

/*a) создайте таблицу dbo.StateProvince с такой же структурой как Person.StateProvince,
     кроме поля uniqueidentifier, не включая индексы, ограничения и триггеры;  */

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

/*b) используя инструкцию ALTER TABLE, создайте для таблицы dbo.StateProvince 
     составной первичный ключ из полей StateProvinceID и StateProvinceCode */

ALTER TABLE dbo.StateProvince
ADD CONSTRAINT PK_StateProvince PRIMARY KEY (StateProvinceID, StateProvinceCode);

/*c) используя инструкцию ALTER TABLE, создайте для таблицы dbo.StateProvince 
     ограничение для поля TerritoryID, чтобы значение поля могло содержать 
	 только четные цифры  */

ALTER TABLE dbo.StateProvince
ADD CONSTRAINT CheckTerritoryID CHECK (TerritoryID % 2 = 0);

/*d) используя инструкцию ALTER TABLE, создайте для таблицы dbo.StateProvince
     ограничение DEFAULT для поля TerritoryID, задайте значение по умолчанию 2;  */

ALTER TABLE dbo.StateProvince
ADD CONSTRAINT DF_TerritoryID DEFAULT 2 FOR TerritoryID;

/*e) заполните новую таблицу данными из Person.StateProvince. Выберите 
     для вставки только те адреса, которые имеют тип ‘Shipping’ в таблице 
	 Person.AddressType. С помощью оконных функций для группы данных из полей 
	 StateProvinceID и StateProvinceCode выберите только строки с максимальным 
	 AddressID. Поле TerritoryID заполните значениями по умолчанию;  */

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

/*f) измените тип поля IsOnlyStateProvinceFlag на smallint, разрешите добавление null значений.  */
ALTER TABLE dbo.StateProvince
ALTER COLUMN IsOnlyStateProvinceFlag smallint NULL;