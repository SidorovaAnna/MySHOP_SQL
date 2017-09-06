CREATE DATABASE MySHOP
ON
(
	NAME = 'MySHOP',
	FILENAME = 'D:\Git\MySHOP_SQL\MySHOP.mdf',
	SIZE = 10MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 10MB
)

LOG ON
(
	NAME = 'LogMySHOP',
	FILENAME = 'D:\Git\MySHOP_SQL\MySHOP.ldf',
	SIZE = 5MB,
	MAXSIZE = 50MB,
	FILEGROWTH = 5MB
)

COLLATE Cyrillic_General_CI_AS
GO

USE MySHOP
GO

--Создание таблиц с данными клиентов, заказами, товарами, остатками на складе,  

CREATE TABLE Products 
(
	ID int NOT NULL IDENTITY,
	Name nvarchar(80) NOT NULL,
)
GO

CREATE TABLE ProductDetails
(
	ID int NOT NULL,
	Color nchar(20) NULL,
	CountryOfOrigin nvarchar(50) NULL,
	[Weight] char(10) NULL,
    [Description] nvarchar(max) NULL,     
)
GO

CREATE TABLE Stocks
(
	ProductID int NOT NULL,
	Qty int DEFAULT 0
)
GO

CREATE TABLE Customers
(
	ID int NOT NULL IDENTITY,
	FName nvarchar(20) NOT NULL,
	LName nvarchar(20) NULL,
	[Address] nvarchar(50) NULL,
	City nvarchar(20) NULL,
	Phone char(12) NULL,
	Email nvarchar(20) NOT NULL,
	DateInSystem date DEFAULT GETDATE()
)
GO

CREATE TABLE Orders
(
	ID int NOT NULL IDENTITY,
	CustomerID int NULL,
	OrderDate date DEFAULT GETDATE()
)
GO

CREATE TABLE OrderDetails
(
	OrderID int NOT NULL,
	LineItem int NOT NULL,
	ProductID int NULL,
	Qty int NOT NULL,
	Price money NOT NULL,
	TotalPrice AS CONVERT(money, Qty*Price) 
)  
GO

--Создание ограничений CHECK 
/*а)на номер телефона (начинается с "7", далее цифры без пробелов, 
б)остатки не могут быть меньше нуля, 
в)даты создания заказов и регистрации юзеров
не могут быть раньше создания магазина
магазин открылся 10 дней назад */

ALTER TABLE Customers
	ADD CONSTRAINT CN_Customers_Phone
	CHECK (Phone LIKE '7[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')	 
GO

ALTER TABLE Stocks
	ADD CONSTRAINT CN_Stocks_Qty
	CHECK (Qty >= 0)
GO

ALTER TABLE Orders
	ADD CONSTRAINT CN_Orders_OrderDate
	CHECK (OrderDate >= DATEADD(DAY, -10, GETDATE()) AND OrderDate <= GETDATE())
GO

ALTER TABLE Customers
	ADD CONSTRAINT CN_Customers_DateInSystem
	CHECK (DateInSystem >= DATEADD(DAY, -10, GETDATE()) AND DateInSystem <= GETDATE())
GO


--Создание связей между таблицами (PK и FK)
ALTER TABLE Products
	ADD CONSTRAINT PK_Products PRIMARY KEY (ID) 
GO

ALTER TABLE ProductDetails
	ADD CONSTRAINT FK_ProductDetails FOREIGN KEY (ID) 
	REFERENCES Products(ID) 
	ON DELETE CASCADE
GO

ALTER TABLE Stocks
	ADD CONSTRAINT FK_ProductID FOREIGN KEY (ProductID)
	REFERENCES Products(ID) 
	ON DELETE CASCADE
GO

ALTER TABLE Customers
	ADD CONSTRAINT PK_CustomersID PRIMARY KEY (ID)
GO

ALTER TABLE Orders
	ADD CONSTRAINT PK_OrdersID PRIMARY KEY (ID)
GO

ALTER TABLE Orders 
	ADD CONSTRAINT FK_Orders_Customers FOREIGN KEY(CustomerID) 
	REFERENCES Customers(ID) 
	ON DELETE SET NULL  
GO

ALTER TABLE OrderDetails ADD CONSTRAINT
	PK_OrderDetails PRIMARY KEY
	(OrderID,LineItem) 
GO

ALTER TABLE OrderDetails ADD CONSTRAINT
	FK_OrderDetails_Orders FOREIGN KEY(OrderID) 
	REFERENCES Orders(ID) 
	ON DELETE CASCADE
GO

ALTER TABLE OrderDetails ADD CONSTRAINT
	FK_OrderDetails_Products FOREIGN KEY(ProductID) 
	REFERENCES Products(ID) 
		ON DELETE SET NULL 
GO

--Заполнение таблиц


--Запросы
--Функции

