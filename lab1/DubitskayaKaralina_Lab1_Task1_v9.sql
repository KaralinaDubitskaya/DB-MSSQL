/* �������� ��������, ��.651001, ������� 9 
   ������������ ������ 1, ������� 1 */

USE master;
GO

CREATE DATABASE NewDatabase;
GO

USE NewDatabase;
GO

CREATE SCHEMA sales;
GO

CREATE SCHEMA persons;
GO

CREATE TABLE sales.Orders (OrderNum INT NULL);
GO

BACKUP DATABASE NewDatabase
	TO DISK = 'D:\SQLServerBackups\NewDatabase.bak';
GO

USE master;
GO

DROP DATABASE NewDatabase;
GO

RESTORE DATABASE NewDatabase	
	FROM DISK = 'D:\SQLServerBackups\NewDatabase.bak';
GO