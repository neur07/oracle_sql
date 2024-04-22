-- LAB 1
-- Wyświetl wszystkie rekordy oraz kolumny z tabeli  EMPLOYEES .

SELECT * FROM employees;

-- Wyświetl opis struktury tabli  EMPLOYEES .

DESCRIBE employees;

--  Wyświetl wszystkie rekordy z tabeli  EMPLOYEES  wybierając wyłącznie kolumny  FIRST_NAME ,  LAST_NAME  oraz  EMAIL .

SELECT first_name, last_name, email FROM employees;


-- LAB 2 - SELECT
-- Wyświetl wszystkie unikalne identyfikatory stanowisk z tabeli employees ,
-- posortuj je alfabetycznie.
-- Rozwiązanie: 19 wierszy.

select distinct job_id from employees
order by job_id;

-- Wyświetl identyfikator, nazwę oraz maksymalne wynagrodzenie wszystkich
-- stanowisk, na których maksymalne wynagrodzenie jest mniejsze niż  10 000 .
-- Posortuj rekordy malejąco po wysokości maksymalnej wypłaty.
-- Rozwiązanie: 9 wierszy, pierwszy wiersz ma maksymalną płacę równą
-- 9000.

select job_id, job_title, max_salary from jobs
where max_salary < 10000
order by max_salary desc;

-- Wyświetl imię, nazwisko, email i datę zatrudnienia osób zatrudnionych w
-- 2004 roku.
-- Rozwiązanie: 10 wierszy.

select first_name, last_name, email, hire_date from employees
where EXTRACT(YEAR FROM hire_date) = 2004;


-- Wyświetl imię, nazwisko, email i datę zatrudnienia osób zatrudnionych po
-- 13.01.2008 . W zapytaniu wykorzystaj dokładnie ten format daty.
-- Rozwiązanie: 9 wierszy.

select first_name, last_name, email, hire_date from employees
where hire_date > TO_DATE('13.01.2008', 'DD.MM.YYYY');


-- Wyświetl imię, nazwisko, identyfikator stanowiska i wysokość
-- wynagrodzenia osób, które zarabiają kwoty w przedziale od 9 do 10 tys.
-- włącznie.
-- Rozwiązanie: 12 wierszy.

select first_name, last_name, job_id, salary from employees
where salary between 9000 and 10000;


-- Wyświetl imiona i nazwiska osób, których nazwisko zaczyna się od K i nie
-- kończy na g.
-- Za pomocą funkcji SUBSTR
-- Za pomocą funkcji REGEXP_LIKE
-- Rozwiązanie: 3 wiersze.

select first_name, last_name from employees
where SUBSTR(last_name,1,1) = 'K' and not substr(last_name,-1,1) = 'g';


select first_name, last_name from employees
where REGEXP_LIKE(last_name, '^K[a-z]*[^g]$', 'i' );




-- LAB3 - JOINS
--  Wyświetl imię, nazwisko i nazwę stanowiska wszystkich zatrudnionych
-- osób. Wyniki posortuj alfabetycznie w zależności od nazwiska.
-- Pierwszy wiersz rozwiązania:
-- FIRST_NAME LAST_NAME JOB_TITLE
-- Ellen Abel Sales Representative

select first_name, last_name, job_title from employees, jobs
where jobs.job_id = employees.job_id
order by last_name asc;


-- 2. Wyświetl imię, nazwisko i nazwę stanowiska osób, które zarabiają
-- minimalną stawkę dla swojego stanowiska.
-- Rozwiązanie: 3 wiersze.

select first_name, last_name, job_title from employees, jobs
where jobs.job_id = employees.job_id and employees.salary = jobs.min_salary;

-- 3. Wyświetl imię i nazwisko pracowników pracujących w regionie o nazwie
-- Europe .
-- Rozwiązanie: 36 wierszy.

select first_name, last_name from employees, departments, locations, countries, regions
where employees.department_id = departments.department_id
and departments.location_id = locations.location_id
and locations.country_id = countries.country_id
and countries.region_id = regions.region_id
and regions.region_name = 'Europe';



-- 4. Wyświetl nazwy działów, które nie zatrudniają żadnego pracownika.
-- Rozwiązanie: 16 wierszy.

select distinct department_name
from departments dep
left join employees emp
on emp.department_id = dep.department_id
where emp.department_id is null;


-- 5. Wyświetl zestawienie pracowników (kolumna zawierająca imię i nazwisko
-- oddzielone spacją, o nazwie Employee ) i ich managerów (kolumna
-- zawierająca imię i nazwisko oddzielone spacją, o nazwie Manager ). Posortuj
-- wyniki alfabetycznie według nazwiska managera.
-- Pierwszy wiersz rozwiązania:
-- EMPLOYEE MANAGER
-- William Smith Gerald Cambrault

