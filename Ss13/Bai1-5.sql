create database baitap_ss13;
use baitap_ss13;

-- Bai 1
create table users(
	user_id int primary key auto_increment,
    username varchar(50) not null unique,
    email varchar(100) not null unique,
    created_at date,
    follower_count int default 0,
    post_count int default 0
);

create table posts(
	post_id int primary key auto_increment,
    user_id int, 
	content text,
    created_at datetime,
    like_count int default 0,
    
    foreign key (user_id) references users(user_id) on delete cascade
);

insert into users(username, email, created_at) values
('alice', 'alice@example.com', '2025-01-01'),
('bob', 'bob@example.com', '2025-01-02'),
('charlie', 'charlie@example.com', '2025-01-03');

-- tao 2 trigger
delimiter $$
-- post_count +1
create trigger trigger_posts_after_insert
after insert on posts
for each row
begin
    update users set post_count = post_count + 1
    where user_id = new.user_id;
end $$

-- post_count -1
create trigger trigger_posts_after_delete
after delete on posts
for each row
begin
    update users set post_count = post_count - 1
    where user_id = old.user_id;
end $$

delimiter ;

insert into posts (user_id, content, created_at) values
(1, 'Hello world from Alice!', '2025-01-10 10:00:00'),
(1, 'Second post by Alice', '2025-01-10 12:00:00'),
(2, 'Bob first post', '2025-01-11 09:00:00'),
(3, 'Charlie sharing thoughts', '2025-01-12 15:00:00');
select * from users;

delete from posts where post_id = 2;
select * from users;


-- Bai 2
create table likes (
	like_id int primary key auto_increment,
    user_id int,
    post_id int,
    liked_at datetime default current_timestamp,
    foreign key (user_id) references users(user_id) on delete cascade,
    foreign key (post_id) references posts(post_id) on delete cascade
);

insert into likes (user_id, post_id, liked_at) values
(2, 1, '2025-01-10 11:00:00'),
(3, 1, '2025-01-10 13:00:00'),
(1, 3, '2025-01-11 10:00:00'),
(3, 4, '2025-01-12 16:00:00');

-- tao trigger tu dong cap nhat like_count
delimiter $$
create trigger trig_likes_after_insert
after insert on likes
for each row
begin 
	update posts set like_count = like_count+1
    where post_id= new.post_id;
end $$

create trigger trig_likes_after_delete
after delete on likes
for each row
begin
	update posts set like_count= like_count- 1
    where post_id= old.post_id;
end $$

delimiter ;

-- tao view
create view user_statistics as
select u.user_id, u.username, u.post_count, ifnull(sum(p.like_count), 0) `total_likes`
from users u
left join posts p on p.user_id =u.user_id
group by u.user_id, u.username, u.post_count;

insert into likes (user_id, post_id, liked_at) values (2, 4, NOW());
select * from posts where post_id = 4;
select * from user_statistics;

-- xoa va kiem chung lai
delete from likes
where user_id = 2 and post_id = 4
order by liked_at desc limit 1;
select * from posts where post_id = 4;
select * from user_statistics;


-- Bai 3
delimiter $$
-- before insert k cho user like bai dang cua chinh minh
create trigger trig_likes_before_insert
before insert on likes
for each row
begin
	declare v_post_owner int;
    select user_id into v_post_owner
    from posts
    where post_id= new.post_id;
    
    if v_post_owner= new.user_id then 
		signal sqlstate '45000' set message_text = 'khong duoc like bai dang cua chinh minh';
	end if;
end $$

-- AFTER INSERT/DELETE/UPDATE: cập nhật posts.like_count
-- insert
create trigger trig_likes_after_insert
after insert on likes
for each row
begin
	update posts set like_count= like_count+ 1
    where post_id= new.post_id;
    
end $$

-- delete
create trigger trig_likes_after_delete
after delete on likes
for each row
begin
	update posts set like_count= like_count- 1
    where post_id= old.post_id;
    
end $$

-- update: neu doi like sang post khac thi -post cu +post moi
create trigger trig_likes_after_update
after update on likes
for each row
begin
	if old.post_id <> new.post_id then
		update posts set like_count= like_count- 1
		where post_id= old.post_id;
		
		update posts set like_count= like_count+ 1
		where post_id= new.post_id;
	end if;
    
end $$

delimiter ;

-- cac thao tac kiem thu
-- Thử like bài của chính mình (phải báo lỗi)
insert into likes (user_id, post_id, liked_at) values (1, 1, now());

-- Thêm like hợp lệ, kiểm tra like_count
insert into likes (user_id, post_id, liked_at) values (2, 1, now());
select * from posts where post_id = 1;

-- UPDATE một like sang post khác, kiểm tra like_count của cả hai post
update likes set post_id = 4
where user_id = 2 and post_id = 1
order by liked_at desc limit 1;

select * from posts where post_id in (1, 4);

-- Xóa like và kiểm tra
delete from likes
where user_id = 2 and post_id = 1
order by liked_at desc limit 1;

select * from posts where post_id=4;

-- Truy vấn SELECT từ posts và user_statistics
select * from posts;
select * from user_statistics;


-- Bai 4
create table post_history (
	history_id int primary key auto_increment,
    post_id int,
    old_content text,
    new_content text,
    changed_at datetime,
    changed_by_user_id int,
    foreign key (post_id) references posts(post_id) on delete cascade
);

-- tao trigger
-- BEFORE UPDATE trên posts
delimiter $$
create trigger trig_posts_before_update_history
before update on posts
for each row
begin
	if not (old.content <=> new.content) then
        insert into post_history (post_id, old_content, new_content, changed_at, changed_by_user_id)
        values (old.post_id, old.content, new.content, NOW(), old.user_id);
    end if;
end $$

-- AFTER DELETE trên posts
create trigger trig_posts_after_delete_history
after delete on posts
for each row
begin
    
end $$
delimiter ;

-- UPDATE nội dung một số bài đăng
update posts set content= concat(content, ' edit')
where post_id in(1, 3);
select * from post_history order by history_id;

-- Kiểm tra kết hợp với trigger like_count
select post_id, user_id, content, like_count
from posts where post_id in(1, 3);


-- Bai 5
-- tao producre
delimiter $$
create procedure add_user(in p_username varchar(50), in p_email varchar(100), in p_created_at date)
begin
	insert into users (username, email, created_at)
    values (p_username, p_email, p_created_at);
end $$
delimiter ;

-- 
delimiter $$
create trigger trig_users_before_insert_validate
before insert on users
for each row
begin
	-- email co '@' va '.'
    if new.email not like '%@%.%' then
		signal sqlstate '45000' set message_text= 'Email khong hop le';
	end if;
    
    -- username chi gom chu cai, so, uderscore
    -- regexp: ^[A-Za-z0-9_]+$
    if new.username not regexp '^[A-Za-z0-9_]+$' then
		signal sqlstate '45000' set message_text= 'username khong hop le';
	end if;
end $$
delimiter ;

-- goi procedure 
-- hop le
call add_user('user_ok_1', 'user_ok_1@example.com', '2025-01-05');
-- khong hop le: email thieu '.' (loi)
call add_user('user_ok_2', 'user_ok_2@examplecom', '2025-01-06');
-- khong hop le: username co ky tu dac biet '-' (loi)
call add_user('user-bad', 'user_bad@example.com', '2025-01-07');


select * from users;