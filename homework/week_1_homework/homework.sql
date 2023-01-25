--Question 3. Count records
select count(*)
from green_taxi_data
where
lpep_pickup_datetime::date = '2019-01-15'
    and
lpep_dropoff_datetime::date = '2019-01-15';

-- Question 4. Largest trip for each day
select lpep_pickup_datetime::date as pick_up, round(sum(trip_distance::numeric), 2)as total_distance
from green_taxi_data
where lpep_pickup_datetime::date >= '2019-01-10' and lpep_pickup_datetime::date <= '2019-01-28'
group by pick_up
order by total_distance desc

-- Question 5. The number of passengers
select count(*) as no_of_passenger, passenger_count
from green_taxi_data
where 
lpep_pickup_datetime::date = '2019-01-01' and (passenger_count=2 or passenger_count=3)
group by passenger_count

-- Question 6. Largest tip
select puzones."Zone" as pickup, dozones."Zone" as dropoff , round(sum(tip_amount::numeric),2) as largest_tip
from public.green_taxi_data as gt
    inner join public.zones as puzones
    on gt."PULocationID" = puzones."LocationID"
    inner join public.zones as dozones
    on gt."DOLocationID" = dozones."LocationID"
where puzones."Zone" = 'Astoria'
group by  puzones."Zone",dozones."Zone"
order by largest_tip desc
