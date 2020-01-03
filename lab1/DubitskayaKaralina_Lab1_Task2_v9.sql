/* �������� ��������, ��.651001, ������� 9 
   ������������ ������ 1, ������� 2 */

USE master;
GO

RESTORE DATABASE AdventureWorks2012
	FROM DISK = 'D:\university\7 ���\��\aw2012fdb\AdventureWorks2012-Full Database Backup.bak'
	WITH
		MOVE 'AdventureWorks2012_Data' TO 'D:\university\7 ���\��\aw2012fdb\AdventureWorks2012_Data.mdf',
		MOVE 'AdventureWorks2012_Log' TO 'D:\university\7 ���\��\aw2012fdb\AdventureWorks2012_Log.mdf';
GO 

USE AdventureWorks2012;
GO


/* ������� 9 */

/*  ������� �� ����� �����������, ������� �������� ����� 1980 ���� (�� �� � 1980 ���)
    � ���� ������� �� ������ ����� 1-��� ������ 2003 ����.  */

SELECT em.BusinessEntityID, em.JobTitle, em.BirthDate, em.HireDate
FROM HumanResources.Employee em
WHERE em.BirthDate >= '1981-01-01' AND em.HireDate >= '2003-04-01';

/*  ������� �� ����� ����� ����� ������� � ����� ���������� ����� � �����������. 
    �������� ������� � ������������ �SumVacationHours� � �SumSickLeaveHours� 
	��� �������� � ���������� ��������������.  */

SELECT SUM(em.VacationHours) 'SumVacationHours', SUM(em.SickLeaveHours) 'SumSickLeaveHours'
FROM HumanResources.Employee em;

/*  ������� �� ����� ������ ���� �����������, ������� ������ ���� ��������� ������� �� ������.   */

SELECT TOP 3 em.BusinessEntityID, em.JobTitle, em.Gender, em.BirthDate, em.HireDate
FROM HumanResources.Employee em
ORDER BY em.HireDate;