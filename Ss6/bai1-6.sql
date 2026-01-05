create database baitap_ss6;
use baitap_ss6;

-- bai 1
create table customers(
	customer_id int primary key,
    full_name varchar(255) not null,
    city varchar(255) 
);

create table orders(
	order_id int primary key,
    customer_id int not null,
    order_date date not null,
    status enum('pending', 'completed', 'cancelled'),
    foreign key (customer_id) references customers(customer_id)
);

insert into customers values
(1, 'Nguyen Van An', 'Ha Noi'),
(2, 'Tran Thi Binh', 'Ho Chi Minh'),
(3, 'Le Hoang Long', 'Da Nang'),
(4, 'Pham Thu Hang', 'Hai Phong'),
(5, 'Vu Minh Tuan', 'Can Tho');

insert into orders (order_id, customer_id, order_date, status) values
(101, 1, '2025-12-01', 'completed'),
(102, 1, '2025-12-02', 'completed'),
(103, 1, '2025-12-03', 'completed'),
(104, 2, '2025-12-03', 'completed'),
(105, 3, '2025-12-04', 'pending'),
(106, 4, '2025-12-04', 'completed'),
(107, 1, '2025-12-05', 'completed');

-- hien ds don hang kem ten KH
select o.order_id, o.order_date, o.status, c.full_name
from orders o 
join customers c on c.customer_id = o.customer_id;

-- hien thi moi KH da dat bao nhieu don hang
select c.customer_id, c.full_name, count(order_id) `tong don hang`
from customers c
left join orders o on o.customer_id = c.customer_id
group by c.customer_id, c.full_name;

-- hien thi cac KH co it nhat 1 don hang
select c.customer_id, c.full_name, count(order_id) `tong don hang`
from customers c
join orders o on o.customer_id = c.customer_id
group by c.customer_id, c.full_name
having count(o.order_id) >=1;


-- bai 2
alter table orders
add column total_amount decimal(10, 2);

update orders set total_amount = 3500000 where order_id = 101;
update orders set total_amount = 4200000 where order_id = 102;
update orders set total_amount = 2600000  where order_id = 103;
update orders set total_amount = 5100000 where order_id = 104;
update orders set total_amount = 2000000 where order_id = 105;
update orders set total_amount = 1800000 where order_id = 106;
update orders set total_amount = 3100000 where order_id = 107;

-- tong tien ma moi KH da chi tieu
select c.customer_id, c.full_name, sum(total_amount) `tong tien`
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.full_name;

-- gia tri don hang cao nhat cua tung KH
select c.customer_id, c.full_name, max(total_amount) `don hang lon nhat`
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.full_name;

-- sap xep ds KH theo tong tien giam dan
select c.customer_id, c.full_name, sum(total_amount) `tong tien`
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.full_name
order by `tong tien` desc;


-- bai 3 
-- tong doanh thu theo tung ngay
select order_date, sum(total_amount) `tong doanh thu`
from orders where status = "completed"
group by order_date;

-- so luong don hang theo tung ngay
select order_date, count(order_id) `so luong DH`
from orders where status = "completed"
group by order_date;

-- cac ngay co doanh thu > 10000000
select order_date, sum(total_amount) `tong doanh thu`
from orders where status = "completed"
group by order_date
having `tong doanh thu` > 10000000;


-- bai 4
create table products(
	product_id int primary key,
    product_name varchar(255) not null,
    price decimal(10, 2) not null check(price>0)
);

create table order_items(
	order_id int ,
    product_id int ,
    quantity int ,
    primary key(order_id, product_id),
    foreign key (order_id) references orders(order_id),
    foreign key (product_id) references products(product_id)
);

insert into products values
(1, 'Dien thoai', 7000000),
(2, 'Tai nghe', 800000),
(3, 'Ban phim', 1200000),
(4, 'Chuot', 500000),
(5, 'Man hinh', 3500000);

insert into order_items (order_id, product_id, quantity) values
(101, 1, 1),
(101, 2, 2),
(102, 5, 1),
(103, 4, 2),
(104, 1, 1),
(106, 3, 1),
(107, 2, 3);

-- so SP da ban cua tung SP
select p.product_id, p.product_name, sum(quantity) `so SP da ban`
from products p
join order_items oi on p.product_id = oi.product_id
group by p.product_id, p.product_name;

-- doanh thu cua tung SP
select p.product_id, p.product_name, sum(quantity * price) `doanh thu`
from products p
join order_items oi on p.product_id = oi.product_id
group by p.product_id, p.product_name;

-- SP co doanh thu > 5000000
select p.product_id, p.product_name, sum(quantity * price) `doanh thu`
from products p
join order_items oi on p.product_id = oi.product_id
group by p.product_id, p.product_name
having `doanh thu` > 5000000;


-- bai 5
select c.customer_id, c.full_name, 
count(order_id) `tong so dh`,
sum(total_amount) `tong so tien da chi`, 
avg(total_amount) `gia tri dh tb`
from customers c
join orders o on c.customer_id = o.customer_id
where o.status = 'completed'
group by c.customer_id, c.full_name
having `tong so dh` >= 3 and `tong so tien da chi` > 10000000
order by `tong so tien da chi` desc;


-- bai 6
select p.product_name,
sum(quantity) `tong sl ban`,
sum(quantity * price) `tong doanh thu`,
avg(price) `gia ban trung binh`
from products p
join order_items oi on p.product_id = oi.product_id
group by p.product_id, p.product_name
having `tong sl ban` >=10
order by `tong doanh thu` desc limit 5;