USE sales_data;
SELECT * FROM geo;
SELECT * FROM people;
SELECT * FROM sales;
SELECT * FROM products;

-- (1) How many customers from India bought the product 'Milk Bars'?
SELECT Sum(Customers) AS 'Total customers from India' FROM sales
WHERE PID = 'P01' and GeoID = 'G1';


 
-- (2) In 2022, which countries ranked among the top five in terms of THE sales of different product?

SELECT s.GeoID,g.Geo,count(s.PID) AS Product_count FROM sales AS s
INNER JOIN geo AS g ON  s.GeoID = g.GeoID
WHERE SaleDate LIKE '2022%'
GROUP BY GeoID
ORDER BY Product_count DESC LIMIT 5;


-- (3) How many customers and sales persons are there for the Team 'Yummies'?
SELECT  p.Team, count(DISTINCT(p.SPID)) AS Total_sales_persons , sum(s.Customers) AS Total_customers FROM people AS p
LEFT JOIN sales AS s ON p.SPID = s.SPID
WHERE p.Team = 'Yummies';

-- (4) Which are the top three countries with the highest number of customers?
SELECT s.GeoID, g.Geo, SUM(Customers) AS Total_customers  FROM sales AS s
LEFT JOIN geo AS g ON s.GeoID = g.GeoID
GROUP BY GeoID ORDER BY Total_customers DESC LIMIT 3;

-- (5) Which are the top 5 days with the highest sales based on the amount?
SELECT COUNT(DISTINCT SaleDate) FROM sales;
SELECT  SaleDate, Amount FROM sales
ORDER BY Amount DESC LIMIT 5;

-- (6) Find the salespersons' sales based on the highest number of 'Almond Choco' box sales.
SELECT pr.PID , s.SPID ,p.Salesperson, s.Boxes FROM products AS pr
LEFT JOIN sales as s ON pr.PID = s.PID 
LEFT JOIN people AS p ON s.SPID = p.SPID
WHERE pr.Product = 'Almond Choco' ORDER BY Boxes DESC;

 
 -- (7) What product achieved the highest sales volume in terms of the number of boxes sold by Indian salespersons?
 SELECT SUM(Boxes) AS TotalBoxes
FROM sales
WHERE GeoID IN (SELECT GeoID FROM geo WHERE Geo = 'India');

 -- (8) What are the top-performing countries in terms of box sales, and how do their sales figures compare to one another?"
 SELECT * FROM geo;
 SELECT * FROM sales;
 SELECT g.Geo AS Country, SUM(s.Boxes) AS TotalBoxesSold FROM sales AS s
LEFT JOIN geo AS g ON s.GeoID = g.GeoID
GROUP BY g.Geo
ORDER BY TotalBoxesSold DESC;

  -- (9) Which region (APAC, Americas, or Europe) has the highest number of customers?
SELECT * FROM geo; 
SELECT * FROM sales;
 SELECT  g.Region, SUM(s.Customers) AS Total_customers FROM sales AS s
LEFT JOIN geo AS g ON s.GeoID = g.GeoID
GROUP BY Region ORDER BY Total_customers DESC;

-- (10)  Find the total sales amount for each product category.?
SELECT p.Product, SUM(s.Amount) AS Total_Sales_Amount FROM sales AS s
LEFT JOIN products AS p ON s.PID = p.PID
GROUP BY Product;

 -- (11) Calculate the average cost per box for products in each size category.
SELECT Size, AVG(Cost_per_box) AS Average_Cost_per_Box
FROM products
GROUP BY Size;
-- (12) List the salespeople who made sales in both Hyderabad and Wellington?
SELECT * FROM people;
SELECT Salesperson FROM people
WHERE Location = 'Hyderabad' AND Location = 'Wellington';

-- (13) Find the total number of customers in each product category for products costing more than $5 per box?
SELECT * FROM geo;
SELECT * FROM people;
SELECT * FROM sales;
SELECT * FROM Products;
SELECT p.Product, SUM(s.Customers) AS Total_customers FROM sales AS s
LEFT JOIN Products AS p on p.PID = s.PID
WHERE P.Cost_per_box > 5
GROUP BY p.PID;

--  (14)  Calculate the total sales amount for each salesperson in each region?

