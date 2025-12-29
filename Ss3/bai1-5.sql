Create database baitap_ss3;
use baitap_ss3;

create table Student(
	student_id int primary key,
    full_name varchar(50) not null,
    date_of_birth date,
    email varchar(50) unique
);

insert into Student(student_id, full_name, date_of_birth, email)
values 
(1, 'Nguyen Van A', '2000-02-19', 'vana@gmail.com'),
(2, 'Tran Thi B', '2003-07-06', 'thib@gmail.com'),
(3, 'Hoang Van C', '2005-06-18', 'vanc@gmail.com'),

(5, 'Hoang ', '2009-06-18', 'vanc78@gmail.com');

select * from Student;

select student_id, full_name from Student;

-- bai2
update Student
set email = 'hoangvanC@gmail.com'
where student_id = 3;

update Student
set date_of_birth = '2001-01-24'
where student_id = 2;

delete from Student
where student_id = 5;

select * from Student;

-- bai 3
create table Subject(
	subject_id int primary key,
    subject_name varchar(50) not null,
    credit int check (credit>0)
);

insert into Subject(subject_id, subject_name, credit)
values 
(1, 'React', 3),
(2, 'Java', 2),
(3, 'C++', 2);

update Subject
set credit = 5
where subject_id = 2;

update Subject
set subject_name = 'Frontend & React'
where subject_id = 1;

-- bai 4
create table Enrollment (
	Student_id int not null,
    Subject_id int not null,
    Enroll_date date not null,
 
	primary key (Student_id, Subject_id),
    foreign key (Student_id) references Student(student_id),
    foreign key (Subject_id) references Subject(subject_id)
);

insert into Enrollment(Student_id, Subject_id, Enroll_date)
values
(1, 1, '2025-12-29'),
(1, 2, '2025-12-29'),
(2, 2, '2025-12-29'),
(2, 3, '2025-12-29');

select * from Enrollment;

select * from Enrollment where Student_id = 2;

-- bai 5
create table Score(
	student_id int not null,
    subject_id int not null,
    mid_score decimal (4, 2) not null check(mid_score between 0 and 10),
    final_score decimal (4, 2)not null check(final_score between 0 and 10),
    
    primary key (student_id, subject_id),
    foreign key (student_id) references Student(student_id),
    foreign key (subject_id) references Subject(subject_id)
);

insert into Score(student_id, subject_id, mid_score, final_score)
values
(1, 1, 7.50, 0.00),
(1, 2, 8.00, 0.00),
(2, 2, 6.50, 8.25),
(2, 3, 9.00, 9.50);

select * from Score;

select * from Score where final_score >=8;