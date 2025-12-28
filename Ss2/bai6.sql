create database management_system;
use management_system;

create table Class(
	class_id int primary key auto_increment,
    class_name varchar(50) not null,
    school_year int not null
);
-- bang sinh vien  
create table Student(
	student_id int primary key auto_increment,
    full_name varchar(50) not null,
    date_of_birth date,
    class_id int not null,
    foreign key (class_id) references Class(class_id)
);

-- bang giang vien
create table Teacher(
	teacher_id int primary key auto_increment,
    full_name varchar(50) not null,
    email varchar(50) not null unique
);

-- bang mon hoc
create table Subject(
	subject_id int primary key auto_increment,
    subject_name varchar(50) not null,
    credits int not null check (credits>0),
    teacher_id int not null,
    foreign key (teacher_id) references Teacher(teacher_id)
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

