create database baitap_ss5;
use baitap_ss5;

create table products(
	product_id int primary key,
    product_name varchar(25) not null,
    price decimal(10,2) not null,
    stock int not null check(stock>0),
    status enum('active', 'inactive')
);

insert into products values
(1, 'Laptop Dell Inspiron', 15000000.00, 10, 'active'),
(2, 'Chuột không dây Logitech', 450000.00, 50, 'active'),
(3, 'Bàn phím cơ', 1200000.00, 20, 'inactive'),
(4, 'Màn hình Samsung 24 inch', 3200000.00, 8, 'active'),
(5, 'Tai nghe Bluetooth', 950000.00, 30, 'inactive');

select * from products;
select * from products where status = 'active';
select * from products where price > 1000000;
select * from products where status = 'active' order by price asc;

-- bai 2
create table customers(
	customer_id int primary key,
    full_name varchar(255) not null,
    email varchar(255) unique,
    city varchar(255) not null,
    status enum('active', 'inactive') not null
);

insert into customers values
(1, 'Nguyễn Văn Hùng', 'hung.nguyen101@gmail.com', 'Hà Nội', 'active'),
(2, 'Trần Thị Mai', 'mai.tran102@gmail.com', 'Hồ Chí Minh', 'active'),
(3, 'Lê Hoàng Long', 'long.le103@gmail.com', 'Đà Nẵng', 'inactive'),
(4, 'Phạm Thị Linh', 'linh.pham104@gmail.com', 'Hải Phòng', 'active'),
(5, 'Hoàng Thị Yến', 'yen.hoang105@gmail.com', 'Cần Thơ', 'inactive');

select * from customers;
select * from customers where city = 'Hồ Chí Minh';
select * from customers where status = 'active' and city = 'Hà Nội';
select customer_id, full_name, email, city, status
from customers order by full_name asc;


-- bai 3
create table orders(
	order_id int primary key auto_increment,
    customer_id int not null,
    total_amount decimal(10, 2) not null check(total_amount>0),
    order_date date not null,
    status enum('pending', 'completed', 'cancelled') not null
);

insert into orders (customer_id, total_amount, order_date, status)
values
(1, 3200000, '2025-12-01', 'completed'),
(2, 8500000, '2025-12-05', 'pending'),
(3, 12000000, '2025-12-10', 'completed'),
(4, 4500000, '2025-12-15', 'cancelled'),
(5, 6700000, '2025-12-18', 'completed');

select * from orders where status = 'completed';
select * from orders where total_amount > 5000000;
select * from orders order by order_date desc limit 5;
select * from orders where status = 'completed' order by total_amount desc;

-- bai 4
alter table products
add sold_quantity int not null default 0;

update products set sold_quantity = 120 where product_id = 1;
update products set sold_quantity = 300 where product_id = 2;
update products set sold_quantity = 180 where product_id = 3;
update products set sold_quantity = 90  where product_id = 4;
update products set sold_quantity = 220 where product_id = 5;

insert into products values
(6,  'Ổ cứng SSD 512GB',        1800000.00, 40, 'active',   260),
(7,  'Ổ cứng HDD 1TB',          1300000.00, 35, 'active',   190),
(8,  'USB 64GB',                 250000.00, 100,'active',   310),
(9,  'Chuột gaming',             850000.00, 60, 'active',   170),
(10, 'Balo laptop',              550000.00, 45, 'inactive', 140),
(11, 'Webcam Full HD',          1100000.00, 25, 'active',   95),
(12, 'Loa Bluetooth JBL',       2200000.00, 30, 'active',   210),
(13, 'Sạc dự phòng 20000mAh',    900000.00, 50, 'active',   275),
(14, 'Router Wifi',             1600000.00, 20, 'active',   155),
(15, 'Bàn phím không dây',       780000.00, 70, 'inactive', 165);

select * from products order by sold_quantity desc limit 10;
select * from products order by sold_quantity desc limit 5 offset 10;
select * from products where price < 2000000 order by sold_quantity desc;

-- bai 5
insert into orders (customer_id, total_amount, order_date, status)
values
(6,  2100000,  '2025-12-20', 'pending'),
(7,  9800000,  '2025-12-21', 'completed'),
(8,  1500000,  '2025-12-22', 'completed'),
(9,  4300000,  '2025-12-23', 'pending'),
(10, 7600000,  '2025-12-24', 'completed'),
(11, 5200000,  '2025-12-25', 'cancelled'),
(12, 8900000,  '2025-12-26', 'completed'),
(13, 2600000,  '2025-12-27', 'pending'),
(14, 13400000, '2025-12-28', 'completed'),
(15, 3100000,  '2025-12-29', 'completed'),
(16, 4700000,  '2025-12-30', 'pending'),
(17, 6200000,  '2025-12-31', 'completed');

-- trang 1
select * from orders 
where status <> 'cancelled'
order by order_date desc limit 5 offset 0;
-- trang 2
select * from orders 
where status <> 'cancelled'
order by order_date desc limit 5 offset 5;
-- trang 3
select * from orders 
where status <> 'cancelled'
order by order_date desc limit 5 offset 10;

-- bai 6

insert into products values
(16, 'Chuột gaming RGB',        1200000, 40, 'active',   180),
(17, 'Bàn phím cơ TKL',         2500000, 30, 'active',   210),
(18, 'Webcam 2K',               1800000, 20, 'active',   95),
(19, 'Tai nghe gaming',         1600000, 35, 'active',   175),
(20, 'Loa vi tính 2.1',          2200000, 25, 'active',   130),
(21, 'Ổ cứng SSD 256GB',         1450000, 50, 'active',   260),
(22, 'Router Wifi AC',           1950000, 15, 'active',   110),
(23, 'USB 128GB',                1100000, 80, 'active',   300),
(24, 'Chuột không dây cao cấp',  1750000, 40, 'inactive', 90),
(25, 'Tai nghe Bluetooth Pro',   2900000, 20, 'active',   160),
(26, 'Bàn phím không dây slim',  1350000, 60, 'active',   140),
(27, 'Webcam Full HD Pro',       1550000, 25, 'active',   105),
(28, 'Loa Bluetooth mini',       1250000, 45, 'inactive', 200),
(29, 'Hub USB-C',                1050000, 70, 'active',   85),
(30, 'Đế tản nhiệt laptop',      1300000, 55, 'active',   190);

-- trang 1
select * from products
where status = 'active' and price between 1000000 and 3000000
order by price asc
limit 10 offset 0;
-- trang 2
select * from products
where status = 'active' and price between 1000000 and 3000000
order by price asc
limit 10 offset 10;