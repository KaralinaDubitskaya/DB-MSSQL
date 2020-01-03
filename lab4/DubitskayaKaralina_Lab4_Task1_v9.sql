/* �������� ��������, ��.651001, ������� 9 
   ������������ ������ 4, ������� 1 */

USE AdventureWorks2012;
GO

/* a) �������� ������� Sales.SpecialOfferHst, ������� ����� ������� 
	���������� �� ���������� � ������� Sales.SpecialOffer.
	������������ ����, ������� ������ �������������� � �������: 
		ID � ��������� ���� IDENTITY(1,1); 
		Action � ����������� �������� (insert, update ��� delete); 
		ModifiedDate � ���� � �����, ����� ���� ��������� ��������; 
		SourceID � ��������� ���� �������� �������; 
		UserName � ��� ������������, ������������ ��������. 
	�������� ������ ����, ���� �������� �� �������. */

CREATE TABLE Sales.SpecialOfferHst (
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	Action CHAR(6) NOT NULL CHECK (Action IN('INSERT', 'UPDATE', 'DELETE')),
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
	SourceID INT NOT NULL,
	UserName VARCHAR(50) NOT NULL
);
GO

/* b) �������� ��� AFTER �������� ��� ���� �������� INSERT, UPDATE, DELETE ��� ������� Sales.SpecialOffer. 
	������ ������� ������ ��������� ������� Sales.SpecialOfferHst � ��������� ���� �������� � ���� Action. */

CREATE TRIGGER Sales.SpecialOffer_Insert
ON Sales.SpecialOffer
AFTER INSERT AS
	INSERT INTO Sales.SpecialOfferHst(Action, ModifiedDate, SourceID, UserName)
	SELECT 'INSERT', GETDATE(), ins.SpecialOfferID, USER_NAME()
	FROM inserted AS ins;

CREATE TRIGGER Sales.SpecialOffer_Update
ON Sales.SpecialOffer
AFTER UPDATE AS
	INSERT INTO Sales.SpecialOfferHst(Action, ModifiedDate, SourceID, UserName)
	SELECT 'UPDATE', GETDATE(), ins.SpecialOfferID, USER_NAME()
	FROM inserted AS ins;

CREATE TRIGGER Sales.SpecialOffer_Delete
ON Sales.SpecialOffer
AFTER DELETE AS
	INSERT INTO Sales.SpecialOfferHst(Action, ModifiedDate, SourceID, UserName)
	SELECT 'DELETE', GETDATE(), del.SpecialOfferID, USER_NAME()
	FROM deleted AS del;

/* c) �������� ������������� VIEW, ������������ ��� ���� ������� Sales.SpecialOffer. 
	�������� ����������� �������� ��������� ���� �������������. */

CREATE VIEW Sales.vSpecialOffer
WITH ENCRYPTION
AS 
	SELECT * FROM Sales.SpecialOffer;
GO

/* d) �������� ����� ������ � Sales.SpecialOffer ����� �������������. �������� ����������� ������. 
	������� ����������� ������. ���������, ��� ��� ��� �������� ���������� � Sales.SpecialOfferHst. */

INSERT INTO Sales.vSpecialOffer (
	Description, 
	DiscountPct, 
	Type,
	Category, 
	StartDate,
	EndDate, 
	MinQty,
	MaxQty)
VALUES ('New Year Discount', 0.10, 'Discount', 'Customer', GetDate(), GetDate(), 11, 10);

UPDATE Sales.vSpecialOffer SET Description = 'NY Discount' WHERE Description = 'New Year Discount';

DELETE Sales.vSpecialOffer WHERE Description = 'NY Discount';

SELECT * 
FROM Sales.SpecialOfferHst;