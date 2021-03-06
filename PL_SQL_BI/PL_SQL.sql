﻿--Лабораторная работа №6. PL/SQL

--1. Добавьте в таблицу SALARY столбец TAX (налог) для вычисления ежемесячного подоходного налога на зарплату по прогрессивной шкале. Налог вычисляется по следующему правилу:
-- -налог равен 9% от начисленной в месяце зарплаты, если суммарная зарплата с начала года до конца рассматриваемого месяца не превышает 20 000;
-- -налог равен 12% от начисленной в месяце зарплаты, если суммарная зарплата с начала года до конца рассматриваемого месяца больше 20 000, но не превышает 30 000;
-- -налог равен 15% от начисленной в месяце зарплаты, если суммарная зарплата с начала года до конца рассматриваемого месяца больше 30 000.
ALTER TABLE SALARY ADD (TAX NUMBER(15));

--2. Составьте программу вычисления налога и вставки её в таблицу SALARY:
--a) с помощью простого цикла (loop) с курсором и оператора if;
<<SIMPLE_LOOP_CURSOR_IF>>
DECLARE
    SALARYTHISYEAR NUMBER(10);
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX FROM SALARY FOR UPDATE OF TAX;
    REC CUR%ROWTYPE;
BEGIN
    OPEN CUR;
    LOOP
        FETCH CUR INTO REC;
        EXIT WHEN CUR%NOTFOUND;
        SELECT SUM(SALVALUE) INTO SALARYTHISYEAR FROM SALARY S
            WHERE S.EMPNO = REC.EMPNO AND S.MONTH <= REC.MONTH AND S.YEAR = REC.YEAR;
        IF SALARYTHISYEAR < 20000 THEN
            UPDATE SALARY SET TAX = REC.SALVALUE * 0.09
                WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
        ELSIF SALARYTHISYEAR < 30000 THEN
            UPDATE SALARY SET TAX = REC.SALVALUE * 0.12
                WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
        ELSE
            UPDATE SALARY SET TAX = REC.SALVALUE * 0.15
                WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
        END IF;
    END LOOP;
    CLOSE CUR;
    COMMIT;
END SIMPLE_LOOP_CURSOR_IF;

--b) с помощью простого цикла (loop) с курсором и оператора case;
<<SIMPLE_LOOP_CURSOR_CASE>>
DECLARE
    SALARYTHISYEAR NUMBER(10);
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX FROM SALARY FOR UPDATE OF TAX;
    REC CUR%ROWTYPE;
BEGIN
    OPEN CUR;
    LOOP
        FETCH CUR INTO REC;
        EXIT WHEN CUR%NOTFOUND;
        SELECT SUM(SALVALUE) INTO SALARYTHISYEAR FROM SALARY S
            WHERE S.EMPNO = REC.EMPNO AND S.MONTH <= REC.MONTH AND S.YEAR = REC.YEAR;
        UPDATE SALARY SET TAX =
            CASE
                WHEN SALARYTHISYEAR < 20000 THEN REC.SALVALUE * 0.09
                WHEN SALARYTHISYEAR < 30000 THEN REC.SALVALUE * 0.12
                ELSE REC.SALVALUE * 0.15
            END
            WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
    END LOOP;
    CLOSE CUR;
    COMMIT;
END SIMPLE_LOOP_CURSOR_CASE;

--c) с помощью курсорного цикла FOR;
<<CURSOR_FOR>>
DECLARE
    SALARYTHISYEAR NUMBER(10);
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX FROM SALARY FOR UPDATE OF TAX;
BEGIN
    FOR REC IN CUR LOOP
        SELECT SUM(SALVALUE) INTO SALARYTHISYEAR FROM SALARY S
            WHERE S.EMPNO = REC.EMPNO AND S.MONTH <= REC.MONTH AND S.YEAR = REC.YEAR;
        UPDATE SALARY SET TAX =
            CASE
                WHEN SALARYTHISYEAR < 20000 THEN REC.SALVALUE * 0.09
                WHEN SALARYTHISYEAR < 30000 THEN REC.SALVALUE * 0.12
                ELSE REC.SALVALUE * 0.15
            END
            WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
    END LOOP;
    COMMIT;
END CURSOR_FOR;

--d) с помощью курсора с параметром, передавая номер сотрудника, для которого необходимо посчитать налог.
<<CURSOR_WITH_PAR>>
DECLARE
    SALARYTHISYEAR NUMBER(10);
    CURSOR CUR(EMPID NUMBER) IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID
        FOR UPDATE OF TAX;
