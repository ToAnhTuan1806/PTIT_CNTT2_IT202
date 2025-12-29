create database bt_ss3;
use bt_ss3;

create table student (
    student_id int primary key,
    full_name varchar(50) not null,
    date_of_birth date,
    email varchar(50) unique
);

insert into student(student_id, full_name, date_of_birth, email)
values
(1, 'nguyen van a', '2000-02-19', 'vana@gmail.com'),
(2, 'tran thi b', '2003-07-06', 'thib@gmail.com'),
(3, 'hoang van c', '2005-06-18', 'vanc@gmail.com');

create table subject (
    subject_id int primary key,
    subject_name varchar(50) not null,
    credit int check (credit > 0)
);

insert into subject(subject_id, subject_name, credit)
values
(1, 'react', 3),
(2, 'java', 2),
(3, 'c++', 2);

create table enrollment (
    student_id int not null,
    subject_id int not null,
    enroll_date date not null,

    primary key (student_id, subject_id),
    foreign key (student_id) references student(student_id),
    foreign key (subject_id) references subject(subject_id)
);

insert into enrollment(student_id, subject_id, enroll_date)
values
(1, 1, '2025-12-29'),
(1, 2, '2025-12-29'),
(2, 2, '2025-12-29'),
(2, 3, '2025-12-29');

create table score (
    student_id int not null,
    subject_id int not null,
    mid_score decimal(4,2) not null check (mid_score between 0 and 10),
    final_score decimal(4,2) not null check (final_score between 0 and 10),

    primary key (student_id, subject_id),
    foreign key (student_id) references student(student_id),
    foreign key (subject_id) references subject(subject_id)
);

insert into score(student_id, subject_id, mid_score, final_score)
values
(1, 1, 7.50, 8.00),
(1, 2, 8.00, 7.50),
(2, 2, 6.50, 8.25),
(2, 3, 9.00, 9.50);

-- them 1 sinh vien moi
insert into student(student_id, full_name, date_of_birth, email)
values (4, 'le thi d', '2004-03-12', 'lethid@gmail.com');

-- dang ky it nhat 2 mon hoc cho sinh vien do
insert into enrollment(student_id, subject_id, enroll_date)
values
(4, 1, '2025-12-29'),
(4, 2, '2025-12-29');

-- them diem cho sinh vien vua them
insert into score(student_id, subject_id, mid_score, final_score)
values
(4, 1, 7.25, 0.00),
(4, 2, 8.00, 0.00);

-- cap nhat diem cuoi ky
update score
set final_score = 8.75
where student_id = 4 and subject_id = 2;

-- xoa 1 luot dang ky khong hop le (vi du)
delete from score
where student_id = 2 and subject_id = 3;

delete from enrollment
where student_id = 2 and subject_id = 3;

-- lay danh sach sinh vien va diem so tuong ung
select
    student_id,
    subject_id,
    mid_score,
    final_score
from score;
