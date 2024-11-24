--таблица пользователей (возможно не нужна, но я её создавала с 
--мыслью, что должен храниться "хозяин" отзыва)
create table Users (
	user_id serial primary key,
);

--таблица категорий
create table Categories (
	category_id serial primary key,
	name varchar(50) not null --название категории
);

--таблица материалов (cвязываем с категорией)
create table Materials(
	material_id serial primary key,
	category_id int references Categories(category_id) on delete cascade,
);

--таблица пунктов приема
create table ReceptionPoints(
	point_id serial primary key,
	name varchar(50) not null, --название
	district text, --район
	address text, --адресс
	working_hours text, --график 
	phone_number text, --номер телефона
	website text, --сайт
	latitude decimal(9, 6), --географическая широта 
	longitude decimal(9, 6), --географическая долгота
	location geography(Point, 4326) --хранение географических данных с использованием систем координат
);

--таблица связей пунктов приема и материалов
create table ReceptionPointMaterials(
	point_id int references ReceptionPoints(point_id) on delete cascade,
	material_id int references Materials(material_id) on delete cascade,
	custom_name varchar(50), --название материала
	custom_memo txt, --памятка
	cost_per_unit decimal(10,2),--стоимость за единицу
	unit varchar(10) --единица измерения (шт, кг)
	primary key (point_id, material_id)
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
);

--запрос
select
    rp.name as point_name,
	rp.district,
	rp.address,
	rp.working_hours,
	rp.phone_number,
	rp.website,
	--вычисляем расстояние от пользователя (его долгота и широта будут передаваться в параметрах через питон,
	--обрабатываются через %s,%s) до пунктов приема
	ST_Distance(rp.location, ST_SetSRID(ST_MakePoint(%s, %s), 4326)) as distance,
	--вычисляем рейтинг (возвращаем null, если отсутсвует, для дальнейшей обработки вывода в питоне "рейтинга пока нет")
    coalesce(avg(r.rating), NULL) as rating,
	--берем все отзывы о пункте, разделяем их через ';', если их нет, выводим соответствующее сообщение
    coalesce(string_agg(r.review_text, '; '),'Отзывов пока нет') as review_text
	coalesce(string_agg(rpm.custom_name || ' (' || rpm.custom_memo || ') - ' || 
                        coalesce(rpm.cost_per_unit::text, 'не указана') || ' ' || 
                        coalesce(rpm.unit, 'не указана'), '; '), 'Материалов нет') as materials
from ReceptionPoints rp
join ReceptionPointMaterials rpm on rp.point_id = rpm.point_id
join Materials m on rpm.material_id = m.material_id
left join Reviews r on rp.point_id = r.point_id
left join Categories c on m.category_id = c.category_id
where c.name like %s  -- Фильтрация по категории
group by rp.point_id
order by distance;
