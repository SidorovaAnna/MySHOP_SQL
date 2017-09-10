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
INSERT Customers (FName, LName, [Address], City, Phone, Email, DateInSystem)
VALUES 
('Иван', 'Иванов', 'Гагарина 36А', 'Москва', '79000000000', 'test0@mail.ru', DATEADD(DAY, -9, GETDATE())),
('Петр', 'Петров', 'Энтузиастов 10', 'Владивосток', '79000000001', 'test1@mail.ru',DATEADD(DAY, -9, GETDATE())),
('Марина', 'Морякова', 'Металлургов 7', 'Москва', '79000000002', 'test1@yandex.ru', DATEADD(DAY, -1, GETDATE())),
('Нина', 'Ноткина', 'Тройкина 7', 'Сызрань', '79000000003', 'test2@mail.ru', DATEADD(DAY, -5, GETDATE()));
GO

SELECT * FROM Customers

INSERT Orders (CustomerID, OrderDate)
VALUES 
(1, DATEADD(DAY, -9, GETDATE())),
(1, DATEADD(DAY, -8, GETDATE())),
(2, DATEADD(DAY, -7, GETDATE())),
(3, DATEADD(DAY, -8, GETDATE())),
(3, DATEADD(DAY, -0, GETDATE())),
(4, DATEADD(DAY, -4, GETDATE()));
GO

SELECT * FROM Orders

INSERT OrderDetails (OrderID, LineItem, ProductID, Qty, Price)
VALUES 
('1', '1', '2', '2', '300.00'),
('1', '2', '3', '2', '520.00'),
('2', '1', '7', '1', '1000.00'),
('3', '1', '7', '1', '1000.00'),
('3', '2', '1', '10', '255.00'),
('3', '3', '6', '2', '1000.00'),
('4', '1', '4', '15', '540.00'),
('4', '2', '5', '4', '120.00'),
('5', '1', '6', '3', '1000.00'),
('6', '1', '5', '6', '120.00');
GO

SELECT * FROM OrderDetails

INSERT Products ([Name])
VALUES 
('Пинцет изогнутый'),
('Пинцет прямой'),
('Ресницы цветные микс С'),
('Клей Брайт'),
('Клей Скай'),
('Лампа Рексант'),
('Ресницы цветные микс Д');
GO

SELECT * FROM Products

INSERT ProductDetails (ID, Color, CountryOfOrigin, [Weight], [Description])
VALUES 
('1', 'золото', 'Корея', '12', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean massa ex, imperdiet non elementum sit amet, tincidunt eget dui.'),
('2', 'мультицвет', 'Китай', '10', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean massa'),
('3', 'синие', 'Корея', '10', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean massa ex, imperdiet non elementum sit amet, tincidunt eget dui.'),
('4', '', 'Корея', '5', 'Lorem ipsum dolor sit amet'),
('5', '', 'Китай', '5', 'Lorem'),
('6', '', 'США', '2500', ''),
('7', 'зеленые', 'Корея', '10', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean massa ex, imperdiet non elementum sit amet, tincidunt eget dui.');
GO

SELECT * FROM ProductDetails

INSERT Stocks (ProductID, Qty)
VALUES 
('1', '100'),
('2', '200'),
('3', '5'),
('4', '100'),
('5', '250'),
('6', '1000'),
('7', '1');
GO

SELECT * FROM Stocks

--Запросы
--Функции

