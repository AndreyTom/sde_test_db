-- #0 создаем таблицу results

CREATE TABLE bookings.results (
    id int NOT NULL,
    response text
   );

-- #1
insert into results values(1,
(select max(a.count_num) from (select count(passenger_id) count_num from tickets group by book_ref) as a)
);

-- #2
insert into results values(2,
(select count(a.count_num) from (select count(passenger_id) count_num from tickets group by book_ref) as a
where a.count_num > (select avg(b.count) from (select count(passenger_id) from tickets group by book_ref) as b))
);

-- #3
insert into results values(3,
(select coalesce  (
(select count(book_ref) response
from (select t_sort.book_ref, string_agg(t_sort.passenger_id, ',') pass_id from (select book_ref, passenger_id from tickets order by passenger_id) t_sort
group by t_sort.book_ref
having count(passenger_id) = 5) id_sort
group by pass_id
having count(book_ref) = (select max(a.count_num) from (select count(passenger_id) count_num from tickets group by book_ref) as a)
order by count(book_ref) desc), 0)
));

-- #4
insert into results (id, response)
select id, response from
(select concat_ws('|', book_ref, passenger_id, passenger_name, contact_data) response, 4 id
from tickets
where book_ref in (
	select book_ref from (
		select distinct(book_ref), count(passenger_id) count_num
		from tickets
		group by book_ref
		having count(passenger_id) = 3
		order by count(passenger_id) ) a
)
order by book_ref, passenger_id, passenger_name, contact_data
) sub_04
;

-- #5
insert into results values(5,
(select count(tf.flight_id)
from ticket_flights tf
left join tickets t
on t.ticket_no = tf.ticket_no
group by t.book_ref
order by count(tf.flight_id) desc
limit 1))
;

-- #6
insert into results values(6,
(select count(tf.flight_id) response
from ticket_flights tf
left join tickets t
on t.ticket_no = tf.ticket_no
group by t.book_ref, t.passenger_id
--having count(tf.flight_id) > 6
order by count(tf.flight_id) desc
limit 1))
;

-- #7
insert into results values(7,
(select count(tf.flight_id) count_num
from ticket_flights tf
left join tickets t
on t.ticket_no = tf.ticket_no
group by t.passenger_id
--having count(tf.flight_id) > 6
order by count(tf.flight_id) desc
limit 1))
;

-- #8
insert into results (id, response)
select id, response from
(select concat_ws('|', t.passenger_id, t.passenger_name, t.contact_data, sum(tf.amount)) response, 8 id
from ticket_flights tf
left join tickets t
on t.ticket_no = tf.ticket_no
group by t.passenger_id, t.passenger_name, t.contact_data
having sum(tf.amount) = (select min(amount_id)
	from (
		select sum(tf.amount) amount_id
		from ticket_flights tf
		left join tickets t
		on t.ticket_no = tf.ticket_no
		group by t.passenger_id
		) a)
order by t.passenger_id, t.passenger_name, t.contact_data) sub_08
;

--#9
insert into results (id, response)
select id, response from
(select 9 id, concat_ws('|', t.passenger_id, t.passenger_name, t.contact_data, sum(f.actual_arrival - f.actual_departure)) response
from ticket_flights tf
left join tickets t on t.ticket_no = tf.ticket_no
left join flights f on tf.flight_id = f.flight_id
where f.status = 'Arrived'
group by t.passenger_id, t.passenger_name, t.contact_data
having sum(f.actual_arrival - f.actual_departure) = (select max(duration)
	from (
		select sum(f.actual_arrival - f.actual_departure) duration
		from ticket_flights tf
		left join tickets t on t.ticket_no = tf.ticket_no
		left join flights f on tf.flight_id = f.flight_id
		where f.status = 'Arrived'
		group by t.passenger_id, t.passenger_name, t.contact_data
		) a)
order by t.passenger_id, t.passenger_name, t.contact_data ) b
;

--#10
insert into results (id, response)
select id, response from
(select 10 id, city response
from airports a
group by city
having count(distinct(a.airport_code)) > 1
order by city) sub_1
;

--#11
insert into results (id, response)
select id, response from
(select 11 id, a1.city response
from flights f
left join airports a1 on f.departure_airport = a1.airport_code
left join airports a2 on f.arrival_airport = a2.airport_code
group by a1.city
having count(distinct(a1.city, a2.city)) = 1
order by a1.city) sub_11
;

