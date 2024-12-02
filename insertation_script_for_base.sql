insert
	into
	service(
	id,
	region,
	street)
select 
	nextval('service_id_seq'), 
	service ,
	service_addr
from
	(
	select
		distinct
	t.service as service ,
		t.service_addr as service_addr
	from
		(
		select
			min(service) as service ,
			min(service_addr) as service_addr,
			w_name,
			w_phone
		from
			dirty_data dd
		group by
			w_name,
			w_phone
	) t) t;
	
insert into employee(id,service_id, "name", surname, experiance, phone_number, salary)
select  nextval('employee_id_seq'),
		service_id,
		split_part(w_name, ' ', 1) as "name",
		split_part(w_name, ' ', 2) as surname,
		max(experiance) as experiance,
		max(w_phone) as phone,
		max(salary) as salary
from(
	select 	(select id from service s where s.region = service or s.street = service_addr) service_id
			, max(w_name) w_name
			, max(w_exp) experiance
			, w_phone
			, max(wages) salary
	from dirty_data dd 
	group by w_phone, service, service_addr
) t
group by t.service_id, t.w_name;

insert into car (id, model, vin, "number", color)
select
nextval('car_id_seq'), max(car), vin, max(car_number), max(color)
from dirty_data dd 
where vin is not null
group by vin;

insert
	into
	client (id,
	"name",
	surname,
	phone_number,
	email,
	password)
	select
	nextval('client_id_seq'), 
	name,
	surname,
	max(phone) as phone,
	max(email) as email,
	max(password) as password
from
	(
	select
		split_part(max(name), ' ', 1) as name,
		split_part(max(name), ' ', 2) as surname,
		phone,
		email,
		max(password) as password
	from
		dirty_data
	group by
		phone,
		email
) t
group by
	t.name,
	t.surname;

insert into client_car (car_id, client_id)
select 
	max(c.id) as car_id,
 	max(cl.id) as client_id
from dirty_data dd 
join car c on c.vin = dd.vin or c."number" = dd.car_number 
join client cl on cl.phone_number = dd.phone or cl.email = dd.email or cl."password" = dd."password" 
group by cl.id, c.id;

insert into card (id, card_number, client_id) 
select distinct 
nextval('card_id_seq'),
card,
(select id from client c where 
	c.phone_number = dd.phone 
	or c.email = dd.email
	or c."password" = dd."password")
from dirty_data dd
where card is not null;

insert into order_transaction (id ,	"date",	service_id ,employee_id ,client_id,card_id,car_id, mileage ,pin,payment)
	(
	select
	nextval('order_transaction_id_seq') as id,
		"date"::date,
		s.id as service_id,
		e.id as employee_id,
		c.id as client_id,
		cc.id as card_id,
		car.id as car_id,
		dd.mileage,
		dd.pin,
		dd.payment 
	from
		dirty_data dd
	left join service s on
		s.region = dd.service
		or s.street = dd.service_addr
	left join employee e on e.service_id = s.id 
		and (e.phone_number = dd.w_phone or e."name"||' '||e.surname = dd.w_name)
	left join client c on c.email = dd.email or c.phone_number  = dd.phone or c."password"  = dd."password" 
	join card cc on cc.card_number = dd.card and cc.client_id = c.id 
	left join car car on car.vin = dd.vin or car."number" = dd.car_number 
	where payment is not null);