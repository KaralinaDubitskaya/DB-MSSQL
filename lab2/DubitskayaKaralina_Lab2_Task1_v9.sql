/* Дубицкая Каролина, гр.651001, Вариант 9 
   Лабораторная работа 2, Задание 1 */
   
USE AdventureWorks2012;
GO

/*  Вывести на экран среднее значение почасовой ставки для каждого сотрудника.  */

SELECT em.BusinessEntityID, em.JobTitle, AVG(ph.Rate) as AverageRate
FROM HumanResources.Employee em
INNER JOIN HumanResources.EmployeePayHistory ph ON em.BusinessEntityID = ph.BusinessEntityID
GROUP BY em.BusinessEntityID, em.JobTitle;

/*  Вывести на экран историю почасовых ставок сотрудников с информацией для отчета
    как показано в примере. Если ставка меньше или равна 50 вывести ‘less or equal 50’;
	больше 50, но меньше или равна 100 – вывести ‘more than 50 but less or equal 100’;
	если ставка больше 100 вывести ‘more than 100’.*/

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

/*  Вычислить максимальную почасовую ставку работающих в настоящий момент сотрудников в каждом отделе.
    Вывести на экран названия отделов, в которых максимальная почасовая ставка больше 60. 
	Отсортировать результат по значению максимальной ставки.  */

SELECT d.Name, MAX(ph.Rate) MaxRate
FROM HumanResources.EmployeeDepartmentHistory edh
INNER JOIN HumanResources.Department d ON d.DepartmentID = edh.DepartmentID
INNER JOIN HumanResources.EmployeePayHistory ph ON ph.BusinessEntityID = edh.BusinessEntityID
GROUP BY d.Name
HAVING MAX(ph.Rate) >= 61
ORDER BY MaxRate;