BEGIN
    FOR REC IN CUR LOOP
        SELECT SUM(SALVALUE) INTO SALARYTHISYEAR FROM SALARY S
            WHERE S.EMPNO = REC.EMPNO AND S.MONTH <= REC.MONTH AND S.YEAR = REC.YEAR;
        UPDATE SALARY SET TAX =
            CASE
                WHEN SALARYTHISYEAR < 20000 THEN REC.SALVALUE * 0.09
                WHEN SALARYTHISYEAR < 30000 THEN REC.SALVALUE * 0.12
                ELSE REC.SALVALUE * 0.15
            END
            WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
    END LOOP;
    COMMIT;
END CURSOR_WITH_PAR;

--3. Оформите составленные программы в виде процедур.
--a) с помощью простого цикла (loop) с курсором и оператора if;
CREATE OR REPLACE PROCEDURE SIMPLE_LOOP_CURSOR_IF AS
    SALARYTHISYEAR NUMBER(10);
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX FROM SALARY FOR UPDATE OF TAX;
    REC CUR%ROWTYPE
BEGIN
    OPEN CUR;
    LOOP
        FETCH CUR INTO REC;
        EXIT WHEN CUR%NOTFOUND;
        SELECT SUM(SALVALUE) INTO SALARYTHISYEAR FROM SALARY S
            WHERE S.EMPNO = REC.EMPNO AND S.MONTH <= REC.MONTH AND S.YEAR = REC.YEAR;
        IF SALARYTHISYEAR < 20000 THEN
            UPDATE SALARY SET TAX = REC.SALVALUE * 0.09
                WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
        ELSIF SALARYTHISYEAR < 30000 THEN
            UPDATE SALARY SET TAX = REC.SALVALUE * 0.12
                WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
        ELSE
            UPDATE SALARY SET TAX = REC.SALVALUE * 0.15
                WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
        END IF;
    END LOOP;
    CLOSE CUR;
    COMMIT;
END SIMPLE_LOOP_CURSOR_IF;

--b) с помощью простого цикла (loop) с курсором и оператора case;
CREATE OR REPLACE PROCEDURE SIMPLE_LOOP_CURSOR_CASE AS
    SALARYTHISYEAR NUMBER(10);
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX FROM SALARY FOR UPDATE OF TAX;
    REC CUR%ROWTYPE
BEGIN
    OPEN CUR;
    LOOP
        FETCH CUR INTO REC;
        EXIT WHEN CUR%NOTFOUND;
        SELECT SUM(SALVALUE) INTO SALARYTHISYEAR FROM SALARY S
            WHERE S.EMPNO = REC.EMPNO AND S.MONTH <= REC.MONTH AND S.YEAR = REC.YEAR;
        UPDATE SALARY SET TAX =
            CASE
                WHEN SALARYTHISYEAR < 20000 THEN REC.SALVALUE * 0.09
                WHEN SALARYTHISYEAR < 30000 THEN REC.SALVALUE * 0.12
                ELSE REC.SALVALUE * 0.15
            END
            WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
    END LOOP;
    CLOSE CUR;
    COMMIT;
END SIMPLE_LOOP_CURSOR_CASE;

--c) с помощью курсорного цикла FOR;
CREATE OR REPLACE PROCEDURE CURSOR_FOR AS
    SALARYTHISYEAR NUMBER(10);
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX FROM SALARY FOR UPDATE OF TAX;
BEGIN
    FOR REC IN CUR LOOP
        SELECT SUM(SALVALUE) INTO SALARYTHISYEAR FROM SALARY S
            WHERE S.EMPNO = REC.EMPNO AND S.MONTH <= REC.MONTH AND S.YEAR = REC.YEAR;
        UPDATE SALARY SET TAX =
            CASE
                WHEN SALARYTHISYEAR < 20000 THEN REC.SALVALUE * 0.09
                WHEN SALARYTHISYEAR < 30000 THEN REC.SALVALUE * 0.12
                ELSE REC.SALVALUE * 0.15
            END
            WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
    END LOOP;
    COMMIT;
END CURSOR_FOR;

--d) с помощью курсора с параметром, передавая номер сотрудника, для которого необходимо посчитать налог.
CREATE OR REPLACE PROCEDURE CURSOR_WITH_PAR AS
    SALARYTHISYEAR NUMBER(10);
    CURSOR CUR(EMPID NUMBER) IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID
        FOR UPDATE OF TAX;
