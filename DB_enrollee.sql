DROP TABLE IF EXISTS department;
DROP TABLE IF EXISTS subject;
DROP TABLE IF EXISTS program;
DROP TABLE IF EXISTS enrollee;
DROP TABLE IF EXISTS achievement;
DROP TABLE IF EXISTS enrollee_achievement;
DROP TABLE IF EXISTS program_subject;
DROP TABLE IF EXISTS program_enrollee;
DROP TABLE IF EXISTS enrollee_subject;

CREATE TABLE department(
    department_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name_department VARCHAR(30)
);
INSERT INTO department(name_department)
VALUES
    ('Инженерная школа'),
    ('Школа естественных наук');

CREATE TABLE subject(
    subject_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name_subject VARCHAR(30)
);
INSERT INTO subject(name_subject)
VALUES
    ('Русский язык'),
    ('Математика'),
    ('Физика'),
    ('Информатика');

CREATE TABLE program(
    program_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name_program VARCHAR(50),
    department_id INT,
    plan INT,
    FOREIGN KEY department(department_id) REFERENCES department(department_id) ON DELETE CASCADE
);
INSERT INTO program(name_program, department_id, plan)
VALUES
    ('Прикладная математика и информатика', 2, 2),
    ('Математика и компьютерные науки', 2, 1),
    ('Прикладная механика', 1, 2),
    ('Мехатроника и робототехника', 1, 3);

CREATE TABLE enrollee(
    enrollee_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name_enrollee VARCHAR(50)
);
INSERT INTO enrollee(name_enrollee)
VALUES
    ('Баранов Павел'),
    ('Абрамова Катя'),
    ('Семенов Иван'),
    ('Яковлева Галина'),
    ('Попов Илья'),
    ('Степанова Дарья');

CREATE TABLE achievement(
    achievement_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name_achievement VARCHAR(30),
    bonus INT
);
INSERT INTO achievement(name_achievement, bonus)
VALUES
    ('Золотая медаль', 5),
    ('Серебряная медаль', 3),
    ('Золотой значок ГТО', 3),
    ('Серебряный значок ГТО    ', 1);

CREATE TABLE enrollee_achievement(
    enrollee_achiev_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    enrollee_id INT,
    achievement_id INT,
    FOREIGN KEY enrollee(enrollee_id) REFERENCES enrollee(enrollee_id) ON DELETE CASCADE,
    FOREIGN KEY achievement(achievement_id) REFERENCES achievement(achievement_id) ON DELETE CASCADE
);
INSERT INTO enrollee_achievement(enrollee_id, achievement_id)
VALUES
    (1, 2),
    (1, 3),
    (3, 1),
    (4, 4),
    (5, 1),
    (5, 3);

CREATE TABLE program_subject(
    program_subject_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    program_id INT,
    subject_id INT,
    min_result INT,
    FOREIGN KEY program(program_id) REFERENCES program(program_id) ON DELETE CASCADE,
    FOREIGN KEY subject(subject_id) REFERENCES subject(subject_id) ON DELETE CASCADE
);
INSERT INTO program_subject(program_id, subject_id, min_result)
VALUES
    (1, 1, 40),
    (1, 2, 50),
    (1, 4, 60),
    (2, 1, 30),
    (2, 2, 50),
    (2, 4, 60),
    (3, 1, 30),
    (3, 2, 45),
    (3, 3, 45),
    (4, 1, 40),
    (4, 2, 45),
    (4, 3, 45);

CREATE TABLE program_enrollee(
    program_enrollee_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    program_id INT,
    enrollee_id INT,
    FOREIGN KEY program(program_id) REFERENCES program(program_id) ON DELETE CASCADE,
    FOREIGN KEY enrollee(enrollee_id) REFERENCES enrollee(enrollee_id) ON DELETE CASCADE
);
INSERT INTO program_enrollee(program_id, enrollee_id)
VALUES
    (3, 1),
    (4, 1),
    (1, 1),
    (2, 2),
    (1, 2),
    (1, 3),
    (2, 3),
    (4, 3),
    (3, 4),
    (3, 5),
    (4, 5),
    (2, 6),
    (3, 6),
    (4, 6);

CREATE TABLE enrollee_subject(
    enrollee_subject_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    enrollee_id INT,
    subject_id INT,
    result INT,
    FOREIGN KEY enrollee(enrollee_id) REFERENCES enrollee(enrollee_id) ON DELETE CASCADE,
    FOREIGN KEY subject(subject_id) REFERENCES subject(subject_id) ON DELETE CASCADE
);
INSERT INTO enrollee_subject(enrollee_id, subject_id, result)
VALUES
    (1, 1, 68),
    (1, 2, 70),
    (1, 3, 41),
    (1, 4, 75),
    (2, 1, 75),
    (2, 2, 70),
    (2, 4, 81),
    (3, 1, 85),
    (3, 2, 67),
    (3, 3, 90),
    (3, 4, 78),
    (4, 1, 82),
    (4, 2, 86),
    (4, 3, 70),
    (5, 1, 65),
    (5, 2, 67),
    (5, 3, 60),
    (6, 1, 90),
    (6, 2, 92),
    (6, 3, 88),
    (6, 4, 94);

--1. Вывести абитуриентов, которые хотят поступать на образовательную программу «Мехатроника и робототехника» в отсортированном по фамилиям виде.

SELECT name_enrollee 
FROM
    enrollee
    INNER JOIN program_enrollee USING(enrollee_id)
WHERE program_id = 4
ORDER BY name_enrollee;    

