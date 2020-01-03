/* Дубицкая Каролина, гр.651001, Вариант 9 
   Лабораторная работа 5 */
   
USE AdventureWorks2012;
GO

/*  Создайте scalar-valued функцию, которая будет принимать в качестве входного параметра
	начальную дату специального предложения (Sales.SpecialOffer.SpecialOfferID) 
	и возвращать строку, содержащую название месяца, день и день недели 
	для заданной даты (June, 1. Wednesday). */

CREATE FUNCTION Sales.GetSpecialOfferStartDate(@SpecialOfferID INT) 
RETURNS NVARCHAR(50) AS
BEGIN
	DECLARE @StartDateStr NVARCHAR(50);

	SELECT @StartDateStr = FORMAT(StartDate, 'MMMM, d. dddd')
	FROM Sales.SpecialOffer 
	WHERE SpecialOfferID = @SpecialOfferID

	RETURN @StartDateStr
END;
GO

SELECT Sales.GetSpecialOfferStartDate (10);
GO

/*  Создайте inline table-valued функцию, которая будет принимать в качестве входного 
	параметра id специального предложения (Sales.SpecialOffer.SpecialOfferID), 
	а возвращать список продуктов, участвующих в предложении (Production.Product). */

CREATE FUNCTION Sales.GetSpecialOfferProducts(@SpecialOfferID INT) 
RETURNS TABLE AS
RETURN
(
	SELECT p.*
	FROM Sales.SpecialOffer AS so
	INNER JOIN Sales.SpecialOfferProduct AS sop 
		ON sop.SpecialOfferID = so.SpecialOfferID
	INNER JOIN Production.Product AS p 
		ON p.ProductID = sop.ProductID
);
GO

WHERE so.SpecialOfferID = @SpecialOfferID

DROP FUNCTION Sales.GetSpecialOfferProducts;
GO

SELECT * FROM Sales.GetSpecialOfferProducts(10);
GO

/*  Вызовите функцию для каждого предложения, применив оператор CROSS APPLY. 
	Вызовите функцию для каждого предложения, применив оператор OUTER APPLY. */

/* Если в функции вместо INNER использовать LEFT JOIN, OUTER APPLY будет в отличие от
   CROSS APPLY выведет также строки из таблицы Sales.SpecialOffer, для которых не определен Product */

SELECT * FROM Sales.SpecialOffer CROSS APPLY Sales.GetSpecialOfferProducts(SpecialOfferID);
SELECT * FROM Sales.SpecialOffer OUTER APPLY Sales.GetSpecialOfferProducts(SpecialOfferID);
GO

/* Измените созданную inline table-valued функцию, сделав ее multistatement table-valued 
   (предварительно сохранив для проверки код создания inline table-valued функции). */

DROP FUNCTION Sales.GetSpecialOfferProducts;
GO

CREATE FUNCTION Sales.GetSpecialOfferProducts(@SpecialOfferID INT) 
RETURNS @result TABLE (
	ProductID int NOT NULL,
	Name dbo.Name NOT NULL,
	ProductNumber nvarchar(25) NOT NULL,
	MakeFlag dbo.Flag NOT NULL,
	FinishedGoodsFlag dbo.Flag NOT NULL,
	Color nvarchar(15) NULL,
	SafetyStockLevel smallint NOT NULL,
	ReorderPoint smallint NOT NULL,
	StandardCost money NOT NULL,
	ListPrice money NOT NULL,
	Size nvarchar(5) NULL,
	SizeUnitMeasureCode nchar(3) NULL,
	WeightUnitMeasureCode nchar(3) NULL,
	Weight decimal(8, 2) NULL,
	DaysToManufacture int NOT NULL,
	ProductLine nchar(2) NULL,
	Class nchar(2) NULL,
	Style nchar(2) NULL,
	ProductSubcategoryID int NULL,
	ProductModelID int NULL,
	SellStartDate datetime NOT NULL,
	SellEndDate datetime NULL,
	DiscontinuedDate datetime NULL,
	rowguid uniqueidentifier ROWGUIDCOL  NOT NULL,
	ModifiedDate datetime NOT NULL) AS 
BEGIN
	INSERT INTO @result
	SELECT 
		p.ProductID,
		p.Name,
		p.ProductNumber,
		p.MakeFlag,
		p.FinishedGoodsFlag,
		p.Color,
		p.SafetyStockLevel,
		p.ReorderPoint,
		p.StandardCost,
		p.ListPrice,
		p.Size,
		p.SizeUnitMeasureCode,
		p.WeightUnitMeasureCode,
		p.Weight,
		p.DaysToManufacture,
		p.ProductLine,
		p.Class,
		p.Style,
		p.ProductSubcategoryID,
		p.ProductModelID,
		p.SellStartDate,
		p.SellEndDate,
		p.DiscontinuedDate,
		p.rowguid,
		p.ModifiedDate
	FROM Sales.SpecialOffer AS so
	INNER JOIN Sales.SpecialOfferProduct AS sop 
		ON sop.SpecialOfferID = so.SpecialOfferID
	INNER JOIN Production.Product AS p 
		ON p.ProductID = sop.ProductID;
	RETURN
END;
GO

SELECT * FROM Sales.GetSpecialOfferProducts(10);
GO