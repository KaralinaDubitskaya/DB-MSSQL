/* Дубицкая Каролина, гр.651001, Вариант 9 
   Лабораторная работа 1, Задание 2 */

USE master;
GO

RESTORE DATABASE AdventureWorks2012
	FROM DISK = 'D:\university\7 сем\БД\aw2012fdb\AdventureWorks2012-Full Database Backup.bak'
	WITH
		MOVE 'AdventureWorks2012_Data' TO 'D:\university\7 сем\БД\aw2012fdb\AdventureWorks2012_Data.mdf',
		MOVE 'AdventureWorks2012_Log' TO 'D:\university\7 сем\БД\aw2012fdb\AdventureWorks2012_Log.mdf';
GO 

USE AdventureWorks2012;
GO


/* ВАРИАНТ 9 */

/*  Вывести на экран сотрудников, которые родились позже 1980 года (но не в 1980 год)
    и были приняты на работу позже 1-ого апреля 2003 года.  */

SELECT em.BusinessEntityID, em.JobTitle, em.BirthDate, em.HireDate
FROM HumanResources.Employee em
WHERE em.BirthDate >= '1981-01-01' AND em.HireDate >= '2003-04-01';

/*  Вывести на экран сумму часов отпуска и сумму больничных часов у сотрудников. 
    Назовите столбцы с результатами ‘SumVacationHours’ и ‘SumSickLeaveHours’ 
	для отпусков и больничных соответственно.  */

SELECT SUM(em.VacationHours) 'SumVacationHours', SUM(em.SickLeaveHours) 'SumSickLeaveHours'
FROM HumanResources.Employee em;

/*  Вывести на экран первых трех сотрудников, которых раньше всех остальных приняли на работу.   */

SELECT TOP 3 em.BusinessEntityID, em.JobTitle, em.Gender, em.BirthDate, em.HireDate
FROM HumanResources.Employee em
ORDER BY em.HireDate;