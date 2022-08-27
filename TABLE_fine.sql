CREATE TABLE fine (
    fine_id        INT PRIMARY KEY AUTO_INCREMENT,
    name           VARCHAR(30),
    number_plate   VARCHAR(6),
    violation      VARCHAR(50),
    sum_fine       DECIMAL(8, 2),
    date_violation DATE,
    date_payment   DATE
);

INSERT INTO fine (name, number_plate, violation, sum_fine, date_violation, date_payment)
    VALUES  ('Баранов П.Е.', 'P523BT', 'Превышение скорости(от 40 до 60)', NULL, '2020-02-14', NULL),
            ('Абрамова К.А.', 'О111AB', 'Проезд на запрещающий сигнал', NULL, '2020-02-23', NULL),
            ('Яковлев Г.Р.', 'T330TT', 'Проезд на запрещающий сигнал', NULL, '2020-03-03', NULL),
            ('Баранов П.Е.', 'P523BT', 'Превышение скорости(от 40 до 60)', 500.00, '2020-01-12', '2020-01-17'),
            ('Абрамова К.А.', 'О111AB', 'Проезд на запрещающий сигнал', 1000.00, '2020-01-14', '2020-02-27'),
            ('Яковлев Г.Р.', 'T330TT', 'Превышение скорости(от 20 до 40)', 500.00, '2020-01-23', '2020-02-23'),
            ('Яковлев Г.Р.', 'M701AA', 'Превышение скорости(от 20 до 40)', NULL, '2020-01-12', NULL),
            ('Колесов С.П.', 'K892AX', 'Превышение скорости(от 20 до 40)', NULL, '2020-02-01', NULL);

CREATE TABLE traffic_violation
(
    violation_id INT PRIMARY KEY AUTO_INCREMENT,
    violation    VARCHAR(50),
    sum_fine     DECIMAL(8, 2)
);

INSERT INTO traffic_violation (violation, sum_fine)
    VALUES ('Превышение скорости(от 20 до 40)', 500),
        ('Превышение скорости(от 40 до 60)', 1000),
        ('Проезд на запрещающий сигнал', 1000);

--1. Занести в таблицу fine суммы штрафов, которые должен оплатить водитель, в соответствии с данными из таблицы traffic_violation. При этом суммы заносить только в пустые поля столбца  sum_fine.

UPDATE fine AS fn, traffic_violation AS tv
    SET fn.sum_fine = tv.sum_fine
    WHERE fn.sum_fine IS NULL AND fn.violation = tv.violation;
    SELECT * FROM fine;

--2. Вывести фамилию, номер машины и нарушение только для тех водителей, которые на одной машине нарушили одно и то же правило   два и более раз. При этом учитывать все нарушения, независимо от того оплачены они или нет. Информацию отсортировать в алфавитном порядке, сначала по фамилии водителя, потом по номеру машины и, наконец, по нарушению.

SELECT name, number_plate, violation FROM fine
    GROUP BY name, number_plate, violation
    HAVING count(violation)>1;

--3. В таблице fine увеличить в два раза сумму неоплаченных штрафов для отобранных на предыдущем шаге записей. 

UPDATE fine AS fn, (
    SELECT name, number_plate, violation FROM fine
    GROUP BY name, number_plate, violation
    HAVING count(violation)>1) AS qin
    SET sum_fine = IF(date_payment IS NULL, sum_fine*2, sum_fine)
    WHERE fn.name = qin.name;
    SELECT * FROM fine;

--4.  в таблицу fine занести дату оплаты соответствующего штрафа из таблицы payment; уменьшить начисленный штраф в таблице fine в два раза  (только для тех штрафов, информация о которых занесена в таблицу payment) , если оплата произведена не позднее 20 дней со дня нарушения.

UPDATE fine AS fn, payment AS paym
    SET fn.date_payment = paym.date_payment,
        fn.sum_fine = IF(DATEDIFF(paym.date_payment, paym.date_violation) <= 20, fn.sum_fine/2, fn.sum_fine)
    WHERE fn.name = paym.name
    AND fn.number_plate = paym.number_plate 
    AND fn.violation = paym.violation
    AND fn.date_violation = paym.date_violation;
    SELECT * FROM fine;

--5. Создать новую таблицу back_payment, куда внести информацию о неоплаченных штрафах (Фамилию и инициалы водителя, номер машины, нарушение, сумму штрафа  и  дату нарушения) из таблицы fine. 

CREATE TABLE back_payment AS 
    SELECT name, number_plate, violation, sum_fine, date_violation
    FROM fine
    WHERE date_payment IS NULL;
    SELECT * FROM back_payment;

--6. Удалить из таблицы fine информацию о нарушениях, совершенных раньше 1 февраля 2020 года. 

DELETE FROM fine
    WHERE DATEDIFF(date_violation,'2020-02-01') < 0;
    SELECT * FROM fine;


