/* Дубицкая Каролина, гр.651001, Вариант 9 
   Лабораторная работа 6 */
   
USE AdventureWorks2012;
GO

/*  Создайте хранимую процедуру, которая будет возвращать сводную таблицу (оператор PIVOT), 
	отображающую данные о максимальной скидке для продуктов (Sales.SpecialOffer) 
	по определенной категории (Sales.SpecialOffer.Category). 
	Список категорий скидок передайте в процедуру через входной параметр.

	Таким образом, вызов процедуры будет выглядеть следующим образом:

	EXECUTE dbo.WorkOrdersByMonths ‘[Reseller],[No Discount],[Customer]’ */

CREATE PROCEDURE dbo.MaxProductDiscountByCategory(@Categories NVARCHAR(255)) AS
	DECLARE @Query AS NVARCHAR(1024);
	SET @Query = '
		SELECT [Name],' + @Categories + '
		FROM (  
			SELECT p.Name, so.Category, so.DiscountPct
			FROM Sales.SpecialOffer AS so
				INNER JOIN Sales.SpecialOfferProduct AS sop 
					ON sop.SpecialOfferID = so.SpecialOfferID 
				INNER JOIN Production.Product AS p 
					ON p.ProductID = sop.ProductID) AS p
		PIVOT
		(
			MAX(DiscountPct)
			FOR p.Category IN (' + @Categories + ')
		) AS pvt'
    EXECUTE sp_executesql @Query;
GO

EXECUTE dbo.MaxProductDiscountByCategory '[Reseller],[No Discount],[Customer]';