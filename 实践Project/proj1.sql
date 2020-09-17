-- comp9311 19T3 Project 1
--
-- MyMyUNSW Solutions

-- Q1:
create or replace view Q1(courseid, code)
as
select distinct courses.id as courseid, subjects.code as code 
from courses, subjects, course_staff, staff_roles
where courses.subject = subjects.id 
and subjects.code like 'LAWS%' 
and courses.id = course_staff.course
and course_staff.role = staff_roles.id
and staff_roles.name = 'Course Tutor'
;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Q2:
create or replace view Q2_1(room,lec_num)
as
select classes.room, count(classes.ctype)
from classes, class_types
where classes.ctype = class_types.id
and class_types.name = 'Lecture'
group by classes.room;
-- how many lecture in each room

create or replace view Q2_2(room,lec_num,building)
as
select q2_1.room, q2_1.lec_num, rooms.building
from q2_1, rooms
where q2_1.room = rooms.id;
--information of buildings and rooms

create or replace view Q2_3(building,lec_num)
as
select q2_2.building, sum(q2_2.lec_num)
from q2_2
group by q2_2.building;
--how many lecture in each building

create or replace view Q2(unswid,name,class_num)
as
--... SQL statements, possibly using other views/functions defined by you ...
select Buildings.unswid, Buildings.name, q2_3.lec_num as class_num
from buildings, q2_3
where buildings.id = q2_3.building
;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Q3:
create or replace view Q3_1(student, course, classes_id, room)
as 
select course_enrolments.student, course_enrolments.course, classes.id, classes.room
from classes, course_enrolments, people
where classes.course = course_enrolments.course 
and course_enrolments.student = people.id
and people.name = 'Craig Conlon';

create or replace view Q3_2(room, facility)
as 
select room_facilities.room, room_facilities.facility from room_facilities, facilities
where room_facilities.facility = facilities.id
and facilities.description = 'Television monitor';

create or replace view Q3(classid, course, room)
as 
--... SQL statements, possibly using other views/functions defined by you ...
select Q3_1.classes_id as classid, Q3_1.course, Q3_1.room
from Q3_1, Q3_2
where Q3_1.room = Q3_2.room
;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Q4:
create or replace view s9311(student, course, grade)
as
select course_enrolments.student, course_enrolments.course, course_enrolments.grade
from course_enrolments, courses, subjects
where course_enrolments.course = courses.id 
and courses.subject = subjects.id
and subjects.code ='COMP9311'
and course_enrolments.grade = 'CR';
--students who enrolled COMP9311

create or replace view s9021(student, course, grade)
as
select course_enrolments.student, course_enrolments.course, course_enrolments.grade
from course_enrolments, courses, subjects
where course_enrolments.course = courses.id 
and courses.subject = subjects.id
and subjects.code ='COMP9021'
and course_enrolments.grade = 'CR';
--students who enrolled COMP9021

create or replace view sall(student)
as
select s9311.student from s9311
intersect
select s9021.student from s9021;
--student who enrolled COMP9311 and COMP9021

