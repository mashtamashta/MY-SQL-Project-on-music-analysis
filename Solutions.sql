use music_data

-- Who is the seniormost employee?
select * from employee
order by levels DESC

-- Which country has most number of invoices?
select count(*) as bill_count, billing_country from invoice
group by billing_country
order by bill_count desc


-- What are top 3 values of total invoices?
select * from invoice
order by total desc
limit 3

-- Which city has the best costumers for festival organisation? ( Highest sum of invice total by city)
select sum(total) as total_city_amount, billing_city from invoice
group by billing_city 
order by total_city_amount desc

-- Who is the best costumer? ( Most amount spent by a user)
select customer.customer_id, customer.first_name, customer.last_name as total from customer
join invoice on customer.customer_id = invoice.customer_id
group by  customer.customer_id
order by total desc

-- Return Name and email of all rock listeners sort by name
select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id IN (
	select track_id from track 
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock' )
order by first_name;


-- Reutrn the name of artists with most rock music returned by top 10 bands!

select artist.artist_id , artist.name , count(artist.artist_id) as number_of_songs
from track
join albums  on albums.album_id = track.album_id
join artist on artist.artist_id = albums.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;


-- Reutrn song names with track length longer than average track length, Reutrn name and milliseconds for each order by longest

select track.name, track.milliseconds as Duration from track
where track.milliseconds > (
	select avg(track.milliseconds) from track
     )
order by milliseconds desc


-- Amount spent by each customer on each artists, customer name , artist name and amount spent!

WITH 
best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
    SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN albums ON albums.album_id = track.album_id
	JOIN artist ON artist.artist_id = albums.artist_id
	GROUP BY artist.artist_id
	ORDER BY total_sales DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN albums alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


-- We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


-- Write a query that determines the customer that has spent the most on music for each country.cWrite a query that returns the country along with the top customer and how much they spent!

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1


