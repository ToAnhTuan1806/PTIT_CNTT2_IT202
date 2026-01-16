/*
 * DATABASE SETUP - SESSION 15 EXAM
 * Database: StudentManagement
 */

DROP DATABASE IF EXISTS StudentManagement;
CREATE DATABASE StudentManagement;
USE StudentManagement;

-- =============================================
-- 1. TABLE STRUCTURE
-- =============================================

-- Table: Students
CREATE TABLE Students (
    StudentID CHAR(5) PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    TotalDebt DECIMAL(10,2) DEFAULT 0
);

-- Table: Subjects
CREATE TABLE Subjects (
    SubjectID CHAR(5) PRIMARY KEY,
    SubjectName VARCHAR(50) NOT NULL,
    Credits INT CHECK (Credits > 0)
);

-- Table: Grades
CREATE TABLE Grades (
    StudentID CHAR(5),
    SubjectID CHAR(5),
    Score DECIMAL(4,2) CHECK (Score BETWEEN 0 AND 10),
    PRIMARY KEY (StudentID, SubjectID),
    CONSTRAINT FK_Grades_Students FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    CONSTRAINT FK_Grades_Subjects FOREIGN KEY (SubjectID) REFERENCES Subjects(SubjectID)
);

-- Table: GradeLog
CREATE TABLE GradeLog (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID CHAR(5),
    OldScore DECIMAL(4,2),
    NewScore DECIMAL(4,2),
    ChangeDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 2. SEED DATA
-- =============================================

-- Insert Students
INSERT INTO Students (StudentID, FullName, TotalDebt) VALUES 
('SV01', 'Ho Khanh Linh', 5000000),
('SV03', 'Tran Thi Khanh Huyen', 0);

-- Insert Subjects
INSERT INTO Subjects (SubjectID, SubjectName, Credits) VALUES 
('SB01', 'Co so du lieu', 3),
('SB02', 'Lap trinh Java', 4),
('SB03', 'Lap trinh C', 3);

-- Insert Grades
INSERT INTO Grades (StudentID, SubjectID, Score) VALUES 
('SV01', 'SB01', 8.5), -- Passed
('SV03', 'SB02', 3.0); -- Failed

-- End of File

-- cau 1: trigger tg_CheckScore (before insert)
delimiter $$
create trigger tg_CheckScore
before insert on grades
for each row
begin
    if new.score < 0 then
        set new.score = 0;
    elseif new.score > 10 then
        set new.score = 10;
    end if;
end $$

delimiter ;
-- score<0
insert into grades(studentid, subjectid, score)
values ('SV01', 'SB02', -5);
select * from grades
where studentid = 'SV01' and subjectid = 'SB02';
-- score>10
insert into grades(studentid, subjectid, score)
values ('SV03', 'SB01', 15);
select * from grades
where studentid = 'SV03' and subjectid = 'SB01';


-- cau 2: transaction them sinh vien sv02
start transaction;
insert into Students(studentid, fullname)
values ('SV02', 'Ha Bich Ngoc');

update Students
set totaldebt = 5000000
where studentid = 'SV02';

commit;

select * from students where studentid = 'SV02';


-- cau 3: trigger tg_LogGradeUpdate (after update)
delimiter $$
create trigger tg_LogGradeUpdate
after update on Grades
for each row
begin
    if old.score <> new.score then
        insert into gradelog(studentid, oldscore, newscore, changedate)
        values (new.studentid, old.score, new.score, now());
    end if;
end $$

delimiter ;
update grades set score = 2.5
where studentid = 'SV03' and subjectid = 'SB02';
select * from gradelog;


-- cau 4: procedure sp_PayTuition dong hoc phi cho sv01: 2,000,000
delimiter $$
create procedure sp_PayTuition()
begin
    declare v_totaldebt decimal(10,2);

    start transaction;

    update Students set totaldebt = totaldebt - 2000000
    where studentid = 'SV01';

    select totaldebt into v_totaldebt
    from Students
    where studentid= 'SV01'
    for update;

    if v_totaldebt < 0 then
        rollback;
    else
        commit;
    end if;
end $$

delimiter ;
call sp_PayTuition();
select studentid, totaldebt from students
where studentid = 'SV01';


-- cau 5: trigger tg_PreventPassUpdate da qua mon thi cam sua diem

delimiter $$
create trigger tg_PreventPassUpdate
before update on Grades
for each row
begin
    if old.score >= 4.0 then
        signal sqlstate '45000' set message_text = 'sinh vien da qua mon nen khong duoc sua diem';
    end if;
end $$

delimiter ;
update grades
set score = 9.0
where studentid = 'SV01' and subjectid = 'SB01';


-- cau 6: procedure sp_DeleteStudentGrade
delimiter $$
create procedure sp_DeleteStudentGrade( in p_StudentID char(5), in p_SubjectID char(5))
begin
    declare v_score decimal(4,2);
    start transaction;

    select score into v_score
    from Grades
    where studentid = p_StudentID and subjectid = p_SubjectID
    for update;

    if v_score is null then
        rollback;
    else
        insert into gradelog(studentid, oldscore, newscore, changedate)
        values (p_StudentID, v_score, null, now());

        delete from Grades
        where studentid = p_StudentID and subjectid = p_SubjectID;

        if row_count() = 0 then
            rollback;
        else
            commit;
        end if;
    end if;
end $$

delimiter ;
call sp_DeleteStudentGrade('SV03', 'SB02');
select * from grades
where studentid = 'SV03' and subjectid = 'SB02';

select * from gradelog;

