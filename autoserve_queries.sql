-- ============================================================
-- AutoServe: Vehicle Service Center Management System
-- File 2 of 2: questions and answers (queries, indexes, views, transactions)
-- Run autoserve_schema.sql first. Run this file top to bottom.
-- Q27 is expected to fail, so it is commented out: run it on its own to see the error.
-- Q28 changes data (job 7012 becomes Completed): re-run the schema file to reset.
-- ============================================================

USE AutoServe;

-- Q1. List all job cards scheduled after '2024-02-01'.
SELECT * FROM Job_Cards WHERE Service_Date > '2024-02-01';

-- Q2. Retrieve all payments made via 'UPI'.
SELECT * FROM Billing WHERE Payment_Method = 'UPI';

-- Q3. Display the 5 services with the highest labor charges.
SELECT * FROM Services ORDER BY Labor_Charge DESC LIMIT 5;

-- Q4. Show the 3 most recent job cards.
SELECT * FROM Job_Cards ORDER BY Service_Date DESC LIMIT 3;

-- Q5. Find all vehicles owned by 'Arjun Bose'.
SELECT v.Reg_Number, v.Make, v.Model
FROM Vehicles v
  JOIN Customers c ON v.Customer_ID = c.Customer_ID
WHERE c.Name = 'Arjun Bose';

-- Q6. List every service performed on the vehicle 'WB02AB1234'.
SELECT j.Job_ID, j.Service_Date, s.Service_Name, js.Charge
FROM Vehicles v
  JOIN Job_Cards j ON v.Vehicle_ID = j.Vehicle_ID
  JOIN Job_Services js ON j.Job_ID = js.Job_ID
  JOIN Services s ON js.Service_ID = s.Service_ID
WHERE v.Reg_Number = 'WB02AB1234'
ORDER BY j.Service_Date;

-- Q7. Display bills with an amount greater than the average billing amount.
SELECT * FROM Billing WHERE Amount > (SELECT AVG(Amount) FROM Billing);

-- Q8. Find the number of vehicles owned by each customer (including customers with none).
SELECT c.Name, COUNT(v.Vehicle_ID) AS Total_Vehicles
FROM Customers c
  LEFT JOIN Vehicles v ON c.Customer_ID = v.Customer_ID
GROUP BY c.Customer_ID, c.Name
ORDER BY c.Customer_ID;

-- Q9. Show the number of job cards for each status.
SELECT Status, COUNT(*) AS Total_Jobs
FROM Job_Cards
GROUP BY Status
ORDER BY Total_Jobs DESC, Status;

-- Q10. Find the average labor charge for each service category.
SELECT Category, ROUND(AVG(Labor_Charge), 2) AS Avg_Charge
FROM Services
GROUP BY Category
ORDER BY Category;

-- Q11. List parts that are below their reorder level.
SELECT Part_ID, Part_Name, Stock_Qty, Reorder_Level
FROM Parts
WHERE Stock_Qty < Reorder_Level;

-- Q12. Identify mechanics who have not been assigned any job card.
SELECT Name FROM Mechanics m
WHERE NOT EXISTS (SELECT 1 FROM Job_Cards j WHERE j.Mechanic_ID = m.Mechanic_ID);

-- Q13. Find the total revenue collected through each payment method.
SELECT Payment_Method, SUM(Amount) AS Total_Revenue
FROM Billing
WHERE Payment_Status = 'Paid'
GROUP BY Payment_Method
ORDER BY Total_Revenue DESC;

-- Q14. Display the total amount billed to each customer.
SELECT c.Name, SUM(b.Amount) AS Total_Billed
FROM Customers c
  JOIN Vehicles v ON c.Customer_ID = v.Customer_ID
  JOIN Job_Cards j ON v.Vehicle_ID = j.Vehicle_ID
  JOIN Billing b ON j.Job_ID = b.Job_ID
GROUP BY c.Customer_ID, c.Name
ORDER BY Total_Billed DESC;

-- Q15. Find customers who own more than one vehicle.
SELECT c.Name, COUNT(*) AS Total_Vehicles
FROM Customers c
  JOIN Vehicles v ON c.Customer_ID = v.Customer_ID
GROUP BY c.Customer_ID, c.Name
HAVING COUNT(*) > 1
ORDER BY c.Customer_ID;

-- Q16. Find vehicles that have been serviced more than once.
SELECT v.Reg_Number, v.Make, v.Model, COUNT(*) AS Completed_Visits
FROM Vehicles v
  JOIN Job_Cards j ON v.Vehicle_ID = j.Vehicle_ID
WHERE j.Status = 'Completed'
GROUP BY v.Vehicle_ID, v.Reg_Number, v.Make, v.Model
HAVING COUNT(*) > 1
ORDER BY v.Vehicle_ID;

-- Q17. Find the total billing revenue for each month.
SELECT YEAR(j.Service_Date) AS Service_Year,
       MONTH(j.Service_Date) AS Service_Month,
       SUM(b.Amount) AS Revenue
FROM Job_Cards j
  JOIN Billing b ON j.Job_ID = b.Job_ID
GROUP BY YEAR(j.Service_Date), MONTH(j.Service_Date)
ORDER BY Service_Year, Service_Month;

-- Q18. Retrieve the service category that generated the highest labor revenue.
SELECT s.Category, SUM(js.Charge) AS Labor_Revenue
FROM Services s
  JOIN Job_Services js ON s.Service_ID = js.Service_ID
  JOIN Job_Cards j ON js.Job_ID = j.Job_ID
