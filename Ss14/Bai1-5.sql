create database SocialNetworkDB;
use SocialNetworkDB;

-- Bai 1
create table users (
	user_id int primary key auto_increment,
    username varchar(50) not null,
    posts_count int default 0
);

create table posts(
	post_id int primary key auto_increment,
    user_id int,
    content text,
    created_at datetime default current_timestamp,
    foreign key (user_id) references users(user_id)
);

-- them du lieu mau
insert into users(username) values ('tuan'), ('an'), ('minh');
select* from users;

-- th thanh cong -> commit
start transaction;
insert into posts(user_id, content) values
(1, 'Bai viet moi cua user 1');

update users set posts_count= posts_count+1
where user_id= 1;

commit;

select * from users where user_id=1;
select * from posts where user_id=1;

-- th gay loi co y
start transaction;
insert into posts(user_id, content) values
(333, 'Bai viet loi do user khong ton tai');

rollback; -- sau khi loi chay dong nay

select * from posts where user_id= 333;
select * from users;



-- Bai 2
create table likes(
	like_id int primary key auto_increment,
    post_id int not null,
    user_id int not null,
    foreign key (post_id) references posts(post_id),
    foreign key (user_id) references users(user_id),
    unique key unique_like (post_id, user_id)
);

alter table posts
add likes_count int default 0;

-- th like lan dau -> commit
start transaction;
insert into likes(post_id, user_id) values(1,1);

update posts set likes_count= likes_count+1
where post_id+ 1;

commit;

select * from likes where post_id =1 and user_id=1;
select post_id, likes_count from posts where post_id=1;

-- th like lan thu 2 cung post va user loi -> rollback
start transaction;
insert into posts(post_id, user_id) values(1,1); -- lenh se loi do da dc tao trc do

rollback;

select * from likes where post_id =1 and user_id=1;
select post_id, likes_count from posts where post_id=1;



-- Bai 3
create table followers(
	follower_id int not null,
    followed_id int not null,
    primary key(follower_id, followed_id),
    foreign key (follower_id) references users(user_id),
    foreign key (followed_id) references users(user_id)
);

alter table users add following_count int default 0;
alter table users add followers_count int default 0;

-- bang follow_log de ghi loi
create table follow_log(
	log_id int primary key auto_increment,
    follower_id int,
    followed_id int,
    error_message varchar(255),
    created_at datetime default current_timestamp
);

-- taoj Stored Procedure sp_follow_user
delimiter $$

create procedure sp_follow_user(in p_follower_id int, in p_followed_id int)
begin
	declare v_count int default 0;
    declare v_exists int default 0;
    
    -- dung DECLARE EXIT HANDLER phat hien loi -> rollback
    declare exit handler for sqlexception
    begin 
		rollback;
        insert into follow_log(follower_id, followed_id, error_message)
        values(p_follower_id, p_followed_id, 'Loi sql khi thuc hien thao tac follow');
	end;

	-- tao transaction
	start transaction;

	-- khong tu follow chinh minh
	if p_follower_id = p_followed_id then
		rollback;
		insert into follow_log(follower_id, followed_id, error_message)
		values (p_follower_id, p_followed_id, 'Khong dc tu follow chinh minh');
		commit;
    
	else 
		-- ktra follower co ton tai khong
		select count(*) into v_exists
		from users where user_id = p_follower_id;
    
		if v_exists = 0 then
			rollback;
			insert into follow_log(follower_id, followed_id, error_message)
			values (p_follower_id, p_followed_id, 'follower khong ton tai');
			commit;
	
		else
			-- ktra followed co ton tai khong
			select count(*) into v_exists
			from users where user_id = p_followed_id;
    
			if v_exists = 0 then
				rollback;
				insert into follow_log(follower_id, followed_id, error_message)
				values (p_follower_id, p_followed_id, 'user dc follow khong ton tai');
				commit;
            
			else
				-- ktra chua follow truoc do
				select count(*) into v_count
				from followers
				where follower_id = p_follower_id and followed_id = p_followed_id;
            
				if v_count > 0 then
					rollback;
					insert into follow_log(follower_id, followed_id, error_message)
					values (p_follower_id, p_followed_id, 'da follow truoc do');
					commit;
                
				else
					-- neu moi ktra ok -> commit
					insert into followers(follower_id, followed_id)
					values (p_follower_id, p_followed_id);

					update users set following_count = following_count + 1
					where user_id = p_follower_id;

					update users set followers_count = followers_count + 1
					where user_id = p_followed_id;

					commit;
				end if;
			end if;
		end if;
	end if;
