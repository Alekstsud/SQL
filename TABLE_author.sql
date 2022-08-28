--1. Создать таблицу author следующей структуры:

CREATE TABLE author (
    author_id 	INT PRIMARY KEY AUTO_INCREMENT,
    name_author 	VARCHAR(50));

--2. Заполнить таблицу author. В нее включить следующих авторов:

INSERT INTO author (name_author)
    VALUES ('Булгаков М.А.'), 
        ('Достоевский Ф.М.'),
        ('Есенин С.А.'), 
        ('Пастернак Б.Л.');  

--3. Перепишите запрос на создание таблицы book , чтобы ее структура соответствовала структуре, показанной на логической схеме (таблица genre уже создана, порядок следования столбцов - как на логической схеме в таблице book, genre_id  - внешний ключ) . Для genre_id ограничение о недопустимости пустых значений не задавать. В качестве главной таблицы для описания поля  genre_idиспользовать таблицу genre следующей структуры:

CREATE TABLE genre (
    genre_id 	INT PRIMARY KEY AUTO_INCREMENT,
    name_genre 	VARCHAR(30)
);

CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50), 
    author_id INT NOT NULL, 
    genre_id INT, 
    price DECIMAL(8,2), 
    amount INT, 
    FOREIGN KEY (author_id)  REFERENCES author (author_id),
    FOREIGN KEY (genre_id)  REFERENCES genre (genre_id)
);

--4. Создать таблицу book той же структуры, что и на предыдущем шаге. Будем считать, что при удалении автора из таблицы author, должны удаляться все записи о книгах из таблицы book, написанные этим автором. А при удалении жанра из таблицы genre для соответствующей записи book установить значение Null в столбце genre_id. 

CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50), 
    author_id INT NOT NULL, 
    genre_id INT, 
    price DECIMAL(8,2), 
    amount INT, 
    FOREIGN KEY (author_id)  REFERENCES author (author_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id)  REFERENCES genre (genre_id) ON DELETE SET NULL
);

--5. Добавьте три последние записи (с ключевыми значениями 6, 7, 8) в таблицу book, первые 5 записей уже добавлены:

INSERT INTO book (title, author_id, genre_id, price, amount)
    VALUES ('Стихотворения и поэмы', 3, 2, 650.00, 15),
    ('Черный человек', 3, 2, 570.20, 6),
    ('Лирика', 4, 2, 518.99, 2);

--6. Вывести название, жанр и цену тех книг, количество которых больше 8, в отсортированном по убыванию цены виде

SELECT title, name_genre, price
    FROM genre INNER JOIN book
    ON genre.genre_id = book.genre_id
    WHERE amount > 8
    ORDER BY price DESC;

--7. Вывести все жанры, которые не представлены в книгах на складе.

SELECT name_genre
    FROM genre LEFT JOIN book
    ON genre.genre_id = book.genre_id
    WHERE title IS NULL;

--8. Необходимо в каждом городе провести выставку книг каждого автора в течение 2020 года. Дату проведения выставки выбрать случайным образом. Создать запрос, который выведет город, автора и дату проведения выставки. Последний столбец назвать Дата. Информацию вывести, отсортировав сначала в алфавитном порядке по названиям городов, а потом по убыванию дат проведения выставок.

SELECT name_city, name_author, 
    (DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 365) DAY)) as Дата
    FROM author CROSS JOIN city
    ORDER BY name_city, Дата DESC;

--9. Вывести информацию о тех книгах, их авторах и жанрах, цена которых принадлежит интервалу от 500  до 700 рублей  включительно.

SELECT title, name_author, name_genre, price, amount
    FROM author 
    INNER JOIN  book ON author.author_id = book.author_id
    INNER JOIN genre ON genre.genre_id = book.genre_id
    WHERE price BETWEEN 500 AND 700;

--10. Вывести информацию о книгах (жанр, книга, автор), относящихся к жанру, включающему слово «роман» в отсортированном по названиям книг виде.

SELECT name_genre, title, name_author
    FROM author 
    INNER JOIN  book ON author.author_id = book.author_id
    INNER JOIN genre ON genre.genre_id = book.genre_id
    WHERE name_genre LIKE 'роман'
    ORDER BY title;

--11. Посчитать количество экземпляров  книг каждого автора из таблицы author.  Вывести тех авторов,  количество книг которых меньше 10, в отсортированном по возрастанию количества виде. Последний столбец назвать Количество.

SELECT name_author, SUM(amount) AS Количество
    FROM author LEFT JOIN book
    on author.author_id = book.author_id
    GROUP BY name_author
    HAVING Количество < 10 OR SUM(amount) is NULL
    ORDER BY Количество;   

--12. получить всех авторов, общее количество книг которых максимально.

SELECT name_author, SUM(amount) as Количество
FROM 
    author INNER JOIN book
    on author.author_id = book.author_id
GROUP BY name_author
HAVING SUM(amount) = 
    (/* вычисляем максимальное из общего количества книг каждого автора */
    SELECT MAX(sum_amount) AS max_sum_amount
    FROM 
        (/* считаем количество книг каждого автора */
        SELECT author_id, SUM(amount) AS sum_amount 
        FROM book GROUP BY author_id
        ) query_in
    );

--13. Вывести в алфавитном порядке всех авторов, которые пишут только в одном жанре

SELECT name_author
FROM author 
    INNER JOIN book ON author.author_id = book.author_id
    INNER JOIN genre ON genre.genre_id = book.genre_id
GROUP BY name_author
    HAVING COUNT( DISTINCT(name_genre))=1;