select concat(concat(emp.first_name, ' '), emp.last_name) as Employee,
concat(concat(man.first_name, ' '), man.last_name) as Manager
from employees emp
join employees man
on emp.manager_id = man.employee_id
order by man.last_name;


-- 6. Wyświetl imiona i nazwiska pracowników, których aktualny dział nie
-- występuje wśród rekordów opisujących historię zatrudnienia pracowników
-- firmy. Posortuj rekordy alfabetycznie według nazwiska pracownika.
-- Rozwiązanie: 15 wierszy. Pierwszy z nich:
-- FIRST_NAME LAST_NAME
-- Hermann Baer

select first_name, last_name
from employees emp
left join job_history jh
on emp.department_id = jh.department_id
where jh.department_id is null and not emp.department_id is null
order by last_name asc;


-- LAB4 - AGGREGATION
-- Wyświetl liczbę działów, które nie mają przypisanego managera.
-- Rozwiązanie: 16

select count(department_id) 
from departments
where manager_id is NULL;


-- 2. Wyświetl ile pełnych lat minęło od zatrudnienia pierwszego pracownika do
-- zatrudnienia ostatniego pracownika.
-- Rozwiązanie: 7

select round(MONTHS_BETWEEN(max(hire_date),min(hire_date)) / 12) as Years from employees;

-- 3. Wyświetl nazwy działów, które nie zatrudniają żadnego pracownika.
-- Rozwiązanie: 16 wierszy

select d.department_name
from departments d
left join employees e
on d.department_id = e.department_id
group by d.department_name
having count(e.employee_id) = 0;

-- 4. Wyświetl nazwę działu oraz średnią zarobków wszystkich pracowników w
-- nim zatrudnionych. Kolumnę ze średnią zarobków nazwij  Average Salary .
-- Zarobki uśrednij do liczb całkowitych. Wyniki posortuj malejąco po średniej
-- zarobków.
-- Pierwszy wiersz rozwiązania:
-- DEPARTMENT_NAME Average Salary
-- Executive 19333

select departments.department_name, round(avg(salary)) as "Average salary"
from departments, employees
where departments.department_id = employees.department_id
group by departments.department_name;


-- 5. Dla każdego kraju wyświetl liczbę zatrudnionych w nim pracowników.
-- Rozwiązanie: np. w United Kingdom zatrudnionych jest 35 pracowników.

select c.country_name, count(e.employee_id)
from countries c
left join locations l
on c.country_id = l.country_id
left join departments d
on l.location_id = d.location_id
left join employees e
on d.department_id = e.department_id
group by c.country_name;


-- 6. Wyświetl numer identyfikacyjny oraz sumę zarobków w działach, w których
-- suma zarobków jest większa niż  15000 oraz mniejsza lub równa  40000 .
-- Pierwszy wiersz rozwiązania:
-- DEPARTMENT_ID Suma zarobków
-- 110 20308

select departments.department_id, sum(salary)
from departments, employees
where departments.department_id = employees.department_id
group by departments.department_id
having sum(salary) between 15000 and 49000;


-- LAB 5 
-- Wyświetl imię, nazwisko i wysokość wypłaty osób, których zarobki ponad
-- dwukrotnie przekraczają średnie zarobki w firmie.
-- Rozwiązanie: 6 wierszy.

select first_name, last_name, salary
from employees 
where salary > 2 *
(
    select avg(salary)
    from employees
);

-- 2. Wyświetl imię, nazwisko i wysokość wypłaty osób, którzy zarabiają ponad
-- dwukrotnie więcej niż wynosi średnia wypłata ich działu. Wyniki posortuj rosnąco po
-- wysokości wypłaty.
-- Rozwiązanie: 4 wiersze.

select first_name, last_name, salary
from employees empa
where salary > 2 *
(
    select avg(salary)
    from employees empb
    where empa.department_id = empb.department_id
)
order by salary;

-- 3. Dla każdego pracownika, dla którego dostępna jest historia zatrudnienia
-- ( job_history ) wyświetl jego imię, nazwisko, nazwę działu i nazwę stanowiska na
-- którym pracował oraz liczbę dni, którą na pracował na danym stanowisku. Wyniki
-- posortuj alfabetycznie po nazwisku.
-- Pierwszy wiersz rozwiązania:
-- FIRST_NAME LAST_NAME DAYS DEPARTMENT_NAME JOB_TITLE
-- Lex De Haan 2018 IT Programmer

select first_name, last_name, (end_date - start_date) as DAYS, department_name, job_title
from job_history jh
left join employees emp
on jh.employee_id = emp.employee_id
left join departments dep
on jh.department_id = dep.department_id
left join jobs
on jobs.job_id = jh.job_id
order by last_name;


-- 4. Wyświetl imię, nazwisko, nazwę działu i wysokość wypłaty pracowników, którzy
-- pracują w działach zatrudniających więcej niż 40 osób. Wyniki posortuj rosnąco po
-- wysokości wypłaty.
-- Pierwszy wiersz rozwiązania:
-- FIRST_NAME LAST_NAME DEPARTMENT_NAME SALARY
-- TJ Olson Shipping 2100

