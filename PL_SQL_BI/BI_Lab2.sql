select 
empname, 
deptname, 
jobname, 
count(emp.empno) over (partition by dept.deptno) DEPTNAME_EMP_CNT, 
count(emp.empno) over (partition by job.jobno) JOBNAME_EMP_CNT, 
count(emp.empno) over (partition by null) TOTAL
from career inner join dept on career.deptno=dept.deptno inner join emp on emp.empno=career.empno inner join job on job.jobno=career.jobno;

select 
startdate, 
salvalue, 
sum(salvalue) OVER (ORDER BY startdate RANGE BETWEEN 90 PRECEDING AND CURRENT ROW) summary_salary
from salary inner join career on salary.empno=career.empno
order by startdate;

SELECT jobname, count(career.empno), RATIO_TO_REPORT(sum(salvalue)) OVER ()
   FROM job inner join career on job.jobno=career.jobno inner join salary on salary.empno=career.empno
group by jobname;

SELECT nvl(deptname, 'Total'), count(empno)
   FROM career inner join dept on career.deptno=dept.deptno
group by rollup(deptname);

SELECT nvl(deptname, 'All departments'), nvl(jobname, 'All jobs'), count(empno)
   FROM career inner join dept on career.deptno=dept.deptno inner join job on job.jobno=career.jobno
group by cube(deptname, jobname);

SELECT nvl(deptname, 'All departments'), nvl(jobname, 'All jobs'),
  AVG(salvalue) salary
  FROM career inner join dept on career.deptno=dept.deptno inner join job on job.jobno=career.jobno inner join salary on salary.empno = career.empno
GROUP BY CUBE(deptname, jobname)
ORDER BY GROUPING(deptname), GROUPING(jobname);



SELECT nvl(deptname, 'All departments'), nvl(jobname, 'All jobs'),
  AVG(salvalue) salary
  FROM career inner join dept on career.deptno=dept.deptno inner join job on job.jobno=career.jobno inner join salary on salary.empno = career.empno
GROUP BY GROUPING SETS((deptname, jobname), (deptname), (jobname), ())
ORDER BY GROUPING(deptname), GROUPING(jobname);