--14. Вывести авторов, пишущих книги в самом популярном жанре. Указать этот жанр.

SELECT  name_author, name_genre
FROM 
    author 
    INNER JOIN book ON author.author_id = book.author_id
    INNER JOIN genre ON  book.genre_id = genre.genre_id
GROUP BY name_author,name_genre, genre.genre_id
HAVING genre.genre_id IN
         (/* выбираем автора, если он пишет книги в самых популярных жанрах*/
          SELECT query_in_1.genre_id
          FROM 
              ( /* выбираем код жанра и количество произведений, относящихся к нему */
                SELECT genre_id, SUM(amount) AS sum_amount
                FROM book
                GROUP BY genre_id
               )query_in_1
          INNER JOIN 
              ( /* выбираем запись, в которой указан код жанр с максимальным количеством книг */
                SELECT genre_id, SUM(amount) AS sum_amount
                FROM book
                GROUP BY genre_id
                ORDER BY sum_amount DESC
                LIMIT 1
               ) query_in_2
          ON query_in_1.sum_amount= query_in_2.sum_amount
         );   

--15. Вывести информацию о книгах (название книги, фамилию и инициалы автора, название жанра, цену и количество экземпляров книг), написанных в самых популярных жанрах, в отсортированном в алфавитном порядке по названию книг виде. Самым популярным считать жанр, общее количество экземпляров книг которого на складе максимально.

SELECT title, name_author, name_genre, price, amount
FROM 
    author 
    INNER JOIN book ON author.author_id = book.author_id
    INNER JOIN genre ON  book.genre_id = genre.genre_id
WHERE   genre.genre_id IN 
        (SELECT genre_id
        FROM book
        GROUP BY genre_id
        HAVING SUM(amount) = (
            SELECT SUM(amount) AS sum_amount
            FROM book
            GROUP BY genre_id
            HAVING sum_amount
            LIMIT 1))
ORDER BY title;

--16.  Если в таблицах supply  и book есть одинаковые книги, которые имеют равную цену,  вывести их название и автора, а также посчитать общее количество экземпляров книг в таблицах supply и book,  столбцы назвать Название, Автор  и Количество.

SELECT book.title AS Название, author.name_author AS Автор, 
       book.amount + supply.amount AS Количество
FROM author 
     INNER JOIN book USING (author_id)   
     INNER JOIN supply  ON book.title = supply.title 
                       AND supply.amount = book.amount
;

--17. Для книг, которые уже есть на складе (в таблице book), но по другой цене, чем в поставке (supply),  необходимо в таблице book увеличить количество на значение, указанное в поставке,  и пересчитать цену. А в таблице  supply обнулить количество этих книг.

UPDATE book 
    INNER JOIN author ON author.author_id = book.author_id
    INNER JOIN supply ON book.title = supply.title 
                     AND supply.author = author.name_author
SET book.price = (book.price * book.amount + supply.price * supply.amount)/(book.amount + supply.amount),
    book.amount = book.amount + supply.amount,
    supply.amount = 0 
WHERE book.price <> supply.price;
SELECT * FROM book;
SELECT * FROM supply;

--18. Включить новых авторов в таблицу author с помощью запроса на добавление, а затем вывести все данные из таблицы author.  Новыми считаются авторы, которые есть в таблице supply, но нет в таблице author.

INSERT INTO author (name_author)
SELECT supply.author
FROM author 
    RIGHT JOIN supply on author.name_author = supply.author
    WHERE name_author IS NUll;
SELECT * FROM author;

--19. Добавить новые книги из таблицы supply в таблицу book на основе сформированного выше запроса. Затем вывести для просмотра таблицу book.

INSERT INTO book (title, author_id, price, amount)
SELECT title, author_id, price, amount
FROM author 
    INNER JOIN supply ON author.name_author = supply.author
WHERE amount <> 0;
SELECT * FROM book;

--20. Занести для книги «Стихотворения и поэмы» Лермонтова жанр «Поэзия», а для книги «Остров сокровищ» Стивенсона - «Приключения». (Использовать два запроса).

UPDATE book
SET genre_id = 
    (
    SELECT genre_id 
    FROM genre 
    WHERE name_genre = 'Поэзия'
    )
WHERE book_id = 10;
UPDATE book
SET genre_id = 
    (
    SELECT genre_id 
    FROM genre 
    WHERE name_genre = 'Приключения'
    )
WHERE book_id = 11;
SELECT * FROM book;

--21. Удалить всех авторов и все их книги, общее количество книг которых меньше 20.

DELETE FROM author
WHERE author_id IN( 
    SELECT author_id
    FROM book
    GROUP BY author_id
    HAVING SUM(amount) <= 20
    );

SELECT * FROM author;

SELECT * FROM book;

--22. Удалить все жанры, к которым относится меньше 4-х книг. В таблице book для этих жанров установить значение Null.

DELETE FROM genre
WHERE genre_id IN 
    ( 
    SELECT genre_id
    FROM book
    GROUP BY genre_id
    HAVING COUNT(amount) < 4   
    );

SELECT * FROM genre;

SELECT * FROM book;

--23. Удалить всех авторов, которые пишут в жанре "Поэзия". Из таблицы book удалить все книги этих авторов. В запросе для отбора авторов использовать полное название жанра, а не его id.

DELETE FROM author
USING 
    book 
    INNER JOIN author ON author.author_id = book.author_id
    INNER JOIN genre ON book.genre_id = genre.genre_id
                    AND name_genre = 'Поэзия';

SELECT * FROM author;

SELECT * FROM book;
