-- COMP9311 19s1 Project 1 Check
--
-- MyMyUNSW Check

create or replace function
	proj1_table_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='r';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_view_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='v';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_function_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_proc
	where proname=tname;
	return (_check > 0);
end;
$$ language plpgsql;

-- proj1_check_result:
-- * determines appropriate message, based on count of
--   excess and missing tuples in user output vs expected output

create or replace function
	proj1_check_result(nexcess integer, nmissing integer) returns text
as $$
begin
	if (nexcess = 0 and nmissing = 0) then
		return 'correct';
	elsif (nexcess > 0 and nmissing = 0) then
		return 'too many result tuples';
	elsif (nexcess = 0 and nmissing > 0) then
		return 'missing result tuples';
	elsif (nexcess > 0 and nmissing > 0) then
		return 'incorrect result tuples';
	end if;
end;
$$ language plpgsql;

-- proj1_check:
-- * compares output of user view/function against expected output
-- * returns string (text message) containing analysis of results

create or replace function
	proj1_check(_type text, _name text, _res text, _query text) returns text
as $$
declare
	nexcess integer;
	nmissing integer;
	excessQ text;
	missingQ text;
begin
	if (_type = 'view' and not proj1_view_exists(_name)) then
		return 'No '||_name||' view; did it load correctly?';
	elsif (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (not proj1_table_exists(_res)) then
		return _res||': No expected results!';
	else
		excessQ := 'select count(*) '||
			   'from (('||_query||') except '||
			   '(select * from '||_res||')) as X';
		-- raise notice 'Q: %',excessQ;
		execute excessQ into nexcess;
		missingQ := 'select count(*) '||
			    'from ((select * from '||_res||') '||
			    'except ('||_query||')) as X';
		-- raise notice 'Q: %',missingQ;
		execute missingQ into nmissing;
		return proj1_check_result(nexcess,nmissing);
	end if;
	return '???';
end;
$$ language plpgsql;

-- proj1_rescheck:
-- * compares output of user function against expected result
-- * returns string (text message) containing analysis of results

create or replace function
	proj1_rescheck(_type text, _name text, _res text, _query text) returns text
as $$
declare
	_sql text;
	_chk boolean;
begin
	if (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (_res is null) then
		_sql := 'select ('||_query||') is null';
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	else
		_sql := 'select ('||_query||') = '||quote_literal(_res);
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	end if;
	if (_chk) then
		return 'correct';
	else
		return 'incorrect result';
	end if;
end;
$$ language plpgsql;

-- check_all:
-- * run all of the checks and return a table of results

drop type if exists TestingResult cascade;
create type TestingResult as (test text, result text);

create or replace function
	check_all() returns setof TestingResult
as $$
declare
	i int;
	testQ text;
	result text;
	out TestingResult;
	tests text[] := array['q1', 'q2', 'q3', 'q4', 'q5','q6','q7','q8','q9','q10','q11','q12'];
begin
	for i in array_lower(tests,1) .. array_upper(tests,1)
	loop
		testQ := 'select check_'||tests[i]||'()';
		execute testQ into result;
		out := (tests[i],result);
		return next out;
	end loop;
	return;
end;
$$ language plpgsql;


--
-- Check functions for specific test-cases in Project 1
--

create or replace function check_q1() returns text
as $chk$
select proj1_check('view','q1','q1_expected',
                   $$select * from q1$$)
$chk$ language sql;

create or replace function check_q2() returns text
as $chk$
select proj1_check('view','q2','q2_expected',
                   $$select * from q2$$)
$chk$ language sql;

create or replace function check_q3() returns text
as $chk$
select proj1_check('view','q3','q3_expected',
                   $$select * from q3$$)
$chk$ language sql;

create or replace function check_q4() returns text
as $chk$
select proj1_check('view','q4','q4_expected',
                   $$select * from q4$$)
$chk$ language sql;

create or replace function check_q5() returns text
as $chk$
select proj1_check('view','q5','q5_expected',
                   $$select * from q5$$)
$chk$ language sql;

create or replace function check_q6() returns text
as $chk$
select proj1_check('view','q6','q6_expected',
                   $$select * from q6$$)
$chk$ language sql;

create or replace function check_q7() returns text
as $chk$
select proj1_check('view','q7','q7_expected',
                   $$select * from q7$$)
$chk$ language sql;

create or replace function check_q8() returns text
as $chk$
select proj1_check('view','q8','q8_expected',
                   $$select * from q8$$)
$chk$ language sql;

create or replace function check_q9() returns text
as $chk$
select proj1_check('view','q9','q9_expected',
                   $$select * from q9$$)
$chk$ language sql;

create or replace function check_q10() returns text
as $chk$
select proj1_check('view','q10','q10_expected',
                   $$select * from q10$$)
$chk$ language sql;

create or replace function check_q11() returns text
as $chk$
select proj1_check('view','q11','q11_expected',
                   $$select * from q11$$)
$chk$ language sql;

create or replace function check_q12() returns text
as $chk$
select proj1_check('view','q12','q12_expected',
                   $$select * from q12$$)
$chk$ language sql;


drop table if exists q1_expected;
create table q1_expected (
   courseid integer,
   code char(8)
);

drop table if exists q2_expected;
create table q2_expected (
	unswid ShortString,
	name LongName,
	num bigint
);

drop table if exists q3_expected;
create table q3_expected (
	classid integer,
	course integer,
	room integer
);

drop table if exists q4_expected;
create table q4_expected (
	unswid integer,
	name longname
);

drop table if exists q5_expected;
create table q5_expected (
  num_student bigint
);

drop table if exists q6_expected;
create table q6_expected (
  semester longname,
  max_num_student bigint
);

drop table if exists q7_expected;
create table q7_expected (
  course integer,
  avgmark numeric(4,2),
  semester shortname
);

drop table if exists q8_expected;
create table q8_expected (
  num bigint
);

drop table if exists q9_expected;
create table q9_expected (
	unswid integer,
    name longname
);

drop table if exists q10_expected;
create table q10_expected (
    unswid ShortString,
    longname longname,
    num integer,
    rank integer
);

drop table if exists q11_expected;
create table q11_expected (
	unswid integer,
    name longname
);

drop table if exists q12_expected;
create table q12_expected (
	unswid integer,
    name longname,
    program longname,
    academic_standing text
);



COPY q1_expected (courseid, code) FROM stdin;
23913	LAWS2214
34511	LAWS1052
41502	LAWS1052
41529	LAWS2213
44852	LAWS2214
48629	LAWS1052
48636	LAWS1213
51943	LAWS1214
55620	LAWS1052
55627	LAWS1213
58892	LAWS3351
62556	LAWS1052
65966	LAWS8271
69489	LAWS1052
69554	LAWS3350
69555	LAWS3352
69615	LAWS8271
72777	LAWS3351
\.
-- ( )+\|+( )+
COPY q2_expected (unswid, name, num) FROM stdin;
02	Building 02	25
03	Building 03	27
05	Building 05	16
15	Building 15	198
16	Building 16	13
17	Building 17	3
1OC	Building 1OC	363
20	Building 20	210
21	Building 21	102
22	Building 22	6
22H9	Building 22H9	10
26	Building 26	337
27	Building 27	4
28	Building 28	12
29	Building 29	37
30	Building 30	843
32	Building 32	1458
36	Building 36	15
AGSM	Australian Graduate School of Management	98
AS24	Building AS24	59
ASB	Australian School of Business	2624
B	Building B	370
B11A	Building B11A	11
B11B	Building B11B	63
B9	Building B9	77
BIO	Biological Sciences Building	276
BIOMTH	Biomedical Theatres	3814
BURROWSTH	Keith Burrows Theatre	1220
C	Building C	1349
C11	Building C11	5
CHEMSC	Chemical Sciences Building	1933
CIVENG	Civil Engineering Building	2186
CLANCY	Clancy Auditorium	518
CLB	Central Lecture Block	5875
D	Building D	210
D10	Building D10	228
D23	Mathews Theatres	3233
E	Building E	1435
E9	Building E9	1
EE	Electrical Engineering Building	3056
F	Building F	4141
F13	Science Theatre	355
F17	Rex Vowels Theatre	122
F9	Building F9	8
G	Building G	994
G15	Webster Theatres	115
G7	Building G7	13
GOLDST	Goldstein College	787
H6	Tyree Energy Technologies Building	314
IOMYERS	IO Myers Studio	18
JG	John Goodsell Building	301
K14	Physics Theatre	181
K17	Computer Science Building	43
L5	223 Anzac Parade	12
LAW	Law Building	6672
LIB2	Library Stage 2	1485
MAT	Mathews Building	2739
MATS	Materials Science Building	672
MB	Morven Brown Building	1751
MECH	Mechanical Engineering Building	1767
METL	Metallurgy Process Building	6
NEWT	Newton Building	100
OMB	Old Main Building	4862
PRT	Building PRT	24
QUAD	Quadrangle	2269
RC	Red Centre	3103
RUP	Rupert Myers Building	728
SAM	Samuels Building	624
SCIN	John Niland Scientia	386
SQH	Squarehouse	309
VALL	Vallentine Annexe	229
W	Building W	136
WEB	Robert Webster Building	3219
WURTH	Wallace Wurth Building	194
\.

COPY q3_expected (classid, course, room) FROM stdin;
115116	54662	448
115117	54662	448
115118	54662	448
115119	54662	448
115120	54662	448
115121	54662	448
115122	54662	448
115123	54662	448
115132	54662	546
115134	54662	644
115135	54662	644
115138	54662	658
118734	55833	448
118737	55833	880
118741	55833	546
118744	55833	639
118823	55833	699
120103	56311	880
120104	56311	880
120105	56311	880
120106	56311	880
120107	56311	880
120108	56311	880
120109	56311	880
120110	56311	880
120111	56311	880
120112	56311	880
120113	56311	880
120114	56311	880
120115	56311	880
120116	56311	880
120117	56311	880
120118	56311	880
120119	56311	880
120120	56311	880
120121	56311	880
120122	56311	880
120123	56311	880
120124	56311	880
120125	56311	880
120126	56311	880
120127	56311	880
120128	56311	880
120129	56311	880
129004	59689	877
129006	59689	877
129007	59689	877
129008	59689	877
129012	59689	581
129013	59689	587
129014	59689	592
129015	59689	592
129016	59689	581
129017	59689	592
129018	59689	592
129019	59689	581
129020	59689	586
129021	59689	592
129022	59689	592
129023	59689	592
129024	59689	587
129025	59689	581
129026	59689	592
129027	59689	592
129028	59689	592
129029	59689	587
129030	59689	592
129031	59689	582
129032	59689	593
129033	59689	592
129034	59689	586
129035	59689	593
129036	59689	586
129037	59689	594
129038	59689	593
129039	59689	581
129040	59689	586
129041	59689	581
129042	59689	592
129043	59689	592
129044	59689	592
129045	59689	592
129046	59689	593
129047	59689	586
138714	63258	877
138715	63258	448
138716	63258	448
149188	67265	694
149191	67266	696
150388	67738	547
150389	67738	547
150390	67738	547
150391	67738	547
150392	67738	547
150393	67738	547
150394	67738	547
\.

COPY q4_expected (unswid, name) FROM stdin;
3274254	Lynn Lee
3343195	Phoebe Mallik
\.


COPY q5_expected (num_student) FROM stdin;
16206
\.

COPY q6_expected (semester,max_num_student) FROM stdin;
Summer Semester 2005	15
\.

COPY q7_expected (course,avgmark,semester) FROM stdin;
39904	83.05	Summ 2009
39906	80.30	Summ 2009
41174	82.50	Sem1 2009
41177	81.35	Sem1 2009
46387	84.33	Sem2 2009
46407	81.26	Sem2 2009
47194	83.06	Sem1 2010
48267	84.05	Sem1 2010
49073	80.30	Sem1 2010
49393	86.14	Sem1 2010
49721	80.15	Sem1 2010
49722	80.39	Sem1 2010
50015	81.24	Sem1 2010
50231	84.97	Sem1 2010
51157	80.13	Sem2 2010
51534	80.03	Sem2 2010
52146	80.26	Sem2 2010
52686	85.74	Sem2 2010
\.

COPY q8_expected (num) FROM stdin;
111
\.


COPY q9_expected (unswid, name) FROM stdin;
3260955	Myall Kozelj
3232407	Aliz Balogh
3354047	Jacqueline Pring
3329420	Amanda Hollis
3349178	Eric Chik
3199879	Nonna Ballantyne
3269260	Einat Rosenberg
3380439	Seoh Ho
3201219	Jolly Duorina
3234675	Tomas Beer
3356955	Karen Kerr
3278144	Robert McElroy
\.

COPY q10_expected (unswid,longname,num,rank) FROM stdin;
K-J14-G5	Keith Burrows Theatre	63	1
K-E19-104	Central Lecture Block Theatre 7	52	2
K-M15-G90	Myers Thtr	45	3
K-D23-201	MathewsThA	43	4
K-E19-103	Central Lecture Block Theatre 6	41	5
K-F8-G23	Law Theatre	39	6
K-F8-G02	Law Th G02	38	7
K-D23-304	MathewsThD	37	8
K-E27-B	Biomedical Lecture Theatre B	32	9
K-D23-303	MathewsThC	31	10
K-G17-G25	Electrical Engineering G25	30	11
K-E27-D	Biomedical Lecture Theatre D	29	12
K-G17-G24	Electrical Engineering G24	27	13
K-E15-1027	Macauley Theatre	27	13
K-E27-C	Biomedical Lecture Theatre C	26	15
K-E27-F	Biomedical Lecture Theatre F	26	15
K-E19-105	Central Lecture Block Theatre 8	25	17
K-D23-203	MathewsThB	24	18
K-F8-G04	Law Th G04	23	19
Z-32-LT07	LecThN07	23	19
K-E27-A	Biomedical Lecture Theatre A	23	19
K-E27-E	Biomedical Lecture Theatre E	18	22
Z-32-LT10	LecThN10	16	23
K-F23-303	Matthews Theatre C	16	23
K-F13-G09	Science Th	13	25
K-C24-G17	Sir John Clancy Auditorium	10	26
Z-32-LT05	LecThN05	4	27
Z-F9-THTR	ATSOCTh	0	28
K-E19-G4	Central Lecture Block Theatre 3	0	28
K-G17-LG1	Rex Vowels Theatre	0	28
K-G14-B	Webster Theatre B	0	28
K-E19-G5	Central Lecture Block Theatre 4	0	28
K-F10-L1	Chemical Sciences Theatre	0	28
K-F23-203	Matthews Theatre B	0	28
Z-30-LT05	LecThS05	0	28
K-E19-G2	Central Lecture Block Theatre 1	0	28
K-G14-A	Webster Theatre A	0	28
K-E19-G3	Central Lecture Block Theatre 2	0	28
K-G19-RT	Ritchie Th	0	28
Z-32-LT04	LecThN04	0	28
K-G15-190	Webst ThA	0	28
Z-30-LT04	LecThS04	0	28
K-M15-1001	Myers Thtr	0	28
K-K14-19	PhysicsTh	0	28
K-F23-304	Matthews Theatre D	0	28
Z-03-MTH	MilitaryTh	0	28
K-E12-229	MellorTh	0	28
K-D9-THTR	IoMyers Th	0	28
K-F23-201	Matthews Theatre A	0	28
K-E19-G6	Central Lecture Block Theatre 5	0	28
K-E12-127	New South Global Theatre	0	28
K-E12-125	SmithTh	0	28
K-G15-290	Webst ThB	0	28
K-E12-227	NyholmTh	0	28
\.

COPY q11_expected (unswid, name) FROM stdin;
3230042	Fiona Ogden
3232152	Cosimo Mottey
\.

COPY q12_expected (unswid, name, program, academic_standing) FROM stdin;
3290456	Tavous Beaumont	Food Science and Technology	Good
3290813	Jamie Olsson	Food Science and Technology	Exclusion
3291190	Milan Lopsik	Food Science and Technology	Probation
3291318	Tianwu Lin Yang	Safety, Health and Environment	Good
3292316	Rebecca Oparil	Science	Good
3293147	Jennifer Edwards	Food Science and Technology	Good
3293977	Adrianna Lederman	Food Science and Technology	Good
3294565	Ngoc Than	Science	Good
3295190	Timothy Heitmann	Food Science and Technology	Good
3297079	Joan Slaviero	Food Science and Technology	Good
3298284	Tracey Lyddy-Meaney	Food Science and Technology	Good
3299037	Sharon Wunnacharoensri	Food Science and Technology	Good
3299496	Rosalind Zurstrassen	Food Science and Technology	Probation
\.
