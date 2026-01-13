CREATE DATABASE StudentDB;
USE StudentDB;
-- 1. Bảng Khoa
CREATE TABLE Department (
    DeptID CHAR(5) PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL
);

-- 2. Bảng SinhVien
CREATE TABLE Student (
    StudentID CHAR(6) PRIMARY KEY,
    FullName VARCHAR(50),
    Gender VARCHAR(10),
    BirthDate DATE,
    DeptID CHAR(5),
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

-- 3. Bảng MonHoc
CREATE TABLE Course (
    CourseID CHAR(6) PRIMARY KEY,
    CourseName VARCHAR(50),
    Credits INT
);

-- 4. Bảng DangKy
CREATE TABLE Enrollment (
    StudentID CHAR(6),
    CourseID CHAR(6),
    Score FLOAT,
    PRIMARY KEY (StudentID, CourseID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);
INSERT INTO Department VALUES
('IT','Information Technology'),
('BA','Business Administration'),
('ACC','Accounting');

INSERT INTO Student VALUES
('S00001','Nguyen An','Male','2003-05-10','IT'),
('S00002','Tran Binh','Male','2003-06-15','IT'),
('S00003','Le Hoa','Female','2003-08-20','BA'),
('S00004','Pham Minh','Male','2002-12-12','ACC'),
('S00005','Vo Lan','Female','2003-03-01','IT'),
('S00006','Do Hung','Male','2002-11-11','BA'),
('S00007','Nguyen Mai','Female','2003-07-07','ACC'),
('S00008','Tran Phuc','Male','2003-09-09','IT');

INSERT INTO Course VALUES
('C00001','Database Systems',3),
('C00002','C Programming',3),
('C00003','Microeconomics',2),
('C00004','Financial Accounting',3);

INSERT INTO Enrollment VALUES
('S00001','C00001',8.5),
('S00001','C00002',7.0),
('S00002','C00001',6.5),
('S00003','C00003',7.5),
('S00004','C00004',8.0),
('S00005','C00001',9.0),
('S00006','C00003',6.0),
('S00007','C00004',7.0),
('S00008','C00001',5.5),
('S00008','C00002',6.5);


-- Phan A:
-- cau 1
create or replace view View_StudentBasic as 
select s.StudentID, s.FullName, d.DeptName
from Student s
join Department d on s.DeptID = d.DeptID;

select * from View_StudentBasic;

-- cau 2
create index idx_std_fullname on Student (FullName);
-- cau 3
delimiter $$
create procedure GetStudentsIT()
begin 
	select s.StudentID, s.FullName, s.Gender, s.BirthDate, d.DeptName
    from Student s
    join Department d ON s.DeptID = d.DeptID
    where d.DeptName = 'Information Technology';
    
end $$

call GetStudentsIT();

-- Phan B
-- cau 4
create or replace view View_StudentCountByDept as
select d.DeptName, count(s.StudentID) as TotalStudents
from Department d
left join Student s on s.DeptID = d.DeptID
group by d.DeptName;

select * from View_StudentCountByDept
order by TotalStudents desc limit 1;

-- cau 5
delimiter $$
create procedure GetTopScoreStudent(in p_CourseID char(6))
begin 
	select s.StudentID, s.FullName, e.Score
    from Enrollment e
    join Student s on e.StudentID = s.StudentID
    where e.CourseID= p_CourseID and e.Score = (
									select max(en.Score) 
                                    from Enrollment en
                                    where en.CourseID= p_CourseID
								);
    
end $$

call GetTopScoreStudent('C00001');
drop procedure GetTopScoreStudent;


-- Cau 6
create view View_IT_Enrollment_DB as
select e.StudentID, e.CourseID, e.Score
from Enrollment e
join Student s on e.StudentID = s.StudentID
where s.DeptID = 'it'and e.CourseID = 'c00001'
with check option;


delimiter $$
create procedure UpdateScore_IT_DB(
    in p_StudentID char(6),
    inout p_newscore float
)
begin
    if p_newscore > 10 then
        set p_NewScore = 10;
    end if;

    update view_it_enrollment_db
    set score = p_newscore
    where studentid = p_studentid;
end $$


-- goi thu tuc
set @newscore = 12;

call updatescore_it_db('s00005', @newscore);

select @newscore as newscoreafterprocedure;

select *
from view_it_enrollment_db
where studentid = 's00005';