SELECT sp.Salesperson, g.Region, SUM(s.Amount) AS Total_Sales_Amount
FROM People AS sp
LEFT JOIN sales AS s ON sp.SPID = s.SPID
LEFT JOIN geo AS g ON s.GeoID = g.GeoID
GROUP BY sp.Salesperson, g.Region ORDER BY Salesperson;

--  (15) Calculate the total sales amount for each product in each region in January 2021?

SELECT p.Product, g.Region, SUM(s.Amount) AS Total_Sales_Amount
FROM sales AS s
LEFT JOIN products AS p ON s.PID = p.PID
LEFT JOIN geo AS g ON s.GeoID = g.GeoID
WHERE EXTRACT(YEAR FROM s.SaleDate) = 2021 AND EXTRACT(MONTH FROM s.SaleDate) = 1
GROUP BY p.Product, g.Region ORDER BY p.Product;


/*(16) Find the year wise total amount of sales for each product in each region  and their difference for the year 2021 & 2022 separately. Using this
identify the products that experienced the greatest decrease in sales based on the region of sale?*/
select * from sales;
WITH SalesCounts AS (
    SELECT
        g.Region,
        p.Product,
       SUM(CASE WHEN EXTRACT(YEAR FROM s.SaleDate) = 2021 THEN s.Amount ELSE NULL END) AS 2021_Sales_Count,
        SUM(CASE WHEN EXTRACT(YEAR FROM s.SaleDate) = 2022 THEN s.Amount ELSE NULL END)  AS 2022_Sales_Count
    FROM sales AS s
    LEFT JOIN products AS p ON s.PID = p.PID
    LEFT JOIN geo AS g ON s.GeoID = g.GeoID
    GROUP BY g.Region, p.Product
)

SELECT
    Region,
    Product,
    2021_Sales_Count,
    2022_Sales_Count,
    (2021_Sales_Count - 2022_Sales_Count) AS Sales_Difference
FROM SalesCounts
ORDER BY Region, Sales_Difference DESC;

    
-- (17)Find the total number of boxes of sale of the product 'White Choc' at the region  Americas in the year 2021 ?
SELECT sum(boxes) AS Total_sale_of_boxes from sales
where SaleDate LIKE '%2021%'
 AND PID = (SELECT PID FROM products WHERE  Product = 'White Choc')
 AND GeoID IN (SELECT GeoID FROM geo WHERE Region = 'Americas' );  
   /*using this result we can verify the next question(using 1st 2 tables)*/
   
   

/* (18) Find the yearwise total sales for each product in each region  and their difference for the year 2021 & 2022 separately.
To calculate yearwise total sales, multiply the total sale count for each product in each region by the number of boxes sold. Using this
identify the products that experienced the greatest decrease in sales based on the region of sale?*/

 WITH Total_sale AS (WITH SalesCounts AS (
    SELECT
        g.Region,
        p.Product,
        SUM( CASE WHEN EXTRACT(YEAR FROM s.SaleDate) = 2021 THEN s.boxes ELSE NULL END) AS 2021_boxes_Count,
        SUM( CASE WHEN EXTRACT(YEAR FROM s.SaleDate) = 2022 THEN s.boxes ELSE NULL END) AS 2022_boxes_Count,
        COUNT(CASE WHEN EXTRACT(YEAR FROM s.SaleDate) = 2021 THEN 1 ELSE NULL END) AS 2021_Sales_Count,
        COUNT(CASE WHEN EXTRACT(YEAR FROM s.SaleDate) = 2022 THEN 1 ELSE NULL END)  AS 2022_Sales_Count
    FROM sales AS s
    LEFT JOIN products AS p ON s.PID = p.PID
    LEFT JOIN geo AS g ON s.GeoID = g.GeoID
    GROUP BY g.Region, p.Product
)

SELECT
    Region,
    Product,
    2021_Sales_Count*2021_boxes_Count AS 2021_Sales,
    2022_Sales_Count*2022_boxes_Count AS 2022_Sales
FROM SalesCounts
)
SELECT  
	Region,
    Product,
	2021_Sales,
    2022_Sales,
    (2021_Sales - 2022_Sales) AS Sales_Difference
    FROM Total_sale
ORDER BY Region, Sales_Difference DESC;


