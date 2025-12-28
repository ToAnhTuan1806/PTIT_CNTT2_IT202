create database bai1_ss2;
use bai1_ss2;
drop table class;
create table class(
	class_id int primary key auto_increment,
    class_name varchar(100) not null,
    school_year int not null
);

create table student(
	student_id int primary key auto_increment,
    full_name varchar(30) not null,
    date_of_bith date,
    class_id int not null,
    foreign key(class_id) references class(class_id)
);
