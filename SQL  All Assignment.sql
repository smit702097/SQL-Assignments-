use classicmodels;

-- Q.1  A ------------------

SELECT DISTINCT employeenumber, firstname, lastname
FROM employees
WHERE jobtitle LIKE '%Sales Rep%'
AND reportsto = 1102;



-- Q2.B ----------------------------------------------------------------------------------------

SELECT DISTINCT productline
FROM products
WHERE productline LIKE '%cars';

-- --------------------------------------------------------------------------------------------------------------------

-- Q2. A ------------------------


SELECT customerNumber, customerName,
       CASE
           WHEN country IN ('USA', 'Canada') THEN 'North America'
           WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
           ELSE 'Other'
       END AS CustomerSegment
FROM customers;

-- -------------------------------------------------------------------------------------------------------------------


-- Q3.A---------------------------------

SELECT productCode, SUM(quantityOrdered) AS totalQuantityOrdered
FROM OrderDetails
GROUP BY productCode
ORDER BY totalQuantityOrdered DESC
LIMIT 10;

-- -----------------------------------------------------

-- Q3.2 ----------------------

SELECT DATE_FORMAT(paymentDate, '%M') AS monthName, COUNT(*) AS totalPayments
FROM Payments
GROUP BY monthName
HAVING totalPayments > 20
ORDER BY totalPayments DESC;

-- ---------------------------------------------------------------------------------------------------

-- Q4. A ------------------------

CREATE DATABASE Customers_Orders;

USE Customers_Orders;

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);

SELECT * FROM CUSTOMERS;

-- --------------------------------------------

-- Q4.B -----------------------

USE Customers_Orders;

CREATE TABLE Orders(
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CHECK (total_amount > 0)
);

SELECT * FROM orders;

 -- --------------------------------------------------------------------------------------------------
 
 -- Q5.A -------------------------
 
 SELECT * FROM CUSTOMERS;
 SELECT * FROM ORDERS;
 
 SELECT CUSTOMERS.country, COUNT(ORDERS.CUSTOMERNUMBER) AS order_count
FROM Customers 
JOIN Orders  ON CUSTOMERS.CUSTOMERNUMBER = ORDERS.CUSTOMERNUMBER
GROUP BY Customers.country
ORDER BY order_count DESC
LIMIT 5;

-- --------------------------------------------------------------------------------------------------------------

-- Q6.A --------------------------------- 
 drop table project ;
create table project(
             employeeID int auto_increment primary key,
             FullName varchar(50) not null,
             Gender enum('Male','Female'),
             ManagerID int);
             
insert into project(FullName,Gender,ManagerID) values('Pranaya','Male',3),
						  ('Priyanka','Female',1),
                          ('Preety','Female',null),
                          ('Anurag','Male',1),
                          ('Sambit','Male',1),
                          ('Rajesh','Male',3),
                          ('Hina','Female',3);
select*from project; 

select   mgr.fullName as Manager_Name,
         emp.fullName as Employee_Name
         from project as mgr inner join project as emp 
         on mgr.employeeID = emp.ManagerID 
         order by mgr.fullName ;

-- ----------------------------------------------------------------------------------------------------------------


-- Q.7A ------------------------------------------

CREATE TABLE facility (
    Facility_ID INT,
    Name VARCHAR(255),
    State VARCHAR(255),
    Country VARCHAR(255)
);

ALTER TABLE facility
MODIFY Facility_ID INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE facility
ADD COLUMN City VARCHAR(255) NOT NULL AFTER Name;

select * from facility;
desc facility;


-- Q.8 ----------------------------------------------


CREATE VIEW product_category_sales AS
SELECT 
    pl.productLine,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM 
    ProductLines pl
JOIN 
    Products p ON pl.productLine = p.productLine
JOIN 
    OrderDetails od ON p.productCode = od.productCode
JOIN 
    Orders o ON od.orderNumber = o.orderNumber
GROUP BY 
    pl.productLine;

SELECT * FROM product_category_sales;

-- --------------------------------------------------------------------------------------------------------------


-- Q.9 -----------------------------------------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE Get_country_payments(
    IN input_year INT,
    IN input_country VARCHAR(255)
)
BEGIN
    SELECT 
        YEAR(p.paymentDate) AS year,
        c.country,
        CONCAT(FORMAT(SUM(p.amount) / 1000, 0), 'K') AS total_amount
    FROM 
        Customers c
    JOIN 
        Payments p ON c.customerNumber = p.customerNumber
    WHERE 
        YEAR(p.paymentDate) = input_year
        AND c.country = input_country
    GROUP BY 
        YEAR(p.paymentDate), c.country;
END //

DELIMITER ;
CALL Get_country_payments(2003, 'USA');

-- -------------------------------------------------------------------------------------------------------------

-- Q10.A -------------------------------------- 
select * from orders;
select * from customers;

SELECT
    c.customerName,
    COUNT(o.customernumber) AS Order_count,
    RANK() OVER (ORDER BY COUNT(o.customernumber) DESC) AS order_frequency_rnk
FROM
    customers c
JOIN
    orders o ON c.customernumber = o.customernumber
GROUP BY
    c.customerName
ORDER BY
    order_frequency_rnk;

WITH OrderCounts AS (
    SELECT
        YEAR(orderdate) AS order_year,
        MONTHNAME(orderdate) AS order_month,
        COUNT(customernumber) AS order_count
    FROM
        orders
    GROUP BY
        YEAR(orderdate), MONTHNAME(orderdate)
),
YearlyOrderCounts AS (
    SELECT
        order_year,
        order_month,
        order_count,
        LAG(order_count) OVER (PARTITION BY order_month ORDER BY order_year) AS prev_year_order_count
    FROM
        OrderCounts
)
SELECT
    order_year,
    order_month,
    order_count,
    COALESCE(
        ROUND((order_count - prev_year_order_count) * 100.0 / NULLIF(prev_year_order_count, 0), 0),
        0
    ) AS YoY_Percentage_Change
FROM
    YearlyOrderCounts
ORDER BY
    order_year, order_month;

    
    -- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    -- Q.11 A --------------------------------
    
SELECT 
    productLine,
    COUNT(*) AS product_count
FROM 
    Products
WHERE 
    buyPrice > (SELECT AVG(buyPrice) FROM Products)
GROUP BY 
    productLine;
    
    -- -----------------------------------------------------------------------------------------------------------------------------------
    
-- Q.12 A ------------------------------------------ 

CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(255),
    EmailAddress VARCHAR(255)
);

DELIMITER //

CREATE PROCEDURE InsertEmp_EH(
    IN p_EmpID INT,
    IN p_EmpName VARCHAR(255),
    IN p_EmailAddress VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Error handling
        ROLLBACK;
        SELECT 'Error occurred' AS ErrorMessage;
    END;

    START TRANSACTION;

    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);

    COMMIT;
END //

DELIMITER ;

CALL InsertEmp_EH(1, 'SUMIT WANARE', 'sumitwanare007.com');

-- ---------------------------------------------------------------------------------------------------------------------------------

-- Q. 13 A ---------------------

CREATE TABLE Emp_BIT (
    Name VARCHAR(255),
    Occupation VARCHAR(255),
    Working_date DATE,
    Working_hours INT
);

INSERT INTO Emp_BIT (Name, Occupation, Working_date, Working_hours) VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);


DELIMITER //

CREATE TRIGGER before_insert_working_hours
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END //

DELIMITER ;

INSERT INTO Emp_BIT (Name, Occupation, Working_date, Working_hours) VALUES
('John', 'Designer', '2024-06-14', -8);


SELECT * FROM Emp_BIT;
