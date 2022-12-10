#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма, который они ценили."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select us1.name, us2.name, movies.title  from 
ratings a, ratings b on a.movie_id = b.movie_id 
inner join movies on movies.id = a.movie_id 
inner join users us1 on us1.id = a.user_id 
inner join users us2 on us2.id = b.user_id 
where a.user_id < b.user_id limit 50;"
echo " " 

echo "2. Найти 10 самых старых оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select  substr(users.name, 0, instr(users.name, ' ')) as Name, movies.title, date(min(timestamp), 'unixepoch') as date, rating from ratings 
inner join users on users.id = ratings.user_id 
inner join movies on movies.id = ratings.movie_id 
group by user_id 
order by timestamp 
limit 10;"
echo " " 



echo "3. Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке "Рекомендуем" для фильмов должно быть написано "Да" или "Нет"."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select title, year, recs.rating as rating, recs.recommendation as recommended
from movies 
inner join 
(select avg_vals.movie_id as movie_id, avg_vals.mid_val as rating,
	case avg_vals.mid_val
        	when max_and_min.max_val then 'Yes'
        	when max_and_min.min_val then 'No'
        	end 'recommendation' 
	from 
	(select movie_id, avg(rating) as mid_val from ratings group by movie_id) avg_vals 
	inner join 
	(select max(mid_val) as max_val, min(mid_val) as min_val from 
        	(select movie_id, avg(rating) as mid_val from ratings group by movie_id)) max_and_min 
		on avg_vals.mid_val==max_and_min.max_val OR avg_vals.mid_val==max_and_min.min_val) recs
on movies.id==movie_id order by year, title;"
echo " "


echo "4. Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-мужчины в период с 2011 по 2014 год."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select count(ratings.rating) as 'Number of men', avg(ratings.rating) as 'Average mark'
from ratings
         inner join users on ratings.user_id = users.id
where users.gender = 'male'
  and cast(strftime('%Y', date(timestamp, 'unixepoch')) as integer) between 2011 and 2014"
echo " " 


echo "5. Составить список фильмов с указанием средней оценки и количества пользователей, которые их оценили. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select movies.title as movie, avg(ratings.rating) as avg_rating, count(ratings.user_id) as count_users
from movies
         inner join ratings on movies.id = ratings.movie_id
group by movies.id
order by movies.year, movies.title
limit 20"
echo " " 


echo "6. Определить самый распространенный жанр фильма и количество фильмов в этом жанре. Отдельную таблицу для жанров не использовать, жанры нужно извлекать из таблицы movies."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "with recursive subGenr(st, subst) as (
select genres as st, genres as subst from movies
union all
select 
case
  when instr(a.subst, '|') != 0 then substr(a.subst, 0, instr(a.subst, '|'))
  else a.subst
  end 'st',
case
  when instr(a.subst, '|') != 0 then substr(a.subst, instr(a.subst, '|') + 1)
  else 'del'
  end 'subst' 
  from subGenr a where subst != 'del'
)
select st as 'Most common genre', max(num) as 'Number of movies' from (select st, count(st) as num from subGenr where instr(st, '|') == 0 and st != subst group by st);"
echo " " 


echo "7.  Вывести список из 10 последних зарегистрированных пользователей в формате 'Фамилия Имя|Дата регистрации' (сначала фамилия, потом имя)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "select substr(users.name, instr(users.name, ' ') + 1) ||  '  ' ||  substr(users.name, 0, instr(users.name, ' '))  ||  '|' ||  users.register_date as 'Фамилия Имя|Дата регистрации'
from users
order by users.register_date desc
limit 10"
echo " " 


echo "8. С помощью рекурсивного CTE определить, на какие дни недели приходился ваш день рождения в каждом году."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "with recursive days(day) as (
select strftime('%Y-%m-%d', '2002-02-10') as day
union all
select strftime('%Y-%m-%d', day, '+1 year') from days where strftime('%Y-%m-%d', day, '+1 year') < strftime('%Y-%m-%d', 'now'))
select case strftime('%w', day)
when '0' then 'Воскресенье'
when '1' then 'Понедельник'
when '2' then 'Вторник'
when '3' then 'Среда'
when '4' then 'Четверг'
when '5' then 'Пятница'
when '6' then 'Суббота'
end 'День недели', strftime('%Y',  day) as 'Год'
from days"
echo " " 
