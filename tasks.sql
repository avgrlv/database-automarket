-- 1. Скидки
create table discount_matrix (
    id serial primary key,
    client_id int8,
    percentage int8,
    foreign key (client_id) references client(id)
);
comment on table discount_matrix is 'Матрица скидок от количества посящений';

insert into discount_matrix(client_id, percentage)
(
	select client_id, percentage
    from (
        with counted as (
            select client_id, count(*) as order_count
            from order_transaction 
            group by client_id
        )
        (select client_id, 30 as percentage from counted c where c.order_count > 100)
        union all
        (select client_id, 10 as percentage from counted c where c.order_count between 70 and 100)
    ) as discount
);

-- 2. Буст работников
update employee set salary = salary * 1.1
where id in (
select ot.employee_id  from order_transaction ot
group by ot.employee_id 
order by sum(ot.payment) desc 
limit 3
);

/*3. Сделать представление для директора: 
филиал, 
количество заказов за последний месяц, 
заработанная сумма,
заработанная сумма за вычетом зарплаты
*/

create view month_record as (
    select
        s.id,
        s.region,
        s.street,
        count(ot.*) as month_orders,
        sum(ot.payment) as month_income,
        sum(ot.payment) - sum(e.salary) as pure_income
    from service s 
    left join employee e on e.service_id  = s.id 
    left join order_transaction ot on ot.service_id = s.id and ot.employee_id = e.id 
    where ot."date" >= (select max(ot2."date") from order_transaction ot2) - interval '1 month'
    group by
        s.id, s.region, s.street 
);



-- 4.Сделать рейтинг самых надежных и ненадежных авто
with car_frequancy_payment as (
 select car_id,
 		c.model,
 		count(ot.*) as freq,
    	sum(ot.payment) as summary
    from order_transaction ot 
    left join car c on c.id = ot.car_id 
    group by ot.car_id, c.model)
(select cp.model, 'Ненадёжные' from car_frequancy_payment cp order by freq desc, summary desc limit 3)
union all 
(select cp.model, 'Надёжные' from car_frequancy_payment cp order by freq asc, summary asc limit 3);
-- 5.Самый "удачный" цвет для каждой модели авто
with model_color_amount as (select
		c.model,
		c.color,
		count(ot.*) cnt
	from
		car c
	left join order_transaction ot on
		ot.car_id = c.id
	group by
		c.model,
		c.color ),
min_model_color as (
select
	t.model,
	min(t.cnt) min_cnt
from model_color_amount t
group by
	t.model)
select mca.model, mca.color, mca.cnt from model_color_amount mca
join min_model_color mmc on mmc.model = mca.model and mmc.min_cnt = mca.cnt