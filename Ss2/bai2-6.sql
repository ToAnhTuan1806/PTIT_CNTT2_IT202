create database student_subject;
use student_subject;

-- bang sinh vien  
create table Student(
	student_id int primary key auto_increment,
    full_name varchar(50) not null
);

-- bang mon hoc
create table Subject(
	subject_id int primary key auto_increment,
    subject_name varchar(50) not null,
    credits int not null check (credits>0)
);

-- bang trung gian dang ki mon hoc
create table Enrollment(
	student_id int not null,
    subject_id int not null,
    register_date date not null,
    primary key (student_id, subject_id),
    foreign key (student_id) references Student(student_id),
    foreign key (subject_id) references Subject(subject_id)
);
-- bang giangr vien
create table Teacher(
	teacher_id int primary key auto_increment,
    full_name varchar(50) not null,
    email varchar(50) not null unique
);

-- cap nhat bang mon hoc de lien ket voi giang vien
alter table Subject
add column teacher_id int not null;

alter table Subject
add constraint fk_subject_teacher
foreign key (teacher_id) references Teacher(teacher_id);

-- bang ket qua hoc tap 
create table Score(
	student_id int not null,
    subject_id int not null,
    process_score decimal(4, 2) not null, check(process_score between 0 and 10),
    final_score decimal(4, 2) not null, check(final_score between 0 and 10),
    
    primary key(student_id, subject_id),
    foreign key (student_id) references Student(student_id),
    foreign key (subject_id) references Subject(subject_id)
);

