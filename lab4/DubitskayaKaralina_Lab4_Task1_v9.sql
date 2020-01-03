/* Дубицкая Каролина, гр.651001, Вариант 9 
   Лабораторная работа 4, Задание 1 */

USE AdventureWorks2012;
GO

/* a) Создайте таблицу Sales.SpecialOfferHst, которая будет хранить 
	информацию об изменениях в таблице Sales.SpecialOffer.
	Обязательные поля, которые должны присутствовать в таблице: 
		ID — первичный ключ IDENTITY(1,1); 
		Action — совершенное действие (insert, update или delete); 
		ModifiedDate — дата и время, когда была совершена операция; 
		SourceID — первичный ключ исходной таблицы; 
		UserName — имя пользователя, совершившего операцию. 
	Создайте другие поля, если считаете их нужными. */

CREATE TABLE Sales.SpecialOfferHst (
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	Action CHAR(6) NOT NULL CHECK (Action IN('INSERT', 'UPDATE', 'DELETE')),
	ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
	SourceID INT NOT NULL,
	UserName VARCHAR(50) NOT NULL
);
GO

/* b) Создайте три AFTER триггера для трех операций INSERT, UPDATE, DELETE для таблицы Sales.SpecialOffer. 
	Каждый триггер должен заполнять таблицу Sales.SpecialOfferHst с указанием типа операции в поле Action. */

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

/* c) Создайте представление VIEW, отображающее все поля таблицы Sales.SpecialOffer. 
	Сделайте невозможным просмотр исходного кода представления. */

CREATE VIEW Sales.vSpecialOffer
WITH ENCRYPTION
AS 
	SELECT * FROM Sales.SpecialOffer;
GO

/* d) Вставьте новую строку в Sales.SpecialOffer через представление. Обновите вставленную строку. 
	Удалите вставленную строку. Убедитесь, что все три операции отображены в Sales.SpecialOfferHst. */

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