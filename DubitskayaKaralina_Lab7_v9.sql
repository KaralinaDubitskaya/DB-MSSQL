/* Дубицкая Каролина, гр.651001, Вариант 9 
   Лабораторная работа 7 */
   
USE AdventureWorks2012;
GO

/*  Вывести значения полей [StartDate], [EndDate] из таблицы [HumanResources].[EmployeeDepartmentHistory] 
	и полей [GroupName] и [Name] из таблицы [HumanResources].[Department] в виде xml, 
	сохраненного в переменную. Формат xml должен соответствовать примеру. */

DECLARE @xml XML;

SET @xml = (
    SELECT
        dh.StartDate AS 'Start',
        dh.EndDate AS 'End',
        d.GroupName AS 'Department/Group',
        d.Name AS 'Department/Name'
    FROM
        HumanResources.EmployeeDepartmentHistory AS dh 
        INNER JOIN HumanResources.Department AS d
            ON dh.DepartmentID = d.DepartmentID
    FOR XML
        PATH ('Transaction'),
        ROOT ('History')
);

SELECT @xml;

/*  Создать временную таблицу, состоящую из 1 колонки и заполнить её xml, содержащимся в тегах Department. */

CREATE TABLE dbo.#Department
(
    [sql] NVARCHAR(250)
);

INSERT INTO dbo.#Department 
SELECT [sql] = CONVERT(VARCHAR(250), xml.node.query('.'))
FROM @xml.nodes('/History/Transaction/Department') AS xml(node);
GO

SELECT [sql] FROM dbo.#Department;