-- ============================================================
-- AutoServe: Vehicle Service Center Management System
-- File 1 of 2: database, table definitions and sample data
-- Run this file first (it drops and recreates the AutoServe database).
-- Tested on MariaDB 10.11 (MySQL-compatible); needs MySQL 8.0.16+ for CHECK.
-- ============================================================

DROP DATABASE IF EXISTS AutoServe;
CREATE DATABASE AutoServe;
USE AutoServe;

-- 2. Customers Table
CREATE TABLE Customers (
  Customer_ID INT PRIMARY KEY,
  Name VARCHAR(100) NOT NULL,
  Phone VARCHAR(15) NOT NULL,
  Email VARCHAR(100),
  City VARCHAR(50)
);

INSERT INTO Customers VALUES
(1, 'Arjun Bose', '9830100001', 'arjun.bose@gmail.com', 'Kolkata'),
(2, 'Neha Kapoor', '9830100002', 'neha.kapoor@yahoo.com', 'Delhi'),
(3, 'Imran Sheikh', '9830100003', 'imran.sheikh@gmail.com', 'Mumbai'),
(4, 'Priyanka Dey', '9830100004', 'priyanka.dey@outlook.com', 'Kolkata'),
(5, 'Rahul Menon', '9830100005', 'rahul.menon@gmail.com', 'Bengaluru'),
(6, 'Sunita Rao', '9830100006', 'sunita.rao@yahoo.com', 'Hyderabad'),
(7, 'Vivek Mehra', '9830100007', 'vivek.mehra@gmail.com', 'Pune'),
(8, 'Tanmay Ghosh', '9830100008', 'tanmay.ghosh@hotmail.com', 'Kolkata'),
(9, 'Farhan Ali', '9830100009', 'farhan.ali@gmail.com', 'Lucknow'),
(10, 'Deepa Iyer', '9830100010', 'deepa.iyer@outlook.com', 'Chennai');

-- 3. Vehicles Table
CREATE TABLE Vehicles (
  Vehicle_ID INT PRIMARY KEY,
  Customer_ID INT NOT NULL,
  Reg_Number VARCHAR(15) NOT NULL UNIQUE,
  Make VARCHAR(50) NOT NULL,
  Model VARCHAR(50) NOT NULL,
  Mfg_Year INT,
  FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID)
);

INSERT INTO Vehicles VALUES
(101, 1, 'WB02AB1234', 'Maruti', 'Swift', 2019),
(102, 1, 'WB06CD5678', 'Honda', 'Activa', 2021),
(103, 2, 'DL03EF4321', 'Hyundai', 'Creta', 2020),
(104, 3, 'MH12GH8765', 'Toyota', 'Innova', 2018),
(105, 4, 'WB24JK1122', 'Tata', 'Nexon', 2022),
(106, 4, 'WB74LM3344', 'Royal Enfield', 'Classic 350', 2020),
(107, 5, 'KA01NP5566', 'Honda', 'City', 2017),
(108, 6, 'TS09QR7788', 'Maruti', 'Baleno', 2021),
(109, 7, 'MH14ST9900', 'Hyundai', 'i20', 2019),
(110, 8, 'WB08UV2468', 'Mahindra', 'Scorpio', 2016),
(111, 9, 'UP32WX1357', 'Tata', 'Harrier', 2023),
(112, 3, 'MH01YZ9753', 'Bajaj', 'Pulsar 150', 2022);

-- 4. Mechanics Table
CREATE TABLE Mechanics (
  Mechanic_ID INT PRIMARY KEY,
  Name VARCHAR(100) NOT NULL,
  Specialization VARCHAR(50),
  Experience_Years INT
);

INSERT INTO Mechanics VALUES
(501, 'Ramesh Yadav', 'Engine', 14),
(502, 'Sourav Das', 'Brakes & Suspension', 9),
(503, 'Imtiaz Khan', 'Electrical', 11),
(504, 'Anita Sharma', 'AC & Cooling', 7),
(505, 'Prakash Nair', 'General Service', 5),
(506, 'Deepak Verma', 'Body & Paint', 12);

