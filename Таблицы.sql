USE master
GO

DROP TABLE IF EXISTS dbo.brand;
-- Таблица автомобильных марок
CREATE TABLE brand (
  id int IDENTITY(1, 1) PRIMARY KEY,
  Name NVARCHAR(40) NOT NULL,
  Country NVARCHAR(40)
);

DROP TABLE IF EXISTS dbo.stock;
-- Таблица склада с моделями авто
CREATE TABLE stock (
  id int IDENTITY(1, 1) PRIMARY KEY,
  id_brand int FOREIGN KEY REFERENCES brand (id),
  Name NVARCHAR(40) NOT NULL,
  Count INT NOT NULL CHECK (Count>=0),
  Price MONEY NOT NULL CHECK (Price>=0)
);

DROP TABLE IF EXISTS dbo.clients;
-- Таблтца с клиентами
CREATE TABLE clients (
  id int IDENTITY(1, 1) PRIMARY KEY,
  Name NVARCHAR(40) NOT NULL,
  Number NVARCHAR(40)
);

DROP TABLE IF EXISTS dbo.agents;
-- Таблица с менеджерами продаж
CREATE TABLE agents (
  id int IDENTITY(1, 1) PRIMARY KEY,
  Name NVARCHAR(40) NOT NULL,
  Date DATE NOT NULL
);

DROP TABLE IF EXISTS dbo.sales;
-- Таблица с продажами
CREATE TABLE sales (
  id int IDENTITY(1, 1),
  id_client int FOREIGN KEY REFERENCES clients (id),
  id_agent int FOREIGN KEY REFERENCES agents (id),
  id_auto int FOREIGN KEY REFERENCES stock (id),
  Price MONEY CHECK (Price>0),
  Date DATE
);

DROP INDEX IF EXISTS brand_name_idx;
-- Индекс названия марок
CREATE INDEX brand_name_idx
ON dbo.brand (Name);

--Заполнение таблиц данными
INSERT INTO brand (Name, Country)
VALUES ('Toyota', 'Japan'),  ('Volkswagen', 'Germany'), ('BMW', 'Germany'), ('AUDI', 'Germany'), ('Mercedes', 'Germany'), ('Volvo', 'Sweden');

INSERT INTO stock (id_brand, Name, Count, Price)
VALUES (1, 'Camry',  4, 4000), (1, 'Corola',  3, 3500), (2, 'Passat',  4, 3500), (2, 'Polo',  2, 3000), (3, 'X5',  11, 6000), (3, 'X6',  1, 7500), 
(4, 'Q7',  7, 6000), (4, 'A6',  13, 5000), (5, '221',  5, 9000), (5, '222',  0, 10000), (6, 'XC90',  1, 2000), (6, 'XC60',  3, 3000);

INSERT INTO clients (Name, Number)
VALUES ('Samanta', '400-300'), ('Boar', '300-300'), ('Duck', '444-333'), ('Mike', '900-100');

INSERT INTO agents (Name, Date)
VALUES ('Jack', '11-02-2002'), ('Sam', '10-07-2012'), ('Nick', '01-01-2018');

INSERT INTO sales (id_client, id_agent, id_auto, Price, Date)
VALUES (1, 1, 1, 4000, '11-02-2002'), (2, 1, 3, 3500, '11-05-2002');