BEGIN
    FOR REC IN CUR LOOP
        SELECT SUM(SALVALUE) INTO SALARYTHISYEAR FROM SALARY S
            WHERE S.EMPNO = REC.EMPNO AND S.MONTH <= REC.MONTH AND S.YEAR = REC.YEAR;
        UPDATE SALARY SET TAX =
            CASE
                WHEN SALARYTHISYEAR < 20000 THEN REC.SALVALUE * 0.09
                WHEN SALARYTHISYEAR < 30000 THEN REC.SALVALUE * 0.12
                ELSE REC.SALVALUE * 0.15
            END
            WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
    END LOOP;
    COMMIT;
END CURSOR_WITH_PAR;

--4. Создайте процедуру, вычисляющую налог на зарплату за всё время начислений для конкретного сотрудника. В качестве параметров передать процент налога (до 20000, до 30000, выше 30000, номер сотрудника).
CREATE OR REPLACE PROCEDURE EMP_TAX_ALL_TIME(EMPID NUMBER, UNDER_20000 NUMBER, OVER_20000 NUMBER, OVER_30000 NUMBER) AS
    SALARYTHISYEAR NUMBER(10);
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID
        FOR UPDATE OF TAX;
BEGIN
    FOR REC IN CUR LOOP
        SELECT SUM(SALVALUE) INTO SALARYTHISYEAR FROM SALARY S
            WHERE S.EMPNO = REC.EMPNO AND S.MONTH <= REC.MONTH AND S.YEAR = REC.YEAR;
        UPDATE SALARY SET TAX =
            CASE
                WHEN SALARYTHISYEAR < 20000 THEN REC.SALVALUE * UNDER_20000
                WHEN SALARYTHISYEAR < 30000 THEN REC.SALVALUE * OVER_20000
                ELSE REC.SALVALUE * OVER_30000
            END
            WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
    END LOOP;
    COMMIT;
END EMP_TAX_ALL_TIME;

--Пример использования
BEGIN
 EMP_TAX_ALL_TIME(7369, 0.09, 0.12, 0.15);
END;

--Эта же процедура в программном блоке PL SQL
DECLARE
    NUM NUMBER(10);
    EMPNO NUMBER(10);
    PROCEDURE EMP_TAX_ALL_TIME(EMPID NUMBER, UNDER_20000 NUMBER, OVER_20000 NUMBER, OVER_30000 NUMBER) AS
        SALARYTHISYEAR NUMBER(10);
        CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
            WHERE EMPNO = EMPID
            FOR UPDATE OF TAX;
    BEGIN
        FOR REC IN CUR LOOP
            SELECT SUM(SALVALUE) INTO SALARYTHISYEAR FROM SALARY S
                WHERE S.EMPNO = REC.EMPNO AND S.MONTH <= REC.MONTH AND S.YEAR = REC.YEAR;
            UPDATE SALARY SET TAX =
                CASE
                    WHEN SALARYTHISYEAR < 20000 THEN REC.SALVALUE * UNDER_20000
                    WHEN SALARYTHISYEAR < 30000 THEN REC.SALVALUE * OVER_20000
                    ELSE REC.SALVALUE * OVER_30000
                END
                WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
        END LOOP;
        COMMIT;
    END EMP_TAX_ALL_TIME;
BEGIN
  EMPNO:=7369;
  EMP_TAX_ALL_TIME(EMPNO, 0.09, 0.12, 0.15);
END;


--5. Создайте функцию, вычисляющую суммарный налог на зарплату сотрудника за всё время начислений. В качестве параметров передать процент налога (до 20000, до 30000, выше 30000, номер сотрудника). Возвращаемое значение – суммарный налог.
CREATE OR REPLACE FUNCTION SUM_EMP_TAX_ALL_TIME(EMPID NUMBER, UNDER_20000 NUMBER, OVER_20000 NUMBER, OVER_30000 NUMBER) RETURN NUMBER AS
    SALARYTHISYEAR NUMBER(10);
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID;
    RESULT NUMBER(10);
BEGIN
    RESULT := 0;
    FOR REC IN CUR LOOP
        SELECT SUM(SALVALUE) INTO SALARYTHISYEAR FROM SALARY S
            WHERE S.EMPNO = REC.EMPNO AND S.MONTH <= REC.MONTH AND S.YEAR = REC.YEAR;
        RESULT := RESULT +
            CASE
                WHEN SALARYTHISYEAR < 20000 THEN REC.SALVALUE * UNDER_20000
                WHEN SALARYTHISYEAR < 30000 THEN REC.SALVALUE * OVER_20000
                ELSE REC.SALVALUE * OVER_30000
            END;
    END LOOP;
    RETURN RESULT;
END  SUM_EMP_TAX_ALL_TIME;

