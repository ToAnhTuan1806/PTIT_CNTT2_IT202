create database baitap_ss7;
use baitap_ss7;

-- bai 1
create table customers(
	customer_id int primary key,
    customer_name varchar(255) not null,
    email varchar(50) not null unique
);

create table orders(
	order_id int primary key,
    customer_id int not null,
    order_date date,
    total_amount decimal(10, 2) not null check(total_amount>0),
    foreign key (customer_id) references customers(customer_id)
);

insert into customers values
(1, 'Nguyen Van An', 'an.nguyen@gmail.com'),
(2, 'Tran Thi Binh', 'binh.tran@gmail.com'),
(3, 'Le Hoang Minh', 'minh.le@gmail.com'),
(4, 'Pham Thu Trang', 'trang.pham@gmail.com'),
(5, 'Vo Duc Long', 'long.vo@gmail.com'),
(6, 'Do Thi Mai', 'mai.do@gmail.com'),
(7, 'Hoang Quoc Huy', 'huy.hoang@gmail.com');

insert into orders (order_id, customer_id, order_date, total_amount) values
(101, 1, '2025-01-05', 2500000.00),
(102, 2, '2025-01-08', 5200000.00),
(103, 3, '2025-01-10', 1800000.00),
(104, 1, '2025-01-15', 7500000.00),
(105, 4, '2025-01-18', 3200000.00),
(106, 5, '2025-01-20', 9100000.00),
(107, 2, '2025-01-25', 4600000.00);

-- DS KH da tung dat don hang
select * from customers
where customer_id in (
	select customer_id 
	from orders
);


-- bai 2
create table products(
	product_id int primary key,
    product_name varchar(255) not null,
    price decimal(10, 2) not null check(price>0)
);

create table order_items(
	order_id int not null,
    product_id int not null,
    quantity int not null check(quantity>0),
    primary key(order_id, product_id),
    foreign key (order_id) references orders(order_id),
    foreign key (product_id) references products(product_id)
);

insert into products values
(1, 'Ao thun basic', 150000.00),
(2, 'Quan jeans', 350000.00),
(3, 'Giay sneaker', 790000.00),
(4, 'Tui deo cheo', 220000.00),
(5, 'Mu luoi trai', 90000.00),
(6, 'Tai nghe bluetooth', 490000.00),
(7, 'Binh nuoc', 80000.00);

insert into order_items (order_id, product_id, quantity) values
(101, 1, 2),
(101, 3, 1),
(102, 2, 1),
(102, 5, 3),
(103, 4, 1),
(104, 6, 1),
(105, 3, 2);

select * from products
where product_id in (
	select product_id 
    from order_items 
);


-- bai 3
insert into orders (order_id, customer_id, order_date, total_amount) values
(201, 1, '2025-12-01',  500000.00),
(202, 2, '2025-12-03', 1200000.00),
(203, 3, '2025-12-05',  300000.00),
(204, 1, '2025-12-10', 2500000.00),
(205, 4, '2025-12-12',  800000.00);

select * from orders
where total_amount > (
	select avg(total_amount)
    from orders
);

-- bai 4
select c.customer_name, (
	select count(*)
    from orders o
    where o.customer_id = c.customer_id
) as order_count
from customers c;

-- bai 5
select customer_name
from customers
where customer_id = (
	select customer_id
    from orders
    group by customer_id
    having sum(total_amount) = (
    	-- lay tong tien lon nhat trong all khach
		select max(tong_tien)
		from (
			-- tong tien moi KH
			select sum(total_amount) as tong_tien
			from orders
			group by customer_id
		) as temp
    )
);