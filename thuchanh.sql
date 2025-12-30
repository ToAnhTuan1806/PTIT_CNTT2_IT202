create database thuchanhh;
use thuchanhh;

create table Student(
	student_id int primary key,
    full_name varchar(50) not null,
    email varchar(50) not null unique,
    phone_number char(10) unique
);

create table Course(
	course_id int primary key,
    course_name varchar(50) not null,
    credits int not null check(credits>0)
);

create table Enrollment(
	student_id int not null,
    course_id int not null,
    grade decimal(4, 2) default 0,
    
    primary key (student_id, course_id),
    foreign key (student_id) references Student(student_id),
    foreign key (course_id) references Course(course_id)
);

insert into Student(student_id, full_name, email, phone_number)
values
(1, 'Nguyen Van A', 'nguyenvana@gmail.com', '0912345678'),
(2, 'Tran Thi B', 'tranthib@gmail.com', '0987654321'),
(3, 'Le Van C', 'levanc@gmail.com', '0901122334'),
(4, 'Pham Thi D', 'phamthid@gmail.com', '0933221100'),
(5, 'Hoang Van E', 'hoangvane@gmail.com', '0977886655');

insert into Course(course_id, course_name, credits)
values
(101, 'SQL', 3),
(102, 'Java', 3),
(103, 'React', 4),
(104, 'English', 2),
(105, 'C++', 3);

insert into Enrollment(student_id, course_id, grade)
values
(1, 101, 8.50),
(1, 104, 7.00),
(2, 102, 9.25),
(3, 103, 6.75),
(3, 105, 8.00),
(4, 101, 5.50),
(5, 104, 7.50),
(5, 102, 8.75);

update Enrollment set grade = 9 where student_id = 2 and course_id = 3;

select full_name, email, phone_number from Student;

delete from Course
where course_id = 101;

-- Không thể xóa khóa học 101 nếu trong bảng Enrollment vì vẫn còn sinh viên đã đăng ký khóa học này.
-- Nguyên nhân là do ràng buộc khóa ngoại (foreign key) giữa Enrollment.course_id và Course.course_id nhằm đảm bảo toàn vẹn dữ liệu.
-- Nên dùng: Dùng ON DELETE CASCADE