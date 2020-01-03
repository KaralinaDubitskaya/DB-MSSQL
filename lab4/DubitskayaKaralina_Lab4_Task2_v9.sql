/* �������� ��������, ��.651001, ������� 9 
   ������������ ������ 4, ������� 2 */

USE AdventureWorks2012;
GO

/* a) �������� ������������� VIEW, ������������ ������ �� ������ Sales.SpecialOffer 
	� Sales.SpecialOfferProduct, � ����� Name �� ������� Production.Product. 
	�������� ���������� ���������� ������ � ������������� �� ����� ProductID, SpecialOfferID. */

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

/* b) �������� ���� INSTEAD OF ������� ��� ������������� �� ��� �������� INSERT, UPDATE, DELETE. 
	������� ������ ��������� ��������������� �������� � �������� Sales.SpecialOffer � Sales.SpecialOfferProduct 
	��� ���������� Product Name. ���������� �� ������ ����������� � ������� Sales.SpecialOfferProduct. 
	�������� �� ������� Sales.SpecialOffer ����������� ������ � ��� ������, ���� ��������� ������ ������ 
	�� ��������� �� Sales.SpecialOfferProduct. */

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

/* c) �������� ����� ������ � �������������, ������ ����� ������ SpecialOffer ��� ������������� Product 
	(�������� ��� �Adjustable Race�). ������� ������ �������� ����� ������ � ������� Sales.SpecialOffer 
	� Sales.SpecialOfferProduct. �������� ����������� ������ ����� �������������. ������� ������. */

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