-- Пример использования
SELECT EMPNO, SUM_EMP_TAX_ALL_TIME(EMPNO, 9, 12, 15) FROM SALARY;

--Эта же функция в программном блоке PL SQL
DECLARE
    NUM NUMBER(10);
    EMPNO NUMBER(10);
    FUNCTION SUM_EMP_TAX_ALL_TIME(EMPID NUMBER, UNDER_20000 NUMBER, OVER_20000 NUMBER, OVER_30000 NUMBER) RETURN NUMBER AS
    SALARYTHISYEAR NUMBER(10);
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID;
    RESULT NUMBER(10);
    BEGIN
        RESULT := 0;
        FOR REC IN CUR LOOP
            SELECT SUM(SALVALUE) INTO SALARYTHISYEAR FROM SALARY S
                WHERE S.EMPNO = REC.EMPNO AND S.MONTH <= REC.MONTH AND S.YEAR = REC.YEAR;
            RESULT := RESULT +
                CASE
                    WHEN SALARYTHISYEAR < 20000 THEN REC.SALVALUE * UNDER_20000
                    WHEN SALARYTHISYEAR < 30000 THEN REC.SALVALUE * OVER_20000
                    ELSE REC.SALVALUE * OVER_30000
                END;
        END LOOP;
        RETURN RESULT;
    END  SUM_EMP_TAX_ALL_TIME;
BEGIN
  EMPNO:=7369;
  DBMS_OUTPUT.PUT_LINE('OUTPUT>>' || SUM_EMP_TAX_ALL_TIME(EMPNO, 0.09, 0.12, 0.15));
END;

--6. Создайте пакет, включающий в свой состав процедуру вычисления налога для всех сотрудников, процедуру вычисления налогов для отдельного сотрудника, идентифицируемого своим номером, функцию вычисления суммарного налога на зарплату сотрудника за всё время начислений.
CREATE OR REPLACE PACKAGE TAXES_PACKAGE AS
    PROCEDURE TAX_CURSOR_FOR();
    PROCEDURE  EMP_TAX(EMPID NUMBER);
    FUNCTION SUM_EMP_TAX_ALL_TIME(EMPID NUMBER, UNDER_20000 NUMBER, OVER_20000 NUMBER, OVER_30000 NUMBER);
END TAXES_PACKAGE;

CREATE OR REPLACE PACKAGE BODY TAXES_PACKAGE AS

    PROCEDURE TAX_CURSOR_FOR AS
        SALARYTHISYEAR NUMBER(10);
        CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX FROM SALARY FOR UPDATE OF TAX;
    BEGIN
        FOR REC IN CUR LOOP
            SELECT SUM(SALVALUE) INTO SALARYTHISYEAR FROM SALARY S
                WHERE S.EMPNO = REC.EMPNO AND S.MONTH <= REC.MONTH AND S.YEAR = REC.YEAR;
            UPDATE SALARY SET TAX =
                CASE
                    WHEN SALARYTHISYEAR < 20000 THEN REC.SALVALUE * 0.09
                    WHEN SALARYTHISYEAR < 30000 THEN REC.SALVALUE * 0.12
                    ELSE REC.SALVALUE * 0.15
                END
                WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
        END LOOP;
        COMMIT;
    END TAX_CURSOR_FOR;
    
    PROCEDURE EMP_TAX(EMPID NUMBER) AS
        SALARYTHISYEAR NUMBER(10);
        CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
            WHERE EMPNO = EMPID
            FOR UPDATE OF TAX;
    BEGIN
        FOR REC IN CUR LOOP
            SELECT SUM(SALVALUE) INTO SALARYTHISYEAR FROM SALARY S
                WHERE S.EMPNO = REC.EMPNO AND S.MONTH <= REC.MONTH AND S.YEAR = REC.YEAR;
            UPDATE SALARY SET TAX =
                CASE
                    WHEN SALARYTHISYEAR < 20000 THEN REC.SALVALUE * 0.09
                    WHEN SALARYTHISYEAR < 30000 THEN REC.SALVALUE * 0.12
                    ELSE REC.SALVALUE * 0.15
                END
                WHERE EMPNO = REC.EMPNO AND MONTH = REC.MONTH AND YEAR = REC.YEAR;
        END LOOP;
        COMMIT;
    END EMP_TAX_ALL_TIME;
    
    FUNCTION SUM_EMP_TAX_ALL_TIME(EMPID NUMBER, UNDER_20000 NUMBER, OVER_20000 NUMBER, OVER_30000 NUMBER) RETURN NUMBER AS
        SALARYTHISYEAR NUMBER(10);
        CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
            WHERE EMPNO = EMPID;
        RESULT NUMBER(10);
    BEGIN
        RESULT := 0;
        FOR REC IN CUR LOOP
            SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
                WHERE S.EMPNO = REC.EMPNO AND S.MONTH <= REC.MONTH AND S.YEAR = REC.YEAR;
            RESULT := RESULT +
                CASE
                    WHEN SALARYTHISYEAR < 20000 THEN REC.SALVALUE * UNDER_20000
                    WHEN SALARYTHISYEAR < 30000 THEN REC.SALVALUE * OVER_20000
                    ELSE REC.SALVALUE * OVER_30000
                END;
        END LOOP;
        RETURN RESULT;
    END  SUM_EMP_TAX_ALL_TIME;