select first_name, last_name, department_name, salary
from employees emp
left join (
    select department_id, count(*) as emp_count
    from employees
    group by department_id
) cnt
on emp.department_id = cnt.department_id
left join departments dep
on emp.department_id = dep.department_id
where emp_count > 40
order by salary;


-- 5. Wyświetl nazwę działu, liczbę zatrudnionych w nim pracowników (jako Department
-- employee count ), następnie imię i nazwisko managera tego działu (w jednej kolumnie o
-- nazwie Department manager ) oraz liczbę pracowników dla których manager działu
-- działu pełni rolę managera, niezależnie od działu (jako Manager employee count ). Wyniki
-- posortuj alfabetycznie według nazwy działu.
-- Pierwszy wiersz rozwiązania:
-- DEPARTMENT
-- NAME
-- DEPARTMENT EMPLOYEE
-- COUNT
-- MANAGER
-- NAME
-- MANAGER EMPLOYEE
-- COUNT
-- Accounting 2 Shelley Higgins 1

select 
department_name as "DEPARTMENT NAME",
department_employee_count as "DEPARTMENT EMPLOYEE COUNT",
concat(concat(emp.first_name, ' '), emp.last_name) as "MANAGER NAME",
mec as "MANAGER EMPLOYEE COUNT"
from departments dep
left join (
    select department_id, count(*) as department_employee_count
    from employees
    group by department_id
) cnt
on dep.department_id = cnt.department_id
left join employees emp
on dep.manager_id = emp.employee_id
left join (
    select manager_id, count(*) as mec
    from employees
    group by manager_id
) mc
on dep.manager_id = mc.manager_id
where department_employee_count is not null
order by department_name;




-- DODATKOWE

-- wyswietl liczbe pracownikow ktorych wyplata jest wyzsza niz srednia wyplata w firmie

SELECT COUNT(*) AS LiczbaPracownikow
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);

-- wyswietl imie, nazwisko,date zatrudnienia i wysokosc wyplaty osob zatrudnionych w czerwcu i zarabiajacych powyzej 8000. wyniki posortuj rosnaco po wysokosci wyplaty

SELECT first_name, last_name, hire_date, salary
FROM employees
WHERE hire_date BETWEEN TO_DATE('01-06-YYYY', 'DD-MM-YYYY') AND TO_DATE('30-06-YYYY', 'DD-MM-YYYY')
AND salary > 8000
ORDER BY salary ASC;

SELECT first_name, last_name, hire_date, salary
FROM employees
WHERE (hire_date BETWEEN TO_DATE('01-06-YYYY', 'DD-MM-YYYY') AND TO_DATE('30-06-YYYY', 'DD-MM-YYYY'))
AND (salary > 8000)
ORDER BY salary ASC;

SELECT first_name, last_name, hire_date, salary
FROM employees
WHERE EXTRACT(MONTH FROM hire_date) = 6
AND EXTRACT(YEAR FROM hire_date) = EXTRACT(YEAR FROM SYSDATE)
AND salary > 8000
ORDER BY salary ASC;

-- wyswietl imie i nazwisko pracownikow, ktorych zatrudniono w tym samym miesiacu co ich managera(niezaleznie od roku.wyniki posortuj alfabetyznie po nazwisku

SELECT e.first_name, e.last_name
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE EXTRACT(MONTH FROM e.hire_date) = EXTRACT(MONTH FROM m.hire_date)
ORDER BY e.last_name;

-- wypisz nazwe dzialu oraz sume zarobkow wszystkich pracownikow zatrudnionych w dziale, dla dzialow w ktorych suma zarobkow przekracza 50000

SELECT d.department_name, SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
HAVING SUM(e.salary) > 50000;


-- wyswietl imie,nazwiwsko,nazwe dzialu, i stanowiska osob,ktorych manager jest takze managerem dzialu w ktorych pracuja. wyniki posortuj alfabetycznie po nazwisku

SELECT
e.first_name,
e.last_name,
d.department_name,
e.job_id
FROM
employees e
JOIN
departments d ON e.department_id = d.department_id
JOIN
employees m ON e.manager_id = m.employee_id AND d.manager_id = m.employee_id
ORDER BY
e.last_name;

-- wyswietl nazwy dzialow oraz srednia wyplate pracownikow w nich zatrudnionych, dla dzialow ktore zatrudniaja pomiedzy 3 a 6 pracownikow(wlacznie z tymi wartosciami)

SELECT
d.department_name,
AVG(e.salary) AS average_salary
FROM
departments d
JOIN
employees e ON d.department_id = e.department_id
GROUP BY
d.department_name
HAVING
COUNT(e.employee_id) BETWEEN 3 AND 6;