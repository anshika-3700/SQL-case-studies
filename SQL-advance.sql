use advance
--CASE-STUDY-ADVANCE
--1.List all the states in which we have customers who have bought cellphones from 2005 till today.
select distinct [State],[Country] from [dbo].[DIM_LOCATION] l 
inner join [dbo].[FACT_TRANSACTIONS] t on l.[IDLocation]=t.[IDLocation]
where year([Date])>'2005'

--2.	What state in the US is buying more 'Samsung' cell phones?
select top 1[State], COUNT([State])num from [dbo].[DIM_MANUFACTURER] m 
inner join [dbo].[DIM_MODEL] d on m.[IDManufacturer]=d.[IDManufacturer] 
inner join [dbo].[FACT_TRANSACTIONS] t on t.[IDModel]=d.[IDModel]
inner join [dbo].[DIM_LOCATION]l on l.[IDLocation]=t.[IDLocation]
where m.[Manufacturer_Name]='Samsung' and l.[Country]='US'
GROUP BY [State] ORDER BY 2 DESC

--3.	Show the number of transactions for each model per zip code per state.
select [IDModel],[ZipCode],[State], count([IDModel])as no_transctn from [dbo].[FACT_TRANSACTIONS] t 
inner join [dbo].[DIM_LOCATION] l on t.IDLocation=l.IDLocation 
group by [IDModel],[ZipCode],[State]

--4.Show the cheapest cellphone
select [Model_Name] , [IDManufacturer], [Unit_price] from [dbo].[DIM_MODEL] 
where [Unit_price]=(select min([Unit_price]) from [dbo].[DIM_MODEL])

---5.Find out the average price for each model in the top5 manufacturers in terms of 
--sales quantity and order by average price.
select tt.[IDModel],avg([TotalPrice]) as avg_price from  [dbo].[FACT_TRANSACTIONS]tt 
inner join [dbo].[DIM_MODEL]mm on mm.IDModel=tt.IDModel inner join
(select top 5 m.[IDManufacturer] ,sum([Quantity])as qty from [dbo].[FACT_TRANSACTIONS] t 
inner join [dbo].[DIM_MODEL] m on m.IDModel =t.IDModel 
inner join [dbo].[DIM_MANUFACTURER]p on p.IDManufacturer=m.IDManufacturer 
group by m.[IDManufacturer] order by qty desc)c on c.IDManufacturer=mm.IDManufacturer
group by tt.[IDModel] order by 2 desc

--6.List the names of the customers and the average amount spent in 2009, where the average is higher than 500
select [IDCustomer],count([IDCustomer]) as num, avg([TotalPrice]) as amt from [dbo].[FACT_TRANSACTIONS] 
where year([Date])=2009 
group by [IDCustomer] having avg([TotalPrice])>500

---7.List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010
select [IDModel] from (select top 5[IDModel]  from [dbo].[FACT_TRANSACTIONS] where year([Date])='2008'
group by [IDModel] order by sum([Quantity]) desc) a
intersect select [IDModel] from 
(select top 5[IDModel]  from [dbo].[FACT_TRANSACTIONS] where year([Date])='2009'
group by [IDModel] order by sum([Quantity]) desc) b
intersect select [IDModel] from 
(select top 5[IDModel] from [dbo].[FACT_TRANSACTIONS] where year([Date])='2010'
group by [IDModel] order by sum([Quantity])  desc) c

---8.Show the manufacturer with the 2nd top sales in the year of 2009 and 
--the manufacturer with the 2nd top sales in the year of 2010.
select * from (select row_number() over (order by sum([TotalPrice]) desc ) ranks, f.[Manufacturer_Name] ,
sum([TotalPrice])as sales_2009 from [dbo].[FACT_TRANSACTIONS]t 
inner join [dbo].[DIM_MODEL]m on m.IDModel=t.IDModel 
inner join [dbo].[DIM_MANUFACTURER]f on f.IDManufacturer=m.IDManufacturer where year([Date])=2009
group by [Manufacturer_Name]) y where ranks =2

select * from (select rank() over (order by sum([TotalPrice]) desc ) ranks, f.[Manufacturer_Name] ,
sum([TotalPrice])as sales_2010 from [dbo].[FACT_TRANSACTIONS]t 
inner join [dbo].[DIM_MODEL]m on m.IDModel=t.IDModel 
inner join [dbo].[DIM_MANUFACTURER]f on f.IDManufacturer=m.IDManufacturer where year([Date])=2010
group by [Manufacturer_Name])z where ranks=2

---9.Show the manufacturers that sold cellphone in 2010 but didn’t in 2009.
select [Manufacturer_Name] from (select distinct[Manufacturer_Name] from [dbo].[DIM_MANUFACTURER]f 
inner join [dbo].[DIM_MODEL]m on m.IDManufacturer=f.IDManufacturer 
inner join [dbo].[FACT_TRANSACTIONS]t on t.IDModel=m.IDModel where year([Date])= 2010)y
 except 
select distinct[Manufacturer_Name] from [dbo].[DIM_MANUFACTURER]f 
inner join [dbo].[DIM_MODEL]m on m.IDManufacturer=f.IDManufacturer 
inner join [dbo].[FACT_TRANSACTIONS]t on t.IDModel=m.IDModel where year([Date])= 2009

---10.Find top 100 customers and their average spend, average quantity by each year. 
--Also find the percentage of change in their spend.

select * ,(((spend_2004-spend_2003)/spend_2003)*100) as spend_change_1, (((spend_2005-spend_2004)/spend_2004)*100) as spend_change_2
from (select [IDCustomer],
avg (case when year(date)=2003 then [TotalPrice] end )as spend_2003 ,
avg (case when year(date)=2004 then [TotalPrice] end) as spend_2004 ,
avg (case when year(date)=2005 then [TotalPrice] end) as spend_2005 ,
avg (case when year(date)=2003 then [Quantity] end) as qty_2003,
avg (case when year(date)=2004 then [Quantity] end) as qty_2004,
avg (case when year(date)=2005 then [Quantity] end) as qty_2005
from FACT_TRANSACTIONS
group by [IDCustomer])q 