-- 5. Services Table
CREATE TABLE Services (
  Service_ID INT PRIMARY KEY,
  Service_Name VARCHAR(100) NOT NULL,
  Category VARCHAR(50) NOT NULL,
  Labor_Charge DECIMAL(10, 2) NOT NULL
);

INSERT INTO Services VALUES
(1, 'General Service', 'Maintenance', 1200.00),
(2, 'Oil Change', 'Maintenance', 500.00),
(3, 'Brake Pad Replacement', 'Brakes', 900.00),
(4, 'Wheel Alignment', 'Tyres', 600.00),
(5, 'Battery Replacement', 'Electrical', 400.00),
(6, 'AC Gas Refill', 'AC & Cooling', 1500.00),
(7, 'Clutch Repair', 'Engine', 2500.00),
(8, 'Engine Tuning', 'Engine', 3000.00),
(9, 'Denting & Painting', 'Body', 4000.00),
(10, 'Tyre Rotation', 'Tyres', 350.00);

-- 6. Parts Table
CREATE TABLE Parts (
  Part_ID INT PRIMARY KEY,
  Part_Name VARCHAR(100) NOT NULL,
  Unit_Price DECIMAL(10, 2) NOT NULL,
  Stock_Qty INT NOT NULL CHECK (Stock_Qty >= 0),
  Reorder_Level INT NOT NULL
);

INSERT INTO Parts VALUES
(1, 'Engine Oil (1 L)', 450.00, 80, 20),
(2, 'Oil Filter', 250.00, 60, 15),
(3, 'Air Filter', 350.00, 40, 10),
(4, 'Brake Pad Set', 1800.00, 12, 5),
(5, 'Brake Fluid', 300.00, 25, 8),
(6, 'Car Battery', 5200.00, 6, 5),
(7, 'Spark Plug', 220.00, 50, 20),
(8, 'Clutch Plate', 3500.00, 4, 3),
(9, 'AC Gas Can', 1200.00, 3, 5),
(10, 'Wiper Blade', 400.00, 30, 10),
(11, 'Coolant (1 L)', 380.00, 2, 10),
(12, 'Tyre (Standard)', 4200.00, 8, 4);

-- 7. Job_Cards Table
CREATE TABLE Job_Cards (
  Job_ID INT PRIMARY KEY,
  Vehicle_ID INT NOT NULL,
  Mechanic_ID INT NOT NULL,
  Service_Date DATE NOT NULL,
  Status VARCHAR(20) NOT NULL
    CHECK (Status IN ('Booked', 'In Progress', 'Completed', 'Cancelled')),
  FOREIGN KEY (Vehicle_ID) REFERENCES Vehicles(Vehicle_ID),
  FOREIGN KEY (Mechanic_ID) REFERENCES Mechanics(Mechanic_ID)
);

INSERT INTO Job_Cards VALUES
(7001, 101, 505, '2024-01-08', 'Completed'),
(7002, 103, 501, '2024-01-12', 'Completed'),
(7003, 104, 502, '2024-01-15', 'Completed'),
(7004, 102, 505, '2024-01-20', 'Completed'),
(7005, 105, 503, '2024-01-20', 'Completed'),
(7006, 106, 505, '2024-02-02', 'Completed'),
(7007, 107, 504, '2024-02-06', 'Completed'),
(7008, 108, 502, '2024-02-10', 'Completed'),
(7009, 109, 501, '2024-02-14', 'Completed'),
(7010, 101, 505, '2024-02-20', 'Completed'),
(7011, 110, 501, '2024-03-01', 'Completed'),
(7012, 111, 502, '2024-03-05', 'In Progress'),
(7013, 112, 505, '2024-03-08', 'Booked'),
(7014, 104, 504, '2024-03-10', 'Cancelled'),
(7015, 105, 505, '2024-03-12', 'Completed');

