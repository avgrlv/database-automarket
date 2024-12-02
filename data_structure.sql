drop table if exists service cascade;
create table service(
  id int8 primary key not null,
  region varchar(255),
  street varchar(255),
  unique(region,street)
);
CREATE SEQUENCE service_id_seq
	INCREMENT 1
	MINVALUE 1 
	MAXVALUE 999999999
	START 1
	cycle
	OWNED BY service.id;
comment on table service is 'Список автосервисов';

drop table if exists employee cascade;
create table employee(
  id int8 primary key not null,
  "name" varchar(255),
  surname varchar(255),
  phone_number varchar(50),
  salary numeric(10,3),
  experiance int8,
  service_id int8 not null,
  constraint fk_service foreign key (service_id) references service(id) on delete cascade
);
CREATE SEQUENCE employee_id_seq
	INCREMENT 1
	MINVALUE 1 
	MAXVALUE 999999999
	START 1
	cycle
	OWNED BY employee.id;
comment on table employee is 'Список сотрудников филиалов';



drop table if exists client cascade;
create table client(
  id int8 primary key not null,
  "name" varchar(255),
  surname varchar(255),
  phone_number varchar(50),
  email varchar(255),
  "password" varchar(255)
);
CREATE SEQUENCE client_id_seq
	INCREMENT 1
	MINVALUE 1 
	MAXVALUE 999999999
	START 1
	cycle
	OWNED BY client.id;
comment on table client is 'Список клиентов';

drop table if exists car;
create table car(
  id int8 primary key not null,
  model varchar(255),
  vin varchar(255),
  "number" varchar(20),
  color varchar(255),
  unique(vin,"number")
);
CREATE SEQUENCE car_id_seq
	INCREMENT 1
	MINVALUE 1 
	MAXVALUE 999999999
	START 1
	cycle
	OWNED BY car.id;
comment on table car is 'Инфомрация об автомобиле';

drop table if exists client_car;
create table client_car(
	client_id int8 not null,
	car_id int8 not null
);
-- Может быть такой вариант, что у человека несколько авто, ровно как и адним авто могут управлять разные люди
comment on table client_car is 'Связь автомобиль-клиент';

drop table if exists card;
create table card(
	id int8 primary key not null,
	card_number varchar(255),
	client_id int8 references client(id)
);
CREATE SEQUENCE card_id_seq
	INCREMENT 1
	MINVALUE 1 
	MAXVALUE 999999999
	START 1
	cycle
	OWNED BY card.id;
comment on table client_car is 'Карты клиента';


drop table if exists order_transaction;
create table order_transaction(
	id int8 primary key not null,
	"date" date not null,
	service_id int8 not null,
	employee_id int8 not null,
	client_id int8 not null,
	card_id int8 not null,
	car_id int8 not null,
	mileage int8,
	pin int8,
	payment int8 not null
);
CREATE SEQUENCE order_transaction_id_seq
	INCREMENT 1
	MINVALUE 1 
	MAXVALUE 999999999
	START 1
	cycle
	OWNED BY order_transaction.id;
comment on table order_transaction is 'Транзакция - обслуживаение';

CREATE INDEX order_transaction_idx ON order_transaction(date);
CREATE INDEX car_vin_idx ON car(vin);
CREATE INDEX client_phone_idx ON client(phone_number);