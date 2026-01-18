create database mini_social_network;
use mini_social_network;

create table users (
   user_id int primary key auto_increment,
   username varchar(50) unique not null,
   password varchar(255) not null,
   email varchar(100) unique not null,
   created_at datetime default current_timestamp
);

create table posts (
    post_id int primary key auto_increment,
    user_id int,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (user_id) references users(user_id) on delete cascade
);

alter table posts add column like_count int default 0;

create table comments (
    comment_id int primary key auto_increment,
    post_id int,
    user_id int,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (post_id) references posts(post_id) on delete cascade,
    foreign key (user_id) references users(user_id) on delete cascade
);

create table likes (
    user_id int,
    post_id int,
    created_at datetime default current_timestamp,
    primary key (user_id, post_id),
    foreign key (user_id) references users(user_id) on delete cascade,
    foreign key (post_id) references posts(post_id) on delete cascade
);

create table friends (
    user_id int,
    friend_id int,
    status varchar(20) check (status in ('pending', 'accepted')) default 'pending',
    created_at datetime default current_timestamp,
    primary key (user_id, friend_id),
    foreign key (user_id) references users(user_id) on delete cascade,
    foreign key (friend_id) references users(user_id) on delete cascade
);

create table user_log (
    log_id int primary key auto_increment,
    user_id int,
    action varchar(50),
    log_time datetime default current_timestamp
);

create table post_log (
    log_id int primary key auto_increment,
    post_id int,
    action varchar(50),
    log_time datetime default current_timestamp
);

create table like_log (
    log_id int primary key auto_increment,
    user_id int,
    post_id int,
    action varchar(50),
    log_time datetime default current_timestamp
);

create table friend_log (
    log_id int primary key auto_increment,
    user_id int,
    friend_id int,
    action varchar(50),
    log_time datetime default current_timestamp
);

-- Bài 1: Đăng ký thành viên
delimiter $$
create procedure sp_register_user(in p_username varchar(50), in p_password varchar(255), in p_email varchar(100))
begin
    declare v_user_count int;
    declare v_email_count int;

    select count(*) into v_user_count from users where username = p_username;
    if v_user_count > 0 then
        signal sqlstate '45000' set message_text = 'Username đã tồn tại';
    end if;

    select count(*) into v_email_count from users where email = p_email;
    if v_email_count > 0 then
        signal sqlstate '45000' set message_text = 'Email đã tồn tại';
    end if;

    insert into users (username, password, email) values (p_username, p_password, p_email);
end $$
delimiter ;

delimiter $$
create trigger trg_after_insert_user
    after insert on users
    for each row
begin
    insert into user_log (user_id, action) values (new.user_id, 'Registered');
end $$
delimiter ;

-- Bài 2: Đăng bài viết
delimiter $$
create procedure sp_create_post(in p_user_id int, in p_content text)
begin
    if trim(p_content) = '' or p_content is null then
        signal sqlstate '45000' set message_text = 'Content không được rỗng';
    end if;
    insert into posts (user_id, content) values (p_user_id, p_content);
end $$
delimiter ;

delimiter $$
create trigger trg_after_insert_post
    after insert on posts
    for each row
begin
    insert into post_log (post_id, action) values (new.post_id, 'Created');
end $$
delimiter ;

-- Bài 3: Thích bài viết
delimiter $$
create trigger trg_after_insert_like
    after insert on likes
    for each row
begin
    update posts set like_count = like_count + 1 where post_id = new.post_id;
    insert into like_log (user_id, post_id, action) values (new.user_id, new.post_id, 'Liked');
end $$
delimiter ;

delimiter $$
create trigger trg_after_delete_like
    after delete on likes
    for each row
begin
    update posts set like_count = like_count - 1 where post_id = old.post_id;
    insert into like_log (user_id, post_id, action) values (old.user_id, old.post_id, 'Unliked');
end $$
delimiter ;

delimiter $$
create trigger trg_before_insert_like
    before insert on likes
    for each row
begin
    declare post_owner_id int;
    select user_id into post_owner_id from posts where post_id = new.post_id;
    if new.user_id = post_owner_id then
        signal sqlstate '45000' set message_text = 'Ko thể like post của chính mình!!';
    end if;
end $$
delimiter ;

-- Bài 4: Gửi lời mời kết bạn
delimiter $$
create procedure sp_send_friend_request(in p_sender_id int, in p_receiver_id int)
begin
    if p_sender_id = p_receiver_id then
        signal sqlstate '45000' set message_text = 'Ko thể gửi lời mời cho chính mình';
    end if;

    if exists (select 1 from friends where user_id = p_sender_id and friend_id = p_receiver_id) then
        signal sqlstate '45000' set message_text = 'Lời mời đã tồn tại';
    end if;

    insert into friends (user_id, friend_id) values (p_sender_id, p_receiver_id);
end $$
delimiter ;

delimiter $$
create trigger trg_after_insert_friend
    after insert on friends
    for each row
begin
    insert into friend_log (user_id, friend_id, action) values (new.user_id, new.friend_id, 'Sent request');
end $$
delimiter ;

-- Bài 5: Chấp nhận lời mời kết bạn
delimiter $$
create trigger trg_after_update_friend
    after update on friends
    for each row
begin
    if new.status = 'accepted' and old.status = 'pending' then
        insert ignore into friends (user_id, friend_id, status)
        values (new.friend_id, new.user_id, 'accepted');

        insert into friend_log (user_id, friend_id, action)
        values (new.user_id, new.friend_id, 'accepted');
    end if;
end $$
delimiter ;

-- Bài 6: Quản lý mối quan hệ bạn bè (cập nhật/xóa với transaction)
delimiter $$
create procedure sp_delete_friendship(in p_user_id int, in p_friend_id int)
begin
    declare exit handler for sqlexception rollback;

    start transaction;
    delete from friends
    where (user_id = p_user_id and friend_id = p_friend_id)
       or (user_id = p_friend_id and friend_id = p_user_id);

    insert into friend_log (user_id, friend_id, action)
    values (p_user_id, p_friend_id, 'deleted');

    commit;
end $$
delimiter ;

-- Bài 7: quản lý xóa bài viết
delimiter $$
create procedure sp_delete_post(in p_post_id int, in p_user_id int)
begin
    declare post_owner int;
    declare exit handler for sqlexception rollback;

    start transaction;

    select user_id into post_owner
    from posts
    where post_id = p_post_id;

    if post_owner != p_user_id then
        signal sqlstate '45000' set message_text = 'Chỉ chủ bài viết mới được xóa';
    end if;

    delete from posts where post_id = p_post_id;

    insert into post_log (post_id, action) values (p_post_id, 'deleted');

    commit;
end $$
delimiter ;

-- Bài 8: Quản lý xóa tài khoản người dùng
delimiter $$
create procedure sp_delete_user(in p_user_id int)
begin
    declare exit handler for sqlexception rollback;

    start transaction;

    delete from users where user_id = p_user_id;

    insert into user_log (user_id, action) values (p_user_id, 'deleted');

    commit;
end $$
delimiter ;
