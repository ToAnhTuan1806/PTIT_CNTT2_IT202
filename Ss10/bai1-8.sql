USE social_network_pro;

-- Bai 1
create or replace view view_users_firstname as
select user_id, username, full_name, email, created_at 
from users
where full_name like 'Nguyễn%';

select * from view_users_firstname;

-- them 1 nv moi
insert into users (username, full_name, gender, email, password, birthdate, hometown) values
('nguyen', 'Nguyễn Văn Mới', 'Nam', 'nguyen@gmail.com', '123', '1996-01-01', 'Hà Nội');
select * from view_users_firstname;

-- xoa nv vua them
delete from users where username = 'nguyen';
select * from view_users_firstname;


-- Bai 2
create or replace view view_user_post as
select u.user_id, count(p.post_id) as total_user_post
from users u
left join posts p on u.user_id = p.user_id
group by u.user_id;

select * from view_user_post;
-- tong so bai viet ma ng dung da dang
select u.full_name, v.total_user_post
from users u
join view_user_post v on u.user_id = v.user_id
order by v.total_user_post desc;


-- USE social_network_pro;
-- SHOW TABLES;

-- Bai 3:
-- tất cả những User ở Hà Nội
explain analyze
select * from users
where hometown = 'Hà Nội';

-- tạo chỉ mục
create index idx_hometown on users (hometown);

-- chay lai 
explain analyze
select * from users
where hometown = 'Hà Nội';

drop index idx_hometown on users;


-- Bai 4:
-- tao chi muc phuc hop
explain analyze
select post_id, content, created_at
from posts
where user_id = 1 and created_at >= '2026-01-01' and created_at < '2027-01-01';

create index idx_created_at_user_id on posts (created_at, user_id);
-- chay lai
explain analyze
select post_id, content, created_at
from posts
where user_id = 1 and created_at >= '2026-01-01' and created_at < '2027-01-01';

-- tao chi muc duy nhat
explain analyze
select user_id, username, email
from users
where email = 'an@gmail.com';

create unique index idx_email on users (email);
explain analyze
select user_id, username, email
from users;

-- xoa chi muc
drop index idx_created_at_user_id on posts;
drop index idx_email on users;


-- Bai 5:
create index idx_hometown on users (hometown);

explain analyze
select u.user_id, u.username, u.hometown, p.post_id, p.content
from users u
join posts p on p.user_id = u.user_id
where u.hometown = 'Hà Nội' ;


-- Bai 6:
create or replace view view_users_summary as
select u.user_id, u.username, count(p.post_id) `total_posts`
from users u
left join posts p on u.user_id = p.user_id
group by u.user_id, u.username;

-- hiển thị các thông tin về người dùng có total_posts > 5
select user_id, username, total_posts
from view_users_summary
where total_posts > 5;


-- Bai 7:
create or replace view view_user_activity_status as 
select u.user_id, u.username, u.gender, u.created_at, 
	case
		when count(distinct p.post_id)>0
        or count(distinct c.comment_id)>0
        then 'Active'
        else 'Inactive'
	end as status
from users u
left join posts p on u.user_id = p.user_id
left join comments c on u.user_id = c.user_id
group by u.user_id, u.username, u.gender, u.created_at;

select * from view_user_activity_status;

-- thong ke so luong ng dung
select status, count(*) as user_count
from view_user_activity_status
group by status
order by user_count desc;

-- Bai 8:
create index idx_user_gender on users (gender);

create or replace view view_popular_posts as
select  p.post_id, u.username, p.content, 
		count(distinct u.user_id)as like_count, count(distinct c.comment_id) as comment_count
from posts p
join users u on u.user_id = p.user_id
left join likes l on l.post_id = p.post_id
left join comments c on c.post_id = p.post_id
group by  p.post_id, u.username, p.content;

select * from view_popular_posts;

-- liệt kê các bài viết có số like + comment > 10
select post_id, username, content, like_count, comment_count, (like_count + comment_count) as total_interactions
from view_popular_posts
where (like_count + comment_count)>10
order by total_interactions desc;