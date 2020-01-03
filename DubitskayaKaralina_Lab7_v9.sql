/* �������� ��������, ��.651001, ������� 9 
   ������������ ������ 7 */
   
USE AdventureWorks2012;
GO

/*  ������� �������� ����� [StartDate], [EndDate] �� ������� [HumanResources].[EmployeeDepartmentHistory] 
	� ����� [GroupName] � [Name] �� ������� [HumanResources].[Department] � ���� xml, 
	������������ � ����������. ������ xml ������ ��������������� �������. */

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

/*  ������� ��������� �������, ��������� �� 1 ������� � ��������� � xml, ������������ � ����� Department. */

CREATE TABLE dbo.#Department
(
    [sql] NVARCHAR(250)
);

INSERT INTO dbo.#Department 
SELECT [sql] = CONVERT(VARCHAR(250), xml.node.query('.'))
FROM @xml.nodes('/History/Transaction/Department') AS xml(node);
GO

SELECT [sql] FROM dbo.#Department;