use social_network_pro;

-- Bai 1:
delimiter $$
create procedure getPostsByUser (in p_user_id int)
begin 
	select post_id as PostID, content as NoiDung, created_at as ThoiGianTao
	from posts
    where user_id = p_user_id;
    
end $$

call getPostsByUser(1);
drop procedure getPostsByUser;


-- Bai 2:
delimiter $$
create procedure CalculatePostLikes (in p_post_id int, out total_likes int)
begin 
	select count(*) into total_likes
	from likes
    where post_id = p_post_id;
    
end $$

call CalculatePostLikes(101, @total_likes);
select @total_likes as total_likes;
drop procedure CalculatePostLikes;

 
-- Bai 3:
delimiter $$
create procedure CalculateBonusPoints (in p_user_id int, inout p_bonus_points  int)
begin 
	declare v_post_count int default 0;
	select count(*) into v_post_count 
	from posts
    where user_id = p_user_id;
    
    if v_post_count >=20 then 	
		set p_bonus_points = p_bonus_points+ 100;
	elseif v_post_count >=10 then
		set p_bonus_points = p_bonus_points+ 50;
    end if;
end $$

set @bonus = 100;
call CalculateBonusPoints(1, @bonus);
select @bonus as p_bonus_points;
drop procedure CalculateBonusPoints;


-- Bai 4:
delimiter $$
create procedure CreatePostWithValidation (in p_user_id int, in p_content text, out result_message varchar(255))
begin 
    if char_length(p_content) <5 then 	
		set result_message = 'Nội dung quá ngắn'; 
	else
		insert into posts(user_id, content, created_at) values
        (p_user_id, p_content, now());
		set result_message = 'Thêm bài viết thành công'; 
    end if;
end $$

-- result <5
call CreatePostWithValidation(1, 'beo', @msg);
select @msg as result_message;

-- result <5
call CreatePostWithValidation(1, 'khong beo', @msg);
select @msg as result_message;
drop procedure CreatePostWithValidation;


-- Bai 5:
delimiter $$
create procedure CalculateUserActivityScore (in p_user_id int, out activity_score int, out activity_level varchar(50))
begin 
	declare v_post_count int default 0;
    declare v_comment_count int default 0;
    declare v_like_count int default 0;
    
    -- post +10
	select count(*) into v_post_count 
	from posts
    where user_id = p_user_id;
    
	-- comment +5 (cmt cua user tao)
	select count(*) into v_comment_count 
	from comments
    where user_id = p_user_id;
    
	-- like nhan dc +3 (like tu bai viet cua user)
	select count(*) into v_like_count 
	from likes l
    join posts p on p.post_id = l.post_id
    where p.user_id = p_user_id;
    
    -- tinh tong diem
    set activity_score= v_post_count*10 + v_comment_count*5 + v_like_count*3;
	-- xac dinh level
    set activity_level= case
		when activity_score> 500 then 'Rất tích cực'
		when activity_score between 200 and 500 then 'Tích cực'
		else 'Bình thường'
	end;
end $$

call CalculateUserActivityScore(18, @score, @level);
select @score as activity_score, @level as activity_score;
drop procedure CalculateUserActivityScore;


-- Bài 6:
delimiter $$
create procedure NotifyFriendsOnNewPost (in p_user_id int, in p_content text)
begin 
    declare v_full_name varchar(255);
    
	select full_name into v_full_name
	from users
    where user_id = p_user_id;
    
	insert into posts(user_id, content, created_at) values
    (p_user_id, p_content, now());
    
	-- gui tbao chieu user_id -> friend_id
    insert into notifications(user_id, type, content, created_at)
    select f.friend_id, 'new_post', concat(v_full_name, ' đã đăng một bài viết mới'), now()
    from friends f
    where f.user_id= p_user_id and f.status = 'accepted' and f.friend_id <> p_user_id; -- (khong gui tbao cho chinh ng dang bai)
	
    -- gui tbao chieu friend_id -> user_id
    insert into notifications(user_id, type, content, created_at)
    select f.user_id, 'new_post', concat(v_full_name, ' đã đăng một bài viết mới'), now()
    from friends f
    where f.friend_id= p_user_id and f.status = 'accepted' and f.user_id <> p_user_id;
end $$

call NotifyFriendsOnNewPost(1, 'Bài viết mới hello friend');
select user_id, type, content, created_at
from notifications
where type = 'new_post'
order by created_at desc;

drop procedure NotifyFriendsOnNewPost;