-- 8. Job_Services Table
CREATE TABLE Job_Services (
  Job_ID INT,
  Service_ID INT,
  Charge DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (Job_ID, Service_ID),
  FOREIGN KEY (Job_ID) REFERENCES Job_Cards(Job_ID),
  FOREIGN KEY (Service_ID) REFERENCES Services(Service_ID)
);

INSERT INTO Job_Services VALUES
(7001, 1, 1000.00), (7001, 2, 500.00),
(7002, 8, 3000.00),
(7003, 3, 900.00),
(7004, 2, 500.00),
(7005, 5, 400.00),
(7006, 1, 1200.00),
(7007, 6, 1500.00),
(7008, 4, 600.00), (7008, 10, 350.00),
(7009, 7, 2500.00),
(7010, 2, 500.00),
(7011, 8, 3000.00), (7011, 2, 500.00),
(7012, 3, 900.00),
(7013, 1, 1200.00),
(7014, 6, 1500.00),
(7015, 4, 600.00), (7015, 10, 350.00);

-- 9. Job_Parts Table
CREATE TABLE Job_Parts (
  Job_ID INT,
  Part_ID INT,
  Quantity INT NOT NULL CHECK (Quantity > 0),
  Unit_Price DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (Job_ID, Part_ID),
  FOREIGN KEY (Job_ID) REFERENCES Job_Cards(Job_ID),
  FOREIGN KEY (Part_ID) REFERENCES Parts(Part_ID)
);

INSERT INTO Job_Parts VALUES
(7001, 1, 4, 420.00), (7001, 2, 1, 250.00), (7001, 3, 1, 350.00),
(7002, 7, 4, 220.00),
(7003, 4, 1, 1800.00), (7003, 5, 1, 300.00),
(7004, 1, 1, 420.00), (7004, 2, 1, 250.00),
(7005, 6, 1, 5200.00),
(7006, 1, 2, 450.00), (7006, 2, 1, 250.00),
(7007, 9, 1, 1200.00), (7007, 11, 2, 380.00),
(7009, 8, 1, 3500.00),
(7010, 1, 4, 450.00), (7010, 2, 1, 250.00),
(7011, 1, 5, 450.00), (7011, 2, 1, 250.00), (7011, 3, 1, 350.00), (7011, 7, 4, 220.00),
(7012, 4, 1, 1800.00);

-- 10. Billing Table
CREATE TABLE Billing (
  Bill_ID INT PRIMARY KEY,
  Job_ID INT NOT NULL UNIQUE,
  Amount DECIMAL(10, 2) NOT NULL,
  Payment_Method VARCHAR(50),
  Payment_Status VARCHAR(20) NOT NULL
    CHECK (Payment_Status IN ('Paid', 'Pending')),
  FOREIGN KEY (Job_ID) REFERENCES Job_Cards(Job_ID)
);

INSERT INTO Billing VALUES
(9001, 7001, 3780.00, 'Credit Card', 'Paid'),
(9002, 7002, 3880.00, 'UPI', 'Paid'),
(9003, 7003, 3000.00, 'Cash', 'Paid'),
(9004, 7004, 1170.00, 'UPI', 'Paid'),
(9005, 7005, 5600.00, 'Credit Card', 'Paid'),
(9006, 7006, 2350.00, 'Debit Card', 'Paid'),
(9007, 7007, 3460.00, NULL, 'Pending'),
(9008, 7008, 950.00, 'Cash', 'Paid'),
(9009, 7009, 6000.00, NULL, 'Pending'),
(9010, 7010, 2550.00, 'UPI', 'Paid'),
(9011, 7011, 7230.00, 'Credit Card', 'Paid'),
(9012, 7015, 950.00, NULL, 'Pending');