create or replace view Q4(unswid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
select people.unswid, people.name
from people, students, sall
where people.id = sall.student
and people.id = students.id 
and students.stype = 'local';
--local student id
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
--Q5:
create or replace view Q5_1(student, savg)
as
select Course_enrolments.student, avg(Course_enrolments.mark) 
from Course_enrolments 
where Course_enrolments.mark is not null 
group by Course_enrolments.student;

create or replace view Q5_2(alavg)
as
select avg(Q5_1.savg) from Q5_1;

create or replace view Q5(num_student)
as
--... SQL statements, possibly using other views/functions defined by you ...
select count(distinct Q5_1.student) as num_student
from Q5_1, Q5_2
where Q5_1.savg > Q5_2.alavg;
;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Q6:
create or replace view Q6_1(course, stut_num)
as
select course_enrolments.course, count(course_enrolments.course) as stut_num
from course_enrolments
group by course_enrolments.course;
--how many students in each course

create or replace view Q6_2(course, stut_num)
as
select q6_1.course, q6_1.stut_num
from q6_1
where q6_1.stut_num>= 10;
--the course size larger than 10

create or replace view Q6_3(course, stut_num, semester)
as
select q6_2.course, q6_2.stut_num, courses.semester
from q6_2, courses
where q6_2.course = courses.id;
--information of courses and semesters

create or replace view Q6_4(stut_num, semester)
as
select max(q6_3.stut_num) as stut_num, q6_3.semester
from q6_3
group by q6_3.semester;
--maximum number of students

create or replace view Q6_5(stut_num, semester)
as
select * from q6_4 where stut_num = (select min(stut_num) from q6_4);
--minimun number of max

create or replace view Q6(semester, max_num_student)
as
--... SQL statements, possibly using other views/functions defined by you ...
select Semesters.longname as semester, q6_5.stut_num as max_num_student
from semesters, q6_5
where q6_5.semester = semesters.id
;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Q7:
create or replace view c_09(course, semester, y)
as
select courses.id, semesters.name, semesters.year
from courses, semesters
where courses.semester = semesters.id 
and semesters.year = 2009;
--courses of 2009

create or replace view c_10(course, semester, y)
as
select courses.id, semesters.name, semesters.year
from courses, semesters
where courses.semester = semesters.id 
and semesters.year = 2010;
--courses of 2010

create or replace view Q7_1(course, num_stut)
as
SELECT course_enrolments.course, COUNT(course_enrolments.course) AS num_stut
FROM course_enrolments 
where course_enrolments.mark is not null
GROUP BY course_enrolments.course;
--enrolled students of each course

create or replace view Q7_2(course, num_stut)
as
select Q7_1.course, Q7_1.num_stut
from Q7_1
where Q7_1.num_stut >= 20;
--student number >= 20

create or replace view Q7_3(course, savg)
as
select Course_enrolments.course, avg(Course_enrolments.mark)
from Course_enrolments 
where Course_enrolments.mark is not null 
group by Course_enrolments.course;
--avg of each course

create or replace view Q7_4(course, num_stut, savg)
as
select Q7_3.course, Q7_2.num_stut, Q7_3.savg
from Q7_2, Q7_3
where Q7_2.course = Q7_3.course and Q7_3.savg>80;
--student number >= 20 and avg mark >= 80

create or replace view s09(course, num_stut, savg, semester, y)
as
select Q7_4.course, Q7_4.num_stut, cast(Q7_4.savg as numeric(4,2)), c_09.semester, c_09.y as year
from Q7_4,c_09
where Q7_4.course = c_09.course;
--2009 

create or replace view s10(course, num_stut, savg, semester, y)
as
select Q7_4.course, Q7_4.num_stut, cast(Q7_4.savg as numeric(4,2)), c_10.semester, c_10.y as year
from Q7_4,c_10
where Q7_4.course = c_10.course;
--2010

create or replace view Q7(course, avgmark, semester)
as
--... SQL statements, possibly using other views/functions defined by you ...
select s09.course, s09.savg, s09.semester from s09
union
select s10.course, s10.savg, s10.semester from s10
;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Q8: 
create or replace view Q8_1(course, offeredby, semester)
as
select distinct courses.id as course, subjects.offeredby, courses.semester
from courses, subjects, OrgUnits
where subjects.id = courses.subject 
and subjects.offeredby = OrgUnits.id
and OrgUnits.name = 'Accounting';
--810 courses offered by Accounting

create or replace view Q8_2(course, offeredby, semester)
as
select courses.id as course, subjects.offeredby, courses.semester
from courses, subjects, OrgUnits
where subjects.id = courses.subject 
and subjects.offeredby = OrgUnits.id
and OrgUnits.name = 'Economics';
--1300 courses offered by Economics

create or replace view Q8_5(student)
as
select distinct course_enrolments.student
from course_enrolments, q8_1
where course_enrolments.course = q8_1.course;
--4425 students enrol accounting course

create or replace view Q8_6(student)
as
select distinct course_enrolments.student
from course_enrolments, q8_2
where course_enrolments.course = q8_2.course;
--5307 students enrol economics course

create or replace view sacct(student)
as
select students.id
from students, q8_5
where students.id = q8_5.student and students.stype = 'local';
--2726 local student enrolled acct

create or replace view secon(student)
as
select students.id
from students, q8_6
where students.id = q8_6.student and students.stype = 'local';
--3260 local student enrolled econ course in 2008

create or replace view Q8_7(part)
as
select distinct stream_enrolments.partof
from stream_enrolments, streams
where stream_enrolments.stream = streams.id and streams.name = 'Law';

create or replace view Q8_8(student, semester)
as
select program_enrolments.student, program_enrolments.semester
from program_enrolments, q8_7
where program_enrolments.id = q8_7.part order by program_enrolments.semester;

create or replace view Q8_9(student, semester)
as
select q8_8.student, q8_8.semester
from q8_8, semesters
where q8_8.semester = semesters.id and semesters.year = 2008;
--354 students enrolled law stream in 2008

create or replace view Q8_10(student)
as
select distinct q8_9.student
from q8_9, students
where q8_9.student = students.id 
and students.stype = 'local';
--162 local students enrolled law stream in 2008

create or replace view Q8_11(student)
as
select q8_10.student from q8_10
except
select sacct.student from sacct;

create or replace view Q8_12(student)
as
select q8_11.student from q8_11
except
select secon.student from secon;
--local students enrolled in law stream in 2008 but never enroll econ, acct course

create or replace view Q8(num)
as
--... SQL statements, possibly using other views/functions defined by you ...
select count(*) as num from q8_12
;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Q9:
create or replace view Q9_1(subject, term, y)
as
select subjects.id, semesters.term, semesters.year
from courses, subjects, semesters
where courses.subject = subjects.id 
and subjects.code like 'COMP9%' 
and courses.semester = semesters.id
and semesters.year between 2002 and 2013;
--comp9...subjects

create or replace view Q9_2(y)
as
select distinct semesters.year 
from semesters 
where semesters.year between 2002 and 2013 order by year;
--from 02 to 13

create or replace view Q9_3(term)
as
select distinct semesters.term from semesters where semesters.term = 'S1'
union
select distinct semesters.term from semesters where semesters.term = 'S2';
-- S1 S2

create or replace view Q9_4(subject, term)
as
select distinct r1.subject, r1.term from q9_1 r1
where not exists(
    select r3.y from q9_2 r3
    where not exists(
        select * from q9_1 r2
        where r2.subject = r1.subject and r2.term = r1.term and r2.y = r3.y
    ) 
);
-- subjects from 02 to 13

create or replace view Q9_5(subject)
as
select distinct r1.subject from q9_4 r1
where not exists( 
    select r3.term from q9_3 r3
    where not exists(
        select * from q9_4 r2
        where r2.subject = r1.subject and r2.term = r3.term 
    )
);
-- popular subjects

create or replace view Q9_6(student, subject)
as
select course_enrolments.student, courses.subject
from course_enrolments, courses, q9_5
where course_enrolments.course = courses.id
and courses.subject = q9_5.subject
and course_enrolments.mark >= 75;
-- students course and got DN or HD

create or replace view Q9_7(student)
as
select distinct r1.student from q9_6 r1
where not exists( 
    select r3.subject from q9_5 r3
    where not exists(
        select * from q9_6 r2
        where r2.student = r1.student and r2.subject = r3.subject 
    )
);

create or replace view Q9(unswid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
select People.unswid, People.name 
from people,q9_7 
where people.id =q9_7.student
;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Q10:
create or replace view Q10_1(classes, room)
as
select classes.id as classes, classes.room
from classes, courses, semesters
where classes.course = courses.id 
and courses.semester = semesters.id
and semesters.year = 2010
and semesters.term = 'S2';
--8490 classes in 2010 S2

create or replace view Q10_2(classes, room, rtype)
as
select q10_1.classes, q10_1.room, room_types.id
from q10_1, rooms, room_types
where q10_1.room = rooms.id 
and rooms.rtype = room_types.id
and room_types.description = 'Lecture Theatre';
--781 classes in lec theatre in 2010 s2

create or replace view Q10_3(room, num)
as
select q10_2.room, count(q10_2.room) as num 
from q10_2 group by q10_2.room 
order by count(q10_2.room) desc;
--count how many class in each lec theatre

create or replace view Q10_4(room, num)
as
select distinct rooms.id, 0 as num
from rooms, q10_2
where rooms.rtype = q10_2.rtype
and rooms.id not in (select q10_3.room from q10_3);

create or replace view Q10_5(room, num)
as
select * from q10_4
union
select * from q10_3;

create or replace view Q10_6(room, num, rk)
as
select q10_5.room, q10_5.num, rank() over(order by q10_5.num desc) from q10_5;
--sort the room information

create or replace view Q10(unswid, longname, num, rank)
as
--... SQL statements, possibly using other views/functions defined by you ...
select rooms.unswid, rooms.longname, q10_6.num, q10_6.rk as rank
from rooms, q10_6
where rooms.id = q10_6.room
order by q10_6.rk
;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Q11:
create or replace view Q11_1(student, semester)
as
select distinct program_enrolments.student, program_enrolments.semester
from program_enrolments, program_degrees
where program_enrolments.program = program_degrees.program 
and program_degrees.abbrev = 'BSc' 
order by program_enrolments.semester;
-- students enrolled bsc and when they enrolled

create or replace view Q11_2(student, course, mark)
as
select distinct course_enrolments.student, courses.id as course, course_enrolments.mark
from course_enrolments, courses, semesters, q11_1
where course_enrolments.student = q11_1.student
and course_enrolments.course = courses.id
and courses.semester = semesters.id
and semesters.year = 2010 and semesters.term = 'S2'
and course_enrolments.mark >= 50;
-- 2010 S2 pass

create or replace view Q11_3(student)
as
select distinct q11_2.student from q11_2;

create or replace view Q11_4(student,course,mark)
as
select q11_3.student,course_enrolments.course, course_enrolments.mark
from q11_3, course_enrolments, courses,semesters
where q11_3.student = course_enrolments.student
and course_enrolments.course = courses.id
and courses.semester = semesters.id
and course_enrolments.mark >=50
and semesters.year < 2011;

create or replace view Q11_5(student, avgmark)
as
select q11_4.student, avg(q11_4.mark) 
from q11_4 group by q11_4.student;
-- avg mark of the student

create or replace view Q11_6(student)
as
select distinct q11_5.student 
from q11_5 
where q11_5.avgmark >= 80;

create or replace view Q11_7(student)
as
select q11_6.student
from q11_6, semesters, subjects, course_enrolments, courses, programs, program_enrolments
where semesters.year < 2011
and courses.semester = semesters.id
and course_enrolments.student = q11_6.student
and course_enrolments.course = courses.id
and course_enrolments.mark >= 50
and program_enrolments.student = q11_6.student
and program_enrolments.program = programs.id
and program_enrolments.semester = semesters.id
and subjects.id = courses.subject
group by q11_6.student, programs.uoc
having sum(subjects.uoc) >= programs.uoc;

create or replace view Q11(unswid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
select people.unswid,people.name
from people, q11_7 
where people.id = q11_7.student
;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Q12:
create or replace view Q12_1(student, unswid, prog, pname)
as
select distinct program_enrolments.student, people.unswid, program_enrolments.program, programs.name
from program_enrolments, program_degrees, people, programs
where 1=1 
and cast(people.unswid as varchar(10)) like '329%' 
and program_enrolments.student = people.id
and program_degrees.abbrev = 'MSc'
and program_degrees.program = programs.id
and program_enrolments.program = program_degrees.program;
--15 329... students enrolled in MSc

create or replace view Q12_2(student, prog, mark, uoc)
as
select distinct course_enrolments.student, program_enrolments.program, course_enrolments.mark, subjects.uoc
from course_enrolments, q12_1, courses, program_enrolments, subjects, semesters
where course_enrolments.student = q12_1.student
and course_enrolments.mark >= 0
and course_enrolments.mark < 50
and courses.id = course_enrolments.course
and subjects.id = courses.subject
and semesters.id = courses.semester
and program_enrolments.semester = semesters.id
and q12_1.prog = program_enrolments.program
and program_enrolments.student = q12_1.student
;

create or replace view Q12_3(student, uoc)
as
select distinct q12_2.student, sum(q12_2.uoc)
from q12_2
group by q12_2.student;

create or replace view Q12(unswid, name, program, academic_standing)
as
--... SQL statements, possibly using other views/functions defined by you ...
select people.unswid, people.name, programs.name, 'Good' as academic 
from q12_3,people,programs,program_enrolments
where q12_3.uoc < 12 
and people.id = q12_3.student
and programs.id = program_enrolments.program
and program_enrolments.student = q12_3.student
union
select people.unswid, people.name, programs.name, 'Probation' as academic 
from q12_3,people,programs,program_enrolments
where q12_3.uoc <= 18 
and q12_3.uoc >= 12 
and people.id = q12_3.student
and programs.id = program_enrolments.program
and program_enrolments.student = q12_3.student
union
select people.unswid, people.name, programs.name, 'Exclusion' as academic 
from q12_3,people,programs,program_enrolments
where q12_3.uoc > 18 
and people.id = q12_3.student
and programs.id = program_enrolments.program
and program_enrolments.student = q12_3.student;
;
