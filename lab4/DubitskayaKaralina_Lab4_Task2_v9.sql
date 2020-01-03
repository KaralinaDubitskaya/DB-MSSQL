/* Дубицкая Каролина, гр.651001, Вариант 9 
   Лабораторная работа 4, Задание 2 */

USE AdventureWorks2012;
GO

/* a) Создайте представление VIEW, отображающее данные из таблиц Sales.SpecialOffer 
	и Sales.SpecialOfferProduct, а также Name из таблицы Production.Product. 
	Создайте уникальный кластерный индекс в представлении по полям ProductID, SpecialOfferID. */

CREATE VIEW Sales.vSpecialOfferAndProduct (
	SpecialOfferID,
	ProductID,
	Name,
	Description,
	DiscountPct,
	Type,
	Category,
	StartDate,
	EndDate,
	MinQty,
	MaxQty,
	ModifiedDate,
	rowguid
)
WITH SCHEMABINDING 
AS
SELECT 
	so.SpecialOfferID,
	sop.ProductID,
	p.Name,
	so.Description,
	so.DiscountPct,
	so.Type,
	so.Category,
	so.StartDate,
	so.EndDate,
	so.MinQty,
	so.MaxQty,
	so.ModifiedDate,
	so.rowguid
FROM Sales.SpecialOffer AS so
	INNER JOIN Sales.SpecialOfferProduct AS sop
		ON sop.SpecialOfferID = so.SpecialOfferID
	INNER JOIN Production.Product AS p 
		ON p.ProductID = sop.ProductID;
GO

CREATE UNIQUE CLUSTERED INDEX IX_vSpecialOfferAndProduct_ProductID_SpecialOfferID
ON Sales.vSpecialOfferAndProduct (ProductId, SpecialOfferID);
GO

/* b) Создайте один INSTEAD OF триггер для представления на три операции INSERT, UPDATE, DELETE. 
	Триггер должен выполнять соответствующие операции в таблицах Sales.SpecialOffer и Sales.SpecialOfferProduct 
	для указанного Product Name. Обновление не должно происходить в таблице Sales.SpecialOfferProduct. 
	Удаление из таблицы Sales.SpecialOffer производите только в том случае, если удаляемые строки больше 
	не ссылаются на Sales.SpecialOfferProduct. */

CREATE TRIGGER Sales.Trg_vSpecialOfferAndProductView_Insert_Update_Delete ON Sales.vSpecialOfferAndProduct
INSTEAD OF INSERT, UPDATE, DELETE AS
BEGIN
	IF EXISTS (SELECT * FROM inserted)
	BEGIN
		IF EXISTS (
			SELECT * 
			FROM vSpecialOfferAndProduct AS v 
			JOIN inserted AS ins
				ON ins.ProductID = v.ProductID 
				   AND ins.SpecialOfferID = v.SpecialOfferID)
		BEGIN
			UPDATE Sales.SpecialOffer SET
				Description = ins.Description,
				DiscountPct = ins.DiscountPct,
				Type = ins.Type,
				Category = ins.Category,
				StartDate = ins.StartDate,
				EndDate = ins.EndDate,
				MinQty = ins.MinQty,
				MaxQty = ins.MaxQty,
				ModifiedDate = GETDATE(),
				rowguid = ins.rowguid
			FROM inserted AS ins
			WHERE ins.SpecialOfferID = Sales.SpecialOffer.SpecialOfferID
		END
		ELSE
		BEGIN
			-- insert
			INSERT INTO Sales.SpecialOffer (
				Description,
				DiscountPct,
				Type,
				Category,
				StartDate,
				EndDate,
				MinQty,
				MaxQty,
				ModifiedDate,
				rowguid)
			SELECT 
				Description = ins.Description,
				DiscountPct = ins.DiscountPct,
				Type = ins.Type,
				Category = ins.Category,
				StartDate = ins.StartDate,
				EndDate = ins.EndDate,
				MinQty = ins.MinQty,
				MaxQty = ins.MaxQty,
				ModifiedDate = GETDATE(),
				rowguid = ins.rowguid
			FROM inserted AS ins;

			INSERT INTO Sales.SpecialOfferProduct (
				SpecialOfferID,
				ProductID,
				ModifiedDate,
				rowguid)
			SELECT 
				so.SpecialOfferID,
				ins.ProductID,
				GETDATE(),
				NEWID()
			FROM inserted AS ins
			JOIN Sales.SpecialOffer AS so 
				ON so.rowguid = ins.rowguid
		END
	END

	IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
	BEGIN
		DELETE FROM Sales.SpecialOfferProduct 
		WHERE ProductID IN (SELECT ProductID FROM deleted)

		DELETE FROM Sales.SpecialOffer 
		WHERE SpecialOfferID IN (SELECT SpecialOfferID FROM deleted) 
		AND SpecialOfferID NOT IN (SELECT SpecialOfferID FROM Sales.SpecialOfferProduct)
	END
END;
GO

/* c) Вставьте новую строку в представление, указав новые данные SpecialOffer для существующего Product 
	(например для ‘Adjustable Race’). Триггер должен добавить новые строки в таблицы Sales.SpecialOffer 
	и Sales.SpecialOfferProduct. Обновите вставленные строки через представление. Удалите строки. */

INSERT INTO Sales.vSpecialOfferAndProduct (
	ProductID,
	Description,
	DiscountPct,
	Type,
	Category,
	StartDate,
	EndDate,
	MinQty,
	MaxQty,
	rowguid
)
VALUES (1, 'NY Special Offer', 0.20, 'Volume Discount', 'Reseller', GETDATE(), GETDATE(), 0, 15, NEWID());

UPDATE Sales.vSpecialOfferAndProduct SET
	DiscountPct = 0.50
WHERE Description = 'NY Special Offer';

DELETE FROM Sales.vSpecialOfferAndProduct
WHERE Description = 'NY Special Offer';