WHERE j.Status = 'Completed'
GROUP BY s.Category
ORDER BY Labor_Revenue DESC
LIMIT 1;

-- Q19. Show the number of pending bills and the total amount still to be collected.
SELECT COUNT(*) AS Pending_Bills, SUM(Amount) AS Pending_Amount
FROM Billing
WHERE Payment_Status = 'Pending';

-- Q20. Rank the mechanics by the revenue of the jobs they handled.
SELECT m.Name,
       COUNT(b.Bill_ID) AS Jobs_Billed,
       COALESCE(SUM(b.Amount), 0) AS Revenue,
       RANK() OVER (ORDER BY COALESCE(SUM(b.Amount), 0) DESC) AS Revenue_Rank
FROM Mechanics m
  LEFT JOIN Job_Cards j ON m.Mechanic_ID = j.Mechanic_ID
  LEFT JOIN Billing b ON j.Job_ID = b.Job_ID
GROUP BY m.Mechanic_ID, m.Name
ORDER BY Revenue_Rank;

-- Q21. Calculate the cumulative billing revenue per service date.
SELECT Service_Date, Daily_Revenue,
       SUM(Daily_Revenue) OVER (ORDER BY Service_Date) AS Cumulative_Revenue
FROM (
  SELECT j.Service_Date, SUM(b.Amount) AS Daily_Revenue
  FROM Job_Cards j
    JOIN Billing b ON j.Job_ID = b.Job_ID
  GROUP BY j.Service_Date
) AS daily
ORDER BY Service_Date;

-- Q22. Create a view that shows the labor, parts and total cost of every job.
CREATE VIEW Job_Totals AS
SELECT j.Job_ID,
       COALESCE(s.Labor_Total, 0) AS Labor_Total,
       COALESCE(p.Parts_Total, 0) AS Parts_Total,
       COALESCE(s.Labor_Total, 0) + COALESCE(p.Parts_Total, 0) AS Job_Total
FROM Job_Cards j
  LEFT JOIN (SELECT Job_ID, SUM(Charge) AS Labor_Total
             FROM Job_Services GROUP BY Job_ID) s ON j.Job_ID = s.Job_ID
  LEFT JOIN (SELECT Job_ID, SUM(Quantity * Unit_Price) AS Parts_Total
             FROM Job_Parts GROUP BY Job_ID) p ON j.Job_ID = p.Job_ID;
SELECT * FROM Job_Totals ORDER BY Job_ID;

-- Q23. Verify that every bill matches the job total (should return no rows).
SELECT b.Bill_ID, b.Amount, t.Job_Total
FROM Billing b
  JOIN Job_Totals t ON b.Job_ID = t.Job_ID
WHERE b.Amount <> t.Job_Total;

-- Q24. Create an index to search job cards by service date.
CREATE INDEX idx_service_date ON Job_Cards(Service_Date);
SELECT INDEX_NAME, COLUMN_NAME, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'AutoServe' AND TABLE_NAME = 'Job_Cards'
ORDER BY INDEX_NAME;

-- Q25. Create a unique index for customer emails.
CREATE UNIQUE INDEX idx_email ON Customers(Email);
SELECT INDEX_NAME, COLUMN_NAME, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'AutoServe' AND TABLE_NAME = 'Customers'
ORDER BY INDEX_NAME;

-- Q26. Create a view for pending payments with customer and vehicle details.
CREATE VIEW Pending_Payments AS
SELECT b.Bill_ID, c.Name AS Customer, c.Phone, v.Reg_Number, b.Amount
FROM Billing b
  JOIN Job_Cards j ON b.Job_ID = j.Job_ID
  JOIN Vehicles v ON j.Vehicle_ID = v.Vehicle_ID
  JOIN Customers c ON v.Customer_ID = c.Customer_ID
WHERE b.Payment_Status = 'Pending';
SELECT * FROM Pending_Payments ORDER BY Amount DESC;

-- Q27. Show that one job card cannot be given two bills (1:1 rule).
-- (expected to fail: duplicate value in the UNIQUE column Job_ID)
-- INSERT INTO Billing VALUES (9099, 7001, 500.00, 'Cash', 'Paid');

-- Q28. Complete job 7012 using a transaction (status, stock and bill change together).
START TRANSACTION;
UPDATE Job_Cards SET Status = 'Completed' WHERE Job_ID = 7012;
UPDATE Parts SET Stock_Qty = Stock_Qty - 1 WHERE Part_ID = 4;
INSERT INTO Billing
SELECT 9013, Job_ID, Job_Total, 'Debit Card', 'Paid'
FROM Job_Totals WHERE Job_ID = 7012;
COMMIT;
SELECT j.Job_ID, j.Status, b.Amount, b.Payment_Status,
       (SELECT Stock_Qty FROM Parts WHERE Part_ID = 4) AS Brake_Pad_Stock
FROM Job_Cards j
  JOIN Billing b ON j.Job_ID = b.Job_ID
WHERE j.Job_ID = 7012;

-- Q29. Undo a change with ROLLBACK.
START TRANSACTION;
UPDATE Job_Cards SET Status = 'Cancelled' WHERE Job_ID = 7013;
SELECT Job_ID, Status FROM Job_Cards WHERE Job_ID = 7013;
ROLLBACK;
SELECT Job_ID, Status FROM Job_Cards WHERE Job_ID = 7013;
