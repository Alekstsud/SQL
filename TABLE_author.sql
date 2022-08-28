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

12. 