--2. Вывести образовательные программы, на которые для поступления необходим предмет «Информатика». Программы отсортировать в обратном алфавитном порядке.

SELECT name_program
FROM
    program
    INNER JOIN program_subject USING(program_id)
    INNER JOIN subject USING(subject_id)
WHERE subject_id = 4
ORDER BY name_program DESC;

/*3.Выведите количество абитуриентов, сдавших ЕГЭ по каждому предмету, максимальное, минимальное и среднее значение баллов по предмету ЕГЭ. Вычисляемые столбцы назвать Количество, Максимум, Минимум, Среднее. Информацию отсортировать по названию предмета в алфавитном порядке, среднее значение округлить до одного знака после запятой.*/

SELECT name_subject, 
       COUNT(enrollee_id) AS Количество, 
       MAX(result) AS Максимум, 
       MIN(result) AS Минимум,
       ROUND(AVG(result), 1) AS Среднее 
FROM
    subject
    INNER JOIN enrollee_subject USING(subject_id)
GROUP BY name_subject
ORDER BY name_subject;

--4. Вывести образовательные программы, для которых минимальный балл ЕГЭ по каждому предмету больше или равен 40 баллам. Программы вывести в отсортированном по алфавиту виде.

SELECT DISTINCT(name_program)
FROM
    program
    INNER JOIN program_subject USING(program_id)
GROUP BY 1
HAVING MIN(min_result) >= 40
ORDER BY name_program;

--5. Вывести образовательные программы, которые имеют самый большой план набора,  вместе с этой величиной.

SELECT name_program, plan
FROM program
WHERE plan = (SELECT MAX(plan) FROM program);

--6. Посчитать, сколько дополнительных баллов получит каждый абитуриент. Столбец с дополнительными баллами назвать Бонус. Информацию вывести в отсортированном по фамилиям виде.

SELECT name_enrollee, IFNULL(SUM(bonus), 0) AS Бонус
-- функция IFNULL(A, B) возвращает значение B если A is NULL, иначе возвращает A.
-- COALESCE(A,B) вернет A, если B - NULL и вернет B, если  A - NULL.
FROM enrollee
    LEFT JOIN enrollee_achievement USING(enrollee_id)
    LEFT JOIN achievement USING(achievement_id)
GROUP BY name_enrollee    
ORDER BY name_enrollee ASC

--7. Выведите сколько человек подало заявление на каждую образовательную программу и конкурс на нее (число поданных заявлений деленное на количество мест по плану), округленный до 2-х знаков после запятой. В запросе вывести название факультета, к которому относится образовательная программа, название образовательной программы, план набора абитуриентов на образовательную программу (plan), количество поданных заявлений (Количество) и Конкурс. Информацию отсортировать в порядке убывания конкурса.

SELECT department.name_department, 
       program.name_program,
       plan, 
       COUNT(enrollee_id) AS Количество, 
       ROUND(COUNT(enrollee_id)/plan, 2) AS Конкурс 
FROM
    program_enrollee
    INNER JOIN program USING(program_id)
    INNER JOIN department USING(department_id)
GROUP BY 1, 2, 3
ORDER BY 5 DESC;

--8. Вывести образовательные программы, на которые для поступления необходимы предмет «Информатика» и «Математика» в отсортированном по названию программ виде.

SELECT name_program
FROM
    program
    INNER JOIN program_subject USING(program_id)
    INNER JOIN subject USING(subject_id)
WHERE name_subject IN('Информатика', 'Математика')
GROUP BY 1
HAVING COUNT(name_subject) = 2
ORDER BY 1;

--9. Посчитать количество баллов каждого абитуриента на каждую образовательную программу, на которую он подал заявление, по результатам ЕГЭ. В результат включить название образовательной программы, фамилию и имя абитуриента, а также столбец с суммой баллов, который назвать itog. Информацию вывести в отсортированном сначала по образовательной программе, а потом по убыванию суммы баллов виде.

SELECT name_program, name_enrollee, SUM(enrollee_subject.result) AS itog 
FROM
    enrollee
    INNER JOIN program_enrollee USING(enrollee_id)
    INNER JOIN program USING(program_id)
    INNER JOIN program_subject USING(program_id)
    INNER JOIN subject USING(subject_id)
    INNER JOIN enrollee_subject ON
    subject.subject_id = enrollee_subject.subject_id 
AND enrollee_subject.enrollee_id = enrollee.enrollee_id
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

/*10. Вывести название образовательной программы и фамилию тех абитуриентов, которые подавали документы на эту образовательную программу, но не могут быть зачислены на нее. Эти абитуриенты имеют результат по одному или нескольким предметам ЕГЭ, необходимым для поступления на эту образовательную программу, меньше минимального балла. Информацию вывести в отсортированном сначала по программам, а потом по фамилиям абитуриентов виде.
Например, Баранов Павел по «Физике» набрал 41 балл, а  для образовательной программы «Прикладная механика» минимальный балл по этому предмету определен в 45 баллов. Следовательно, абитуриент на данную программу не может поступить.*/

SELECT DISTINCT(name_program), name_enrollee
FROM
    enrollee
    INNER JOIN program_enrollee USING(enrollee_id)
    INNER JOIN program USING(program_id)
    INNER JOIN program_subject USING(program_id)
    INNER JOIN subject USING(subject_id)
    INNER JOIN enrollee_subject ON
    subject.subject_id = enrollee_subject.subject_id 
AND enrollee_subject.enrollee_id = enrollee.enrollee_id
WHERE min_result > result
ORDER BY 1, 2;