--#12
insert into results (id, response)
-- все возможные варианты через cross join
select 12 id, * from
((select concat_ws('|',a1.city, a2.city) response
from (select distinct(city) from airports) a1
cross join
(select distinct(city) from airports) a2
where a1.city <> a2.city
	and a1.city < a2.city
order by concat_ws('|',a1.city, a2.city)
)

-- минус все имеющиейся варианты
except

(select distinct(concat_ws('|',a1.city, a2.city)) response
from flights f
left join airports a1 on f.departure_airport = a1.airport_code
left join airports a2 on f.arrival_airport = a2.airport_code
where a1.city < a2.city
order by concat_ws('|',a1.city, a2.city)
)
) sub_12
group by response;
;

--#13
insert into results (id, response)
select id, response from
(select distinct(city) response, 13 id from airports
where not city in (
	-- подзапрос выбирает города, куда рейсы из Москвы есть
	select distinct(a2.city) response
	from flights f
	left join airports a1 on f.departure_airport = a1.airport_code
	left join airports a2 on f.arrival_airport = a2.airport_code
	where a1.city = 'Москва')
order by city
) sub_13
;

--#14
insert into results (id, response)
select id, response from
(select a.model as response, 14 id
from flights f
left join aircrafts a on f.aircraft_code = a.aircraft_code
where f.status = 'Arrived'
group by a.model
order by count(f.aircraft_code) desc
limit 1) sub_14
;

--#15
insert into results (id, response)
select id, response from
(select a.model response, 15 id, count(tf.ticket_no)
from flights f
left join aircrafts a on f.aircraft_code = a.aircraft_code
left join ticket_flights tf on f.flight_id = tf.flight_id
where f.status = 'Arrived'
group by a.model
order by count(tf.ticket_no) desc
limit 1
) sub_15

--#16
insert into results (id, response)
select id, response from
(select extract (hour from sum(f.scheduled_arrival - f.scheduled_departure) - sum(f.actual_arrival - f.actual_departure)) * 60 +
	extract (minute from sum(f.scheduled_arrival - f.scheduled_departure) - sum(f.actual_arrival - f.actual_departure)) +
	extract (second from sum(f.scheduled_arrival - f.scheduled_departure) - sum(f.actual_arrival - f.actual_departure)) / 60 response,
	16 id
from flights f
where f.status = 'Arrived') sub_16
;

--#17
insert into results values(17,
(select coalesce (
(select distinct(a2.city) response from flights f
left join airports a2 on f.arrival_airport = a2.airport_code
where scheduled_departure between '2016-09-13' and '2016-09-14'
and departure_airport in (select airport_code from airports a where a.city = 'Санкт-Петербург')
and status = 'Arrived'), 'нет данных')))
;

--#18
insert into results (id, response)
select id, response from
(select concat_ws('|', f.flight_id, f.flight_no, f.departure_airport, f.arrival_airport, f.scheduled_departure) response, 18 id
from flights f
where f.flight_id in (
	select tf.flight_id
	from ticket_flights tf
	group by tf.flight_id
	order by sum(amount) desc
	limit 1)) sub_18
;

--#19
with date_num_flights as (
	select date(f.actual_departure) date_of_flights, count(f.actual_departure) num_of_flights
	from flights f
	where f.status = 'Arrived'
	group by date(f.actual_departure)
)
insert into results (id, response)
select id, response from (
(select date_of_flights response, 19 id from date_num_flights
where num_of_flights = (select min(num_of_flights) from date_num_flights)
)) sub_19
;

--#20
insert into results values(20,
(select coalesce (
(select avg(num_of_flights) response from
(select count(f.actual_departure) num_of_flights
from flights f
left join airports a on f.departure_airport = a.airport_code
where f.status = 'Arrived' 	and a.city = 'Москва'
	and f.actual_departure between '2016-09-01' and '2016-10-01'
	-- есть данные на этом периоде:
	--and f.actual_departure between '2017-07-01' and '2017-08-01'
group by date(f.actual_departure)
) sub_20), 0)))
;

--#21
insert into results (id, response)
select id, response from (
select a.city response, 21 id
from flights f
left join airports a on f.departure_airport  = a.airport_code
where f.status = 'Arrived'
group by a.city
having avg(f.actual_arrival - f.actual_departure) > '03:00'
order by avg(f.actual_arrival - f.actual_departure) desc
limit 5) sub_21
;

select * from results
where id = 21
limit 20

--truncate results;
