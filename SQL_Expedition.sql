alter table courier 
add primary key(id);

alter table province 
add primary key(province_code);

alter table courier 
add foreign key(province_code) references province(province_code);

alter table discount
add foreign key(id) references courier(id);

drop table courier;

drop table courier_province;

-- Merge All
create table courier_province 
as
	(
	select c.id, c.expedition, c.mode_of_shipment, c.customer_care_calls, c.customer_rating, c.cost_of_the_product, c.prior_purchases,
		   c.product_importance, c.gender, c.discount_offered, c.weight_in_gms, c.delay_or_ontime, c.province_code, p.province 
	from courier c 
	join province p 
	on c.province_code = p.province_code 
	order by c.id
	);

-- Transaction Count
select expedition, count(id) as "transaction_count"
from courier
group by expedition
order by 2 desc;

-- Average Discount Offered
select expedition, round(avg(discount_offered),2) as "average_discount"
from courier c 
group by 1
order by 2 desc;

-- Rating Count Expedition
select expedition, customer_rating, count(customer_rating) as "rating_count"
from courier c
group by expedition, customer_rating
order by 1,2
--having customer_rating = '5';

-- Delay or Ontime Count
select expedition, delay_or_ontime, count(delay_or_ontime) as count
from courier c
group by expedition, delay_or_ontime
order by 1,2;

-- Customer Care Calls Count
select expedition, customer_care_calls , count(customer_care_calls) as count
from courier c
group by expedition, customer_care_calls 
order by 1,2;

-- Mode of Shipment Count
select expedition, mode_of_shipment, count(mode_of_shipment) as count
from courier c
group by expedition, mode_of_shipment  
order by 1,2;

-- Destination Province
select expedition, province, count(province) as count
from courier_province cp 
group by expedition, province 
order by 1,2,3;

--Calculating Average Discount
alter table courier
add column discount float
create table discount
as
	(
	select id, cast(cast(discount_offered as float) / cast(cost_of_the_product as float) * 100 as decimal(4,2)) as discount
	from courier
	);
	--update courier 
	--set discount = cast(cast(discount_offered as float) / cast(cost_of_the_product as float) * 100 as decimal(4,2))
select c.expedition, avg(d.discount) as avg_discount
from courier c 
join discount d 
on c.id = d.id
group by expedition
order by avg_discount desc;

-- Calculating Average Weight
select expedition, cast(avg(weight_in_gms) as decimal(6,2)) as avg_weight_gms
from courier c 
group by expedition
order by 2 desc;

-- 1 Rating by Customer
select expedition, customer_rating, count(customer_rating)
from courier c
group by expedition, customer_rating 
having customer_rating = 1
order by 3 desc;

-- Average Cost Grouped by Gender
select gender, round(avg(cost_of_the_product)) as avg_cost
from courier c 
group by gender 
order by 2;

select expedition, province, delay_or_ontime, count(delay_or_ontime)
from courier_province cp 
group by 1,2,3
having delay_or_ontime = 0
order by 1,4 desc

-- Average Shipping Cost to Each City
select province, mode_of_shipment, round(avg(cost_of_the_product)) as avg_cost 
from courier_province cp
group by 1,2
order by 1,2 desc
