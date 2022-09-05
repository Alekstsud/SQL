--1.  Включить нового человека в таблицу с клиентами. Его имя Попов Илья, его email popov@test, проживает он в Москве.

INSERT INTO client (name_client,city_id, email)
SELECT 'Попов Илья', city_id, 'popov@test'
FROM city
WHERE name_city = 'Москва';
SELECT * FROM client;

--2. Создать новый заказ для Попова Ильи. Его комментарий для заказа: «Связаться со мной по вопросу доставки».

INSERT INTO buy  (buy_description, client_id)
SELECT 'Связаться со мной по вопросу доставки', client_id
FROM client
WHERE name_client = 'Попов Илья';
SELECT * FROM buy;

--3. В таблицу buy_book добавить заказ с номером 5. Этот заказ должен содержать книгу Пастернака «Лирика» в количестве двух экземпляров и книгу Булгакова «Белая гвардия» в одном экземпляре.

INSERT INTO buy_book(buy_id, book_id, amount)
SELECT '5', (SELECT book_id FROM book WHERE title ='Лирика' AND author_id = (SELECT author_id 
FROM 
    author 
    WHERE name_author LIKE 'Пас%')), '2'
FROM 
    book
    WHERE title = 'Лирика';

INSERT INTO buy_book(buy_id, book_id, amount)
SELECT '5', (SELECT book_id FROM book WHERE title ='Белая гвардия' AND author_id = (SELECT author_id 
FROM 
    author 
    WHERE name_author LIKE 'Бул%')), '1'
FROM 
    book
    WHERE title = 'Белая гвардия';

SELECT * FROM buy_book;

--4. Уменьшить количество тех книг на складе, которые были включены в заказ с номером 5.

UPDATE book AS b
INNER JOIN buy_book AS bb USING(book_id)
SET b.amount = b.amount - bb.amount
WHERE bb.buy_id = 5;

SELECT * FROM book;

--5. Создать счет (таблицу buy_pay) на оплату заказа с номером 5, в который включить название книг, их автора, цену, количество заказанных книг и  стоимость. Последний столбец назвать Стоимость. Информацию в таблицу занести в отсортированном по названиям книг виде.

CREATE TABLE buy_pay AS
SELECT title, name_author, price, buy_book.amount, book.price * buy_book.amount AS Стоимость
FROM 
    buy_book
    INNER JOIN book USING(book_id)
    INNER JOIN author USING (author_id)
WHERE buy_book.buy_id = 5
ORDER BY book.title;

SELECT * FROM buy_pay;

--6. Создать общий счет (таблицу buy_pay) на оплату заказа с номером 5. Куда включить номер заказа, количество книг в заказе (название столбца Количество) и его общую стоимость (название столбца Итого).  Для решения используйте ОДИН запрос.

CREATE TABLE buy_pay AS
SELECT buy_id, SUM(buy_book.amount) AS Количество , SUM(buy_book.amount * book.price) AS Итого
FROM 
    buy_book
    INNER JOIN book USING(book_id)
WHERE buy_book.buy_id = 5;
SELECT * FROM buy_pay;

--7. В таблицу buy_step для заказа с номером 5 включить все этапы из таблицы step, которые должен пройти этот заказ. В столбцы date_step_beg и date_step_end всех записей занести Null.

INSERT INTO buy_step(buy_id, step_id)
SELECT 5, step_id
FROM 
    buy 
    INNER JOIN buy_step USING(buy_id)
    CROSS JOIN step USING(step_id)
GROUP BY step_id;

SELECT * FROM buy_step;

--8. В таблицу buy_step занести дату 12.04.2020 выставления счета на оплату заказа с номером 5. Правильнее было бы занести не конкретную, а текущую дату. Это можно сделать с помощью функции Now(). Но при этом в разные дни будут вставляться разная дата, и задание нельзя будет проверить, поэтому  вставим дату 12.04.2020.

UPDATE buy_step
SET date_step_beg = '2020-04-12' WHERE step_id = 1;

SELECT * FROM buy_step
WHERE buy_id = 5;

UPDATE buy_step
SET date_step_beg='2020-04-12'
WHERE buy_id=5 and step_id=1;
SELECT*FROM buy_step;

--9. Завершить этап «Оплата» для заказа с номером 5, вставив в столбец date_step_end дату 13.04.2020, и начать следующий этап («Упаковка»), задав в столбце date_step_beg для этого этапа ту же дату. Реализовать два запроса для завершения этапа и начале следующего. Они должны быть записаны в общем виде, чтобы его можно было применять для любых этапов, изменив только текущий этап. Для примера пусть это будет этап «Оплата».

UPDATE buy_step 
SET date_step_end = "2020-04-13"
WHERE buy_id = 5 AND step_id = 1;
                                
UPDATE buy_step 
SET date_step_beg = "2020-04-13"
WHERE buy_id = 5 AND step_id = (SELECT step_id+1
                                FROM step
                                WHERE name_step = "Оплата");
SELECT * FROM buy_step;