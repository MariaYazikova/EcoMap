--таблица пользователей (возможно не нужна, но я её создавала с 
--мыслью, что должен храниться "хозяин" отзыва)
create table Users (
	user_id serial primary key,
);

--таблица пунктов приема
create table ReceptionPoints(
	point_id serial primary key,
	name varchar(50) not null, --название
	address text, --адресс
	contact_info text, --контакты(номер телефона, адрес, соц.сети)
	categories varchar(255), --материалы, которые может принять пункт
	cost_per_unit decimal(10, 2), --стоимость за единицу материала
	working_hours text, --график 
	notes text, --примечания (маркировка к примеру)
	latitude decimal(9, 6), --географическая широта 
	longitude decimal(9, 6), --географическая долгота
	location geography(Point, 4326) --хранение географических данных с использованием систем координат
);

--таблица отзывов
create table Reviews (
	review_id serial primary key,
	user_id int references Users(user_id), --связываем с пользователем
	point_id int references ReceptionPoints(point_id),--связываем с пунктом
	rating int check (rating >=1 and rating <=5),--рейтинг
	review_text text,--отзыв
	feedback boolean,--смог ли пользователь отнести материал (да/нет)
	visit_issue text,--если нет то почему
	date_of_review timestamp default current_timestamp,--текущая дата оставления отзыва
	--явное указание, что point_id внешний ключ, который 
	--гарантирует, что point_id в reviews ссылается на существующую
	--запись в таблице пукнтов приема. 
	constraint fk_point foreign key (point_id) references ReceptionPoints (point_id)
);

--запрос
select
    name,
	point_id,
	--вычисляем расстояние от пользователя (его долгота и широта будут передаваться в параметрах через питон,
	--обрабатываются через %s,%s) до пунктов приема
	ST_Distance(location, ST_SetSRID(ST_MakePoint(%s, %s), 4326)) as distance,
	--вычисляем рейтинг (возвращаем null, если отсутсвует, для дальнейшей обработки вывода в питоне "рейтинга пока нет")
    coalesce(avg(rating), NULL) as rating,
	--берем все отзывы о пункте, разделяем их через ';', если их нет, выводим соответствующее сообщение
    coalesce(string_agg(review_text, '; '),'Отзывов пока нет') as review_text
--данные берем из таблицы пунктов, где категория совпадает с выбранной пользоватем (передается параметром)
from ReceptionPoints
where categories like %s
--left join, чтобы все записи из ReceptionPoints были включены в результат, а если для пункта приема
--нет нужной информации в Reviews, то будут отправлены Null
left join Reviews on ReceptionPoints.point_id = Reviews.point_id
--группируем по айдишнику имени и локации
group by point_id, name, location
--сортируем в порядке возрастания дистанции
order by distance; 

	