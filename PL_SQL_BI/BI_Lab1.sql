----1

SELECT
MAX(CASE WHEN jobno= 1006
THEN empcount
ELSE NULL END) AS presidents,
MAX(CASE WHEN jobno= 1001
THEN empcount
ELSE NULL END) AS fin_director,
MAX(CASE WHEN jobno= 1000
THEN empcount
ELSE NULL END) AS manager,
MAX(CASE WHEN jobno= 1004
THEN empcount
ELSE NULL END) AS clerk,
MAX(CASE WHEN jobno= 1005
THEN empcount
ELSE NULL END) AS driver
FROM (
SELECT jobno, COUNT(*) as empcount
FROM career WHERE ENDDATE IS NULL
GROUP BY jobno
);

-----------2

SELECT
MAX(CASE WHEN DEPTNAME= 'ACCOUNTING'
THEN EMPNAME
ELSE NULL END) AS ACCOUNTING,
MAX(CASE WHEN DEPTNAME= 'RESEARCH'
THEN EMPNAME
ELSE NULL END) AS RESEARCH,
MAX(CASE WHEN DEPTNAME= 'SALES'
THEN EMPNAME
ELSE NULL END) AS SALES,
MAX(CASE WHEN DEPTNAME= 'OPERATIONS'
THEN EMPNAME
ELSE NULL END) AS OPERATIONS
FROM (
SELECT
DEPTNAME,
EMPNAME,
ROW_NUMBER() OVER (
PARTITION BY DEPTNAME
ORDER BY EMPNAME
) rn
FROM career
JOIN DEPT USING (DEPTNO)
JOIN EMP USING (EMPNO)
)
GROUP BY rn;


--------------3
SELECT jb.jobno,
CASE jb.jobno
WHEN 1006 THEN emp_cnts.presidents
WHEN 1001 THEN emp_cnts.fin_director
WHEN 1000 THEN emp_cnts.manager
WHEN 1004 THEN emp_cnts.clerk
WHEN 1005 THEN emp_cnts.driver
END count_by_job
FROM(
SELECT
MAX(CASE WHEN jobno= 1006
THEN empcount
ELSE NULL END) AS presidents,
MAX(CASE WHEN jobno= 1001
THEN empcount
ELSE NULL END) AS fin_director,
MAX(CASE WHEN jobno= 1000
THEN empcount
ELSE NULL END) AS manager,
MAX(CASE WHEN jobno= 1004
THEN empcount
ELSE NULL END) AS clerk,
MAX(CASE WHEN jobno= 1005
THEN empcount
ELSE NULL END) AS driver
FROM (
SELECT jobno, COUNT(*) as empcount
FROM career WHERE ENDDATE IS NULL
GROUP BY jobno
)) emp_cnts, 
(select JOBNO from job WHERE JOBNO IN (1000, 1004, 1005, 1001, 1006)) jb;




---------------4
CREATE OR REPLACE VIEW emps_info AS (
SELECT empno, empname, jobname, deptno, ROUND(AVG(salvalue)) AS avg_salary
  FROM emp JOIN salary USING(empno) JOIN career USING(empno) JOIN job USING(jobno) JOIN dept USING(deptno)
WHERE enddate IS NULL
GROUP BY empno, empname, jobname, deptno);
select * FROM emps_info;

SELECT CASE rn
WHEN 1
THEN EMPNAME
WHEN 2
THEN JOBNAME
WHEN 3
THEN CAST(avg_salary AS CHAR(4))
END EMPS
FROM (
SELECT
e.empname,
e.jobname,
e.avg_salary,
ROW_NUMBER() OVER (
PARTITION BY e.EMPNO
ORDER BY e.EMPNO
) rn
FROM emps_info e,
(select * from emps_info
where ROWNUM <= 4) four_rows
WHERE e.deptno = 40
);


----------------5

SELECT DECODE(LAG(jobname) OVER(ORDER BY jobname), jobname, NULL, jobname), empname
FROM career JOIN emp USING(empno) JOIN job USING(jobno) WHERE ENDDATE IS NULL;