END TAXES_PACKAGE;

--7. Создайте триггер, действующий при обновлении данных в таблице SALARY. А именно, если происходит обновление поля SALVALUE, то при назначении новой зарплаты, меньшей чем должностной оклад (таблица JOB, поле MINSALARY), изменение не вносится  и сохраняется старое значение, если новое значение зарплаты больше должностного оклада, то изменение вносится.
CREATE OR REPLACE TRIGGER NO_LITTLE_SALARY
    BEFORE UPDATE OF SALVALUE ON SALARY
    FOR EACH ROW
DECLARE
    CURSOR CUR(EMPID CAREER.EMPNO%TYPE) IS
        SELECT MINSALARY FROM JOB
            WHERE JOBNO = (SELECT JOBNO FROM CAREER WHERE EMPID = EMPNO AND ENDDATE IS NULL);
    REC JOB.MINSALARY%TYPE;
BEGIN
    OPEN CUR(:NEW.EMPNO);
    FETCH CUR INTO REC;
    IF (:NEW.SALVALUE < REC) THEN
        :NEW.SALVALUE := :OLD.SALVALUE;
    END IF;
    CLOSE CUR;
END;

--8. Создайте триггер, действующий при удалении записи из таблицы CAREER. Если в удаляемой строке поле ENDDATE содержит NULL, то запись не удаляется, в противном случае удаляется.
CREATE OR REPLACE TRIGGER NO_DELETE_FOR_WORKERS
    AFTER DELETE ON CAREER
    FOR EACH ROW
    WHEN (OLD.ENDDATE IS NULL)
BEGIN
    INSERT INTO CAREER VALUES (OLD.JOBNO, OLD.EMPNO, OLD.STARTDATE, OLD.ENDDATE);
END;

--9. Создайте триггер, действующий на добавление или изменение данных в таблице EMP. Если во вставляемой или изменяемой строке поле BIRTHDATE содержит NULL, то после вставки или изменения должно быть выдано сообщение ‘BERTHDATE is NULL’. Если во вставляемой или изменяемой строке поле BIRTHDATE содержит дату ранее ‘01-01-1940’, то должно быть выдано сообщение ‘PENTIONA’. Во вновь вставляемой строке имя служащего должно быть приведено к заглавным буквам.
CREATE OR REPLACE TRIGGER WORKING_WITH_EMPLOYEES
    BEFORE INSERT OR UPDATE ON EMP
    FOR EACH ROW
BEGIN
    IF NEW.BIRTHDATE IS NULL THEN
        RAISE_APPLICATION_ERROR(-2134, 'BIRTHDATE is NULL')
    END IF;
    IF NEW.BIRTHDATE < to_date('01-01-1940', 'dd-mm-yyyy') THEN
        RAISE_APPLICATION_ERROR(-2135, 'PENTIONA')
    END IF;
    NEW.EMPNAME := UCASE(NEW.EMPNAME);
END;

--10. Создайте программу изменения типа заданной переменной из символьного типа (VARCHAR2) в числовой тип (NUMBER). Программа должна содержать раздел обработки исключений. Обработка должна заключаться в выдаче сообщения ‘ERROR: argument is not a number’. Исключительная ситуация возникает при задании строки в виде числа с запятой, разделяющей дробную и целую части.
<<VARCHAR2_TO_NUMBER>>
DECLARE
    NUM NUMBER(10);
    FUNCTION VARCHAR2TONUM(SYM IN VARCHAR2) RETURN NUMBER IS
    BEGIN
        RETURN CAST(SYM AS NUMBER);
        EXCEPTION
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: argument is not a number: ' || str);
            RETURN NULL;
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20103, 'Unexpected error');
        RETURN NULL;
    END;
BEGIN
END VARCHAR2_TO_NUMBER;