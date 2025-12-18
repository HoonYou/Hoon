with x as (
    -- 2018년 10월 (대여 + 반납)
    select rent_station_id as station_id, rent_at as event_time from rental_history
    where rent_at >= '2018-10-01' and rent_at < '2018-11-01'
    union all
    select return_station_id, return_at from rental_history
    where return_at >= '2018-10-01' and return_at < '2018-11-01'
    
    union all

    -- 2019년 10월 (대여 + 반납)
    select rent_station_id, rent_at from rental_history
    where rent_at >= '2019-10-01' and rent_at < '2019-11-01'
    union all
    select return_station_id, return_at from rental_history
    where return_at >= '2019-10-01' and return_at < '2019-11-01'
),
y as (
  select 
    station_id, 
    sum(case when event_time >= '2018-10-01' and event_time < '2018-11-01' then 1 else 0 end) as oct_2018, 
    sum(case when event_time >= '2019-10-01' and event_time < '2019-11-01' then 1 else 0 end) as oct_2019
  from x 
  group by station_id
)
select 
    s.station_id, 
    s.name, 
    s.local, 
    -- 2018년 대비 2019년 비율 (2019 / 2018)
    round((y.oct_2019 * 100.0 / y.oct_2018), 2) as usage_pct 
from y 
join station s on y.station_id = s.station_id
-- 2018년 대비 2019년 비율이 50% 이하인 곳
where (y.oct_2019 * 100.0 / y.oct_2018) <= 50 
  and y.oct_2018 > 0 
  and y.oct_2019 > 0;