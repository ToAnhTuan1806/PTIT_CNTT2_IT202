CREATE DATABASE mini_project_ss08;
USE mini_project_ss08;

-- Xóa bảng nếu đã tồn tại (để chạy lại nhiều lần)
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS guests;

-- Bảng khách hàng
CREATE TABLE guests (
    guest_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_name VARCHAR(100),
    phone VARCHAR(20)
);

-- Bảng phòng
CREATE TABLE rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_type VARCHAR(50),
    price_per_day DECIMAL(10,0)
);

-- Bảng đặt phòng
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

INSERT INTO guests (guest_name, phone) VALUES
('Nguyễn Văn An', '0901111111'),
('Trần Thị Bình', '0902222222'),
('Lê Văn Cường', '0903333333'),
('Phạm Thị Dung', '0904444444'),
('Hoàng Văn Em', '0905555555');

INSERT INTO rooms (room_type, price_per_day) VALUES
('Standard', 500000),
('Standard', 500000),
('Deluxe', 800000),
('Deluxe', 800000),
('VIP', 1500000),
('VIP', 2000000);

INSERT INTO bookings (guest_id, room_id, check_in, check_out) VALUES
(1, 1, '2024-01-10', '2024-01-12'), -- 2 ngày
(1, 3, '2024-03-05', '2024-03-10'), -- 5 ngày
(2, 2, '2024-02-01', '2024-02-03'), -- 2 ngày
(2, 5, '2024-04-15', '2024-04-18'), -- 3 ngày
(3, 4, '2023-12-20', '2023-12-25'), -- 5 ngày
(3, 6, '2024-05-01', '2024-05-06'), -- 5 ngày
(4, 1, '2024-06-10', '2024-06-11'); -- 1 ngày

-- Phan I:
-- liet ke ten va sdt cua tat ca khach hang
select guest_name, phone from guests;

-- liet ke cac loai phong khac nhau trong KS
select room_type from rooms;

-- hien thi loai phong va gia thue theo ngay, sx theo gia tang dan
select room_type, price_per_day from rooms 
order by price_per_day asc;

-- hien thi phong co gia thue lon hon 1000000
select room_id, room_type, price_per_day from rooms
where price_per_day > 1000000;

-- liet ke cac luot dat phong dien ra trong 2024
select booking_id, guest_id, room_id, check_in, check_out from bookings
where check_in >= '2024-01-01' and check_in <'2025-01-01';

-- so luong cua tung loai phong
select room_type, count(*) `so luong dat phong`
from rooms
group by room_type;


-- Phan II:
-- liet ke danh sach cac lan dat phong
select booking_id, guest_name, room_type, check_in 
from bookings b
join guests g on b.guest_id = g.guest_id
join rooms r on b.room_id = r.room_id
order by b.check_in;

-- moi khach da dat phong bao nhieu lan
select g.guest_id, g.guest_name, count(b.booking_id) `so lan dat`
from guests g
left join bookings b on g.guest_id = b.guest_id
group by g.guest_id, g.guest_name
order by `so lan dat` desc;

-- doanh thu cua moi phong
select b.room_id,
(b.check_out - b.check_in) `so ngay o`, r.price_per_day, (b.check_out - b.check_in) * r.price_per_day `doanh thu`
from bookings b
join rooms r on b.room_id = r.room_id
order by b.booking_id;


-- tong doanh thu cua tung loai phong
select r.room_type, sum((b.check_out - b.check_in) * r.price_per_day) `tong doanh thu`
from bookings b
join rooms r on b.room_id = r.room_id
group by r.room_type
order by `tong doanh thu` desc;

-- nhung khach da dat phong tu 2 lan tro len
select g.guest_id, g.guest_name, count(*) `so lan dat`
from bookings b
join guests g on b.guest_id = g.guest_id
group by g.guest_id, g.guest_name
having count(*) >= 2;

-- loai phong co so luot dat phong nhieu nhat
select r.room_type, count(*) `so luot dat`
from bookings b
join rooms r on b.room_id = r.room_id
group by r.room_type
order by `so luot dat` desc
limit 1;

-- Phan III:
-- nhung phong co gia thue cao hon gia trung binh
select room_id, room_type, price_per_day
from rooms
where price_per_day > (
    select avg(price_per_day)
    from rooms
);

-- Hiển thị những khách chưa từng đặt phòng
select g.guest_id, g.guest_name, g.phone
from guests g
left join bookings b on g.guest_id = b.guest_id
where b.booking_id is null;

-- Tìm phòng được đặt nhiều lần nhất
select r.room_id, r.room_type, r.price_per_day, count(*) `so luot dat`
from bookings b
join rooms r on b.room_id = r.room_id
group by r.room_id, r.room_type, r.price_per_day
order by `so luot dat` desc
limit 1;


