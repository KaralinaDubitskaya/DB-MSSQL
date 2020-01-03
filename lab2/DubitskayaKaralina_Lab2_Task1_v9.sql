/* �������� ��������, ��.651001, ������� 9 
   ������������ ������ 2, ������� 1 */
   
USE AdventureWorks2012;
GO

/*  ������� �� ����� ������� �������� ��������� ������ ��� ������� ����������.  */

SELECT em.BusinessEntityID, em.JobTitle, AVG(ph.Rate) as AverageRate
FROM HumanResources.Employee em
INNER JOIN HumanResources.EmployeePayHistory ph ON em.BusinessEntityID = ph.BusinessEntityID
GROUP BY em.BusinessEntityID, em.JobTitle;

/*  ������� �� ����� ������� ��������� ������ ����������� � ����������� ��� ������
    ��� �������� � �������. ���� ������ ������ ��� ����� 50 ������� �less or equal 50�;
	������ 50, �� ������ ��� ����� 100 � ������� �more than 50 but less or equal 100�;
	���� ������ ������ 100 ������� �more than 100�.*/

SELECT em.BusinessEntityID, em.JobTitle, ph.Rate,
	CASE 
		WHEN ph.Rate <= 50 
			THEN 'Less or equal 50'
		WHEN ph.Rate > 50 AND ph.Rate <= 100 
			THEN 'More than 50 but less or equal 100'
		ELSE 'More than 100'
	END RateReport
FROM HumanResources.Employee em
INNER JOIN HumanResources.EmployeePayHistory ph
ON em.BusinessEntityID = ph.BusinessEntityID;

/*  ��������� ������������ ��������� ������ ���������� � ��������� ������ ����������� � ������ ������.
    ������� �� ����� �������� �������, � ������� ������������ ��������� ������ ������ 60. 
	������������� ��������� �� �������� ������������ ������.  */

SELECT d.Name, MAX(ph.Rate) MaxRate
FROM HumanResources.EmployeeDepartmentHistory edh
INNER JOIN HumanResources.Department d ON d.DepartmentID = edh.DepartmentID
INNER JOIN HumanResources.EmployeePayHistory ph ON ph.BusinessEntityID = edh.BusinessEntityID
GROUP BY d.Name
HAVING MAX(ph.Rate) >= 61
ORDER BY MaxRate;