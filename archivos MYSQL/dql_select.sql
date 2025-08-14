-- Consultas

-- Consultas

--    • Encuentra el empleado que ha generado la mayor cantidad de ventas en el último trimestre.

select e.EmployeeId, e.FirstName, e.LastName, SUM(i.Total) as ventas_3m
from Invoice i
join Employee e on i.CustomerId =  e.EmployeeId 
where i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY e.EmployeeId, e.FirstName, e.LastName 
order by ventas_3m desc
limit 1;


--    • Lista los cinco artistas con más canciones vendidas en el último año.

select t.Composer, t.Name, SUM(il.Quantity) as cantidad_vendida 
from InvoiceLine il 
join Track t on il.TrackId = t.TrackId 
join Invoice i on il.InvoiceId  = i.InvoiceId 
where i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY t.composer, t.name
order by cantidad_vendida desc
limit 5;


--    • Obtén el total de ventas y la cantidad de canciones vendidas por país.

select
	(select IFNULL(SUM(total),0) FROM Invoice i2) AS total_ventas, i.BillingCountry, i.Total as total_por_pais
from Invoice i
join InvoiceLine il on 


--    • Calcula el número total de clientes que realizaron compras por cada género en un mes específico.

select t.GenreId, i.InvoiceDate, SUM(il.Quantity) as total_clientes
from InvoiceLine il 
join Track t on il.TrackId = t.TrackId 
join Invoice i on il.InvoiceId = i.InvoiceId 
where MONTH(InvoiceDate) = 12
group by t.GenreId, i.InvoiceId
order by total_clientes desc;


--    • Encuentra a los clientes que han comprado todas las canciones de un mismo álbum.

select t.AlbumId, a.Title, SUM(il.Quantity) as total_clientes
from InvoiceLine il 
join Track t on il.TrackId = t.TrackId 
left join Album a  on t.AlbumId = a.AlbumId  
where a.Title  = "Killers"
group by t.AlbumId, a.Title 
order by total_clientes desc;

--    • Lista los tres países con mayores ventas durante el último semestre.

select i.InvoiceId, i.InvoiceDate, i.BillingCountry, SUM(i.Total) as total_ventas
from Invoice i 
where i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
group by i.InvoiceId, i.InvoiceDate, i.BillingCountry 
order by total_ventas desc;


--    • Muestra los cinco géneros menos vendidos en el último año.

select t.GenreId, g.Name, SUM(il.Quantity) as cantidad_vendida
from InvoiceLine il 
join Track t on il.TrackId = t.TrackId 
join Invoice i on il.InvoiceId = i.InvoiceId 
left join Genre g on t.GenreId = g.GenreId
where i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
group by t.GenreId, g.Name 
order by cantidad_vendida asc
limit 5;


--    • Encuentra los cinco empleados que realizaron más ventas de Rock.


select em.FirstName, g.Name, il.Quantity as cantidad_vendida
from InvoiceLine il 
join ( 
	select e.EmployeeID, e.FirstName, e.LastName
	from Invoice i 
	join Employee e on i.CustomerID = e.EmployeeID
) em 
Join Track t on il.TrackId = t.TrackID
Left Join Genre g on t.GenreID = g.GenreID
where g.Name = "Rock"
group by em.FirstName, g.Name, il.Quantity 
order by cantidad_vendida DESC 
limit 5;


--    • Calcula el precio promedio de venta por género.

select g.GenreId, g.Name as Genero, AVG(il.UnitPrice) as Precio_Promedio
from InvoiceLine il 
join Track t on il.TrackId = t.TrackId 
join Genre g on t.GenreId = g.GenreId
group by g.GenreId, g.Name
order by Precio_Promedio desc;

--    • Lista las cinco canciones más largas vendidas en el último año.

select t.Name as Cancion, t.Milliseconds / 1000 as Duracion_Segundos, SUM(il.Quantity) as Cantidad_Vendida
from InvoiceLine il
join Track t on il.TrackId = t.TrackId
join Invoice i on il.InvoiceId = i.InvoiceId
where i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
group by t.Name, t.Milliseconds
order by t.Milliseconds desc
limit 5;


--    • Muestra los clientes que compraron más canciones de Jazz.

select c.CustomerId, c.FirstName, c.LastName, SUM(il.Quantity) as cantidad_comprada
from InvoiceLine il
join Invoice i on il.InvoiceId = i.InvoiceId
join Customer c on i.CustomerId = c.CustomerId
join Track t on il.TrackId = t.TrackId
join Genre g on t.GenreId = g.GenreId
where g.Name = "Jazz"
group by c.CustomerId, c.FirstName, c.LastName
order by cantidad_comprada desc;

--    • Encuentra la cantidad total de minutos comprados por cada cliente en el último mes.

select c.CustomerId, c.FirstName, c.LastName, SUM(t.Milliseconds) / 60000 as Minutos_Comprados
from InvoiceLine il
join Invoice i on il.InvoiceId = i.InvoiceId
join Customer c on i.CustomerId = c.CustomerId
join Track t on il.TrackId = t.TrackId
where i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
group by c.CustomerId, c.FirstName, c.LastName
order by Minutos_Comprados desc;


--    • Muestra el número de ventas diarias de canciones en cada mes del último trimestre.

select 
    DATE(i.InvoiceDate) as Fecha, 
    MONTH(i.InvoiceDate) as Mes, 
    COUNT(il.InvoiceLineId) as Ventas_Diarias
from InvoiceLine il
join Invoice i on il.InvoiceId = i.InvoiceId
where i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
group by Fecha, Mes
order by Fecha;

--    • Calcula el total de ventas por cada vendedor en el último semestre.

select 
    e.EmployeeId, 
    e.FirstName, 
    e.LastName, 
    SUM(i.Total) as Total_Ventas
from Invoice i
join Customer c on i.CustomerId = c.CustomerId
join Employee e on c.SupportRepId = e.EmployeeId
where i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
group by e.EmployeeId, e.FirstName, e.LastName
order by Total_Ventas desc;

--    • Encuentra el cliente que ha realizado la compra más cara en el último año.
select 
    c.CustomerId, 
    c.FirstName, 
    c.LastName, 
    MAX(i.Total) as Compra_Mas_Cara
from Invoice i
join Customer c on i.CustomerId = c.CustomerId
where i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
group by c.CustomerId, c.FirstName, c.LastName
order by Compra_Mas_Cara desc
limit 1;

--    • Lista los cinco álbumes con más canciones vendidas durante los últimos tres meses.
select 
    a.AlbumId, 
    a.Title, 
    SUM(il.Quantity) as Canciones_Vendidas
from InvoiceLine il
join Track t on il.TrackId = t.TrackId
join Album a on t.AlbumId = a.AlbumId
join Invoice i on il.InvoiceId = i.InvoiceId
where i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
group by a.AlbumId, a.Title
order by Canciones_Vendidas desc
limit 5;

--    • Obtén la cantidad de canciones vendidas por cada género en el último mes.
select 
    g.GenreId, 
    g.Name as Genero, 
    SUM(il.Quantity) as Canciones_Vendidas
from InvoiceLine il
join Track t on il.TrackId = t.TrackId
join Genre g on t.GenreId = g.GenreId
join Invoice i on il.InvoiceId = i.InvoiceId
where i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
group by g.GenreId, g.Name
order by Canciones_Vendidas desc;

-- Lista los clientes que no han comprado nada en el último año.
select 
    c.CustomerId, 
    c.FirstName, 
    c.LastName
from Customer c
left join Invoice i on c.CustomerId = i.CustomerId 
    and i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
where i.InvoiceId IS NULL;