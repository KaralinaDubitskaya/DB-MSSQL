/* Дубицкая Каролина, гр.651001, Вариант 9 
   Лабораторная работа 1, Задание 1 */

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