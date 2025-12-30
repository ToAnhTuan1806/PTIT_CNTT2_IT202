create database miniproject;
use miniproject;

create table Student(
	student_id varchar(20) primary key,
    full_name varchar(50) not null,
    date_of_birth date not null,
    email varchar(30) not null unique
);

create table Teacher(
	teacher_id varchar(20) primary key,
    full_name varchar(50) not null,
    email varchar(30) not null unique
);
create table Course(
	course_id varchar(20) primary key,
    course_name varchar(50) not null,
    description text,
    total_sessions int not null check(total_sessions>0),
    
    teacher_id varchar(20) not null,
    foreign key (teacher_id) references Teacher(teacher_id)
);

create table Enrollment(
	student_id varchar(20) not null,
    course_id varchar(20) not null,
    enroll_date date not null,
    
    primary key(student_id, course_id),
    foreign key (student_id) references Student(student_id),
    foreign key (course_id) references Course(course_id)
);

create table Score(
	student_id varchar(20),
    course_id varchar(20),
    mid_score decimal(4,2) check (mid_score between 0 and 10),
    final_score decimal(4,2) check (final_score between 0 and 10),

    primary key (student_id, course_id),
    foreign key (student_id) references student(student_id),
    foreign key (course_id) references course(course_id)
);

-- phan 2 nhap du lieu ban dau
insert into student values
    ('sv21', 'nguyễn hoàng long', '2003-04-15', 'longnh@gmail.com'),
    ('sv22', 'trần thị ngọc',    '2002-09-10', 'ngoc@gmail.com'),
    ('sv23', 'lê minh khôi',     '2003-02-22', 'khoi@gmail.com'),
    ('sv24', 'phạm thu hà',      '2002-12-01', 'ha@gmail.com'),
    ('sv25', 'vũ quốc khánh',    '2003-08-19', 'khanh@gmail.com');

insert into teacher values
    ('gv21', 'nguyễn văn hùng',  'hung@gmail.com'),
    ('gv22', 'trần thị tuyết',   'tuyet@gmail.com'),
    ('gv23', 'đỗ minh nhật',     'nhat@gmail.com'),
    ('gv24', 'lê hoàng anh',     'anh@gmail.com'),
    ('gv25', 'phạm quốc cường',  'cuong@gmail.com');

insert into course values
    ('c21', 'nhập môn tin học',        'kiến thức tin học cơ bản', 24, 'gv21'),
    ('c22', 'lập trình C',             'ngôn ngữ lập trình C',     30, 'gv22'),
    ('c23', 'cơ sở dữ liệu',           'sql và quản lý dữ liệu',   36, 'gv23'),
    ('c24', 'lập trình web nâng cao',  'html css js',              28, 'gv24'),
    ('c25', 'python cho data',         'python phân tích dữ liệu', 32, 'gv25');

insert into enrollment values
    ('sv21', 'c21', '2025-03-01'),
    ('sv21', 'c22', '2025-03-03'),
    ('sv22', 'c21', '2025-03-05'),
    ('sv23', 'c23', '2025-03-06'),
    ('sv24', 'c24', '2025-03-07');

insert into score values
    ('sv21', 'c21', 7.5, 8.0),
    ('sv21', 'c22', 6.8, 7.2),
    ('sv22', 'c21', 7.0, 7.5),
    ('sv23', 'c23', 8.8, 9.2),
    ('sv24', 'c24', 6.9, 7.4);
    
-- phan 3: cap nhat du lieu
update Student set email = 'longhoang123@gmail.com' where student_id = 'sv21';

update Course set description = 'html css js & frontend react' where course_id = 'c24';

update Score set final_score = 8.1 where student_id = 'sv24' and course_id = 'c24';

-- phan 4: xoa du lieu
delete from Enrollment where student_id = 'sv22' and course_id = 'c22';

delete from Score where student_id = 'sv22' and course_id = 'c22';

-- phan 5: truy van du lieu
select * from Student;
select * from Teacher;
select * from Course;
select * from Enrollment;
select * from Score;