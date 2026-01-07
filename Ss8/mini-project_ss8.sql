create database mini_project_ss8;
use mini_project_ss8;

create table customers (
    customer_id int primary key auto_increment,
    customer_name varchar(100) not null,
    email varchar(100) not null unique,
    phone varchar(10) not null unique
);

create table categories (
    category_id int primary key auto_increment,
    category_name varchar(255) not null unique
);

create table products (
    product_id int primary key auto_increment,
    product_name varchar(255) not null unique,
    price decimal(10,2) not null check (price > 0),
    category_id int not null,
        foreign key (category_id) references categories(category_id)
);

create table orders (
    order_id int primary key auto_increment,
    customer_id int not null,
    order_date datetime default current_timestamp,
    status enum('pending','completed','cancel') default 'pending',
        foreign key (customer_id) references customers(customer_id)
);

-- order_items
create table order_items (
    order_item_id int primary key auto_increment,
    order_id int not null,
    product_id int not null,
    quantity int not null check (quantity > 0),
        foreign key (order_id) references orders(order_id),
        foreign key (product_id) references products(product_id)
);

insert into customers (customer_name, email, phone) values
('nguyen van a', 'a@gmail.com', '0900000001'),
('tran thi b', 'b@gmail.com', '0900000002'),
('le van c', 'c@gmail.com', '0900000003'),
('pham thi d', 'd@gmail.com', '0900000004'),
('hoang van e', 'e@gmail.com', '0900000005');

insert into categories (category_name) values
('dien thoai'),
('laptop'),
('phu kien');

insert into products (product_name, price, category_id) values
('iphone 14', 20000000, 1),
('samsung s23', 18000000, 1),
('macbook air m1', 25000000, 2),
('dell inspiron', 18000000, 2),
('tai nghe bluetooth', 1500000, 3);

insert into orders (customer_id, status) values
(1, 'completed'),
(2, 'completed'),
(3, 'pending'),
(1, 'completed'),
(4, 'cancel');

insert into order_items (order_id, product_id, quantity) values
(1, 1, 1),
(1, 5, 2),
(2, 3, 1),
(3, 2, 1),
(4, 4, 1),
(4, 5, 3);

-- Phan A
-- 1) lay danh sach tat ca danh muc san pham
select * from categories;

-- 2) lay danh sach don hang co trang thai la completed
select * from orders
where status = 'completed';

-- 3) lay danh sach san pham va sap xep theo gia giam dan
select * from products
order by price desc;

-- 4) lay 5 san pham co gia cao nhat, bo qua 2 san pham dau tien
select * from products
order by price desc
limit 5 offset 2;

-- Phan B
-- 1) lay danh sach san pham kem ten danh muc
select p.product_id, p.product_name, p.price, c.category_name
from products p
join categories c on p.category_id = c.category_id;

-- 2) lay danh sach don hang gom: order_id, order_date, customer_name, status
select o.order_id, o.order_date, cu.customer_name, o.status
from orders o
join customers cu on o.customer_id = cu.customer_id;

-- 3) tinh tong so luong san pham trong tung don hang
select oi.order_id, sum(oi.quantity) `tong_so_luong`
from order_items oi
group by oi.order_id;

-- 4) thong ke so don hang cua moi khach hang
select cu.customer_id, cu.customer_name, count(o.order_id) `so_don_hang`
from customers cu
left join orders o on cu.customer_id = o.customer_id
group by cu.customer_id, cu.customer_name;

-- 5) lay danh sach khach hang co tong so don hang >= 2
select cu.customer_id, cu.customer_name, count(o.order_id) `so_don_hang`
from customers cu
join orders o on cu.customer_id = o.customer_id
group by cu.customer_id, cu.customer_name
having count(o.order_id) >= 2;

-- 6) thong ke gia trung binh, thap nhat va cao nhat cua san pham theo danh muc
select c.category_id, c.category_name,
    avg(p.price) `gia_trung_binh`,
    min(p.price) `gia_thap_nhat`,
    max(p.price) `gia_cao_nhat`
from categories c
join products p on p.category_id = c.category_id
group by c.category_id, c.category_name;


-- Phan C
-- 1) lay danh sach san pham co gia cao hon gia trung binh cua tat ca san pham
select * from products
where price > (select avg(price) from products);

-- 2) lay danh sach khach hang da tung dat it nhat mot don hang
select * from customers
where customer_id in (select distinct customer_id from orders);

-- 3) lay don hang co tong so luong san pham lon nhat
select o.order_id, o.order_date, o.status
from orders o
         join order_items oi on o.order_id = oi.order_id
group by o.order_id
having sum(oi.quantity) = (
    select max(tong_sl)
    from (
             select sum(quantity) as tong_sl
             from order_items
             group by order_id
         ) as temp
);

-- 4) lay ten khach hang da mua san pham thuoc danh muc co gia trung binh cao nhat
select distinct cu.customer_name
from customers cu
where cu.customer_id in (
    select o.customer_id
    from orders o
             join order_items oi on o.order_id = oi.order_id
    where oi.product_id in (
        select p.product_id
        from products p
        where p.category_id = (
            select category_id
            from (
                     select category_id, avg(price) as avg_price
                     from products
                     group by category_id
                     order by avg_price desc
                     limit 1
                 ) as top_cat
        )
    )
);

-- 5) tu bang tam (subquery), thong ke tong so luong san pham da mua cua tung khach hang
select cu.customer_name, temp.tong_sl_mua
from customers cu
         join (
    select o.customer_id, sum(oi.quantity) as tong_sl_mua
    from orders o
             join order_items oi on o.order_id = oi.order_id
    group by o.customer_id
) as temp on cu.customer_id = temp.customer_id;

-- 6) viet lai truy van lay san pham co gia cao nhat, subquery chi tra ve 1 gia tri (khong loi more than 1 row)
select product_id, product_name, price
from products
where price = (select max(price) from products);