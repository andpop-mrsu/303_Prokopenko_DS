#!/bin/bash

chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Составить список фильмов, имеющих хотя бы одну оценку. Список фильмов отсортировать по году выпуска и по названиям. В списке оставить первые 10 фильмов."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT movies.title, movies.year FROM movies INNER JOIN ratings ON ratings.movie_id=movies.id GROUP BY movies.title HAVING count(*) >= 1 ORDER BY movies.year, movies.title LIMIT 10;"
echo " "


echo "2. Вывести список всех пользователей, фамилии (не имена!) которых начинаются на букву 'A'. Полученный список отсортировать по дате регистрации. В списке оставить первых 5 пользователей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT name FROM users WHERE substr(substr(name, instr(name, ' ')+1), 1, 1)='A' ORDER BY register_date LIMIT 10;"
echo " "


echo "3. Написать запрос, возвращающий информацию о рейтингах в более читаемом формате: имя и фамилия эксперта, название фильма, год выпуска, оценка и дата оценки в формате ГГГГ-ММ-ДД. Отсортировать данные по имени эксперта, затем названию фильма и оценке. В списке оставить первые 50 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT name, title, year, rating, date(timestamp, 'unixepoch') AS date FROM users INNER JOIN ratings ON users.id=ratings.user_id INNER JOIN movies ON ratings.movie_id=movies.id ORDER BY substr(name, 1, instr(name, ' ')-1), title, rating LIMIT 50;"
echo " "


echo "4. Вывести список фильмов с указанием тегов, которые были им присвоены пользователями. Сортировать по году выпуска, затем по названию фильма, затем по тегу. В списке оставить первые 40 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT title, tag FROM tags INNER JOIN movies ON movie_id=movies.id ORDER BY year, title, tag LIMIT 40;"
echo " "


echo "5. Вывести список самых свежих фильмов. В список должны войти все фильмы последнего года выпуска, имеющиеся в базе данных. Запрос должен быть универсальным, не зависящим от исходных данных (нужный год выпуска должен определяться в запросе, а не жестко задаваться)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT title FROM movies WHERE year=(select max(year) FROM movies);"
echo " "


echo "6. Найти все драмы, выпущенные после 2005 года, которые понравились женщинам (оценка не ниже 4.5). Для каждого фильма в этом списке вывести название, год выпуска и количество таких оценок. Результат отсортировать по году выпуска и названию фильма."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select title, year, count(title) from movies inner join ratings on movies.id=ratings.movie_id inner join users on users.id=ratings.user_id where ratings.rating>=4.5 and gender='female' and instr(movies.genres, 'Drama')!=0 and year>2005 group by title order by year, title;"
echo " "



echo "7. Провести анализ востребованности ресурса - вывести количество пользователей, регистрировавшихся на сайте в каждом году. Найти, в каких годах регистрировалось больше всего и меньше всего пользователей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT year, num as 'Users number' from (select strftime('%Y', register_date) as 'year', count(*) as 'num' from users group by strftime('%Y', register_date));
SELECT case num 
	when max(num) then num 
	end 'Highest number of users',
year from (select strftime('%Y', register_date) as 'year', count(*) as 'num' from users group by strftime('%Y', register_date));
SELECT case num 
	when min(num) 
	then num end 'Lowest number of users', 
year from (select strftime('%Y', register_date) as 'year', count(*) as 'num' from users group by strftime('%Y', register_date));"
echo " "