end$$

delimiter ;


-- goi procedure 
-- thanh cong: user 1 follow user 2
call sp_follow_user(1, 2);

select* from followers where follower_id = 1 and followed_id = 2;
select user_id, username, following_count, followers_count from users where user_id in (1,2);

-- that bai: goi lai lan nua (da follow) -> rollback + log
call sp_follow_user(1, 2);

-- that bai: tu follow chinh minh -> rollback + log
call sp_follow_user(1, 1);

-- that bai: user khong ton tai -> rollback + log
call sp_follow_user(999, 2);

-- xem bang log loi
select * from follow_log order by log_id desc;



-- Bai 4
create table comments (
    comment_id int primary key auto_increment,
    post_id int not null,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (post_id) references posts(post_id),
    foreign key (user_id) references users(user_id)
);

alter table posts add comments_counts int default 0;

-- tao stored procedure sp_post_comment
delimiter $$
create procedure sp_post_comment(in p_post_id int, in p_user_id int, in p_content text)
begin
	-- dung DECLARE EXIT HANDLER phat hien loi -> rollback
	declare exit handler for sqlexception
    begin
        rollback;
    end;
    
    start transaction;
	-- insert comment
    insert into comments(post_id, user_id, content)
    values (p_post_id, p_user_id, p_content);
    
    savepoint after_insert;
    
    -- neu update loi thi chi rollback ve sau khi insert comment
	begin
        declare continue handler for sqlexception
        begin
            rollback to after_insert;
        end;

        -- update comments_count
        update posts set comments_count = comments_count+ 1
        where post_id =p_post_id;
    end;
    
    commit;
end$$

delimiter ;

call sp_post_comment(1, 1, 'binh luan thanh cong');
select * from comments where post_id = 1;
select post_id, comments_count from posts where post_id = 1;



-- Bai 5
-- tao bang log xoa bai
create table delete_log (
    log_id int primary key auto_increment,
    post_id int not null,
    deleted_at datetime default current_timestamp,
    deleted_by int not null
);

-- tao stored procedure sp_delete_post
delimiter $$

create procedure sp_delete_post(
    in p_post_id int,
    in p_user_id int
)
begin
    declare v_owner_id int;
    -- neu co loi sql bat ky buoc nao -> rollback
    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;
    -- kiem tra bai viet ton tai va dung chu bai viet
    select user_id into v_owner_id
    from posts
    where post_id = p_post_id limit 1;

    if v_owner_id is null or v_owner_id <> p_user_id then
        rollback;
    else
        -- xoa likes
        delete from likes
        where post_id = p_post_id;

        -- xoa comments
        delete from comments
        where post_id = p_post_id;

        -- xoa post
        delete from posts
        where post_id = p_post_id;

        -- giam posts_count cua chu bai viet
        update users
        set posts_count = posts_count- 1
        where user_id = p_user_id;

        -- ghi log xoa thanh cong
        insert into delete_log(post_id, deleted_by)
        values (p_post_id, p_user_id);

        commit;
    end if;
end$$

delimiter ;

-- hop le
call sp_delete_post(1, 1);
-- xem log
select * from delete_log order by log_id desc;
-- khong hop le: sai chu bai viet ( post_id=1 nhung user_id khong phai 1)
call sp_delete_post(1, 999);
-- kiem tra (log khong them dong moi neu that bai)
select * from delete_log order by log_id desc;