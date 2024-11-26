--подключаем расширение postgis
create extension if not exists postgis;

--таблица пользователей (возможно не нужна, но я её создавала с 
--мыслью, что должен храниться "хозяин" отзыва)
create table if not exists Users (
	user_id serial primary key
);

--таблица категорий
create table if not exists Categories (
	category_id serial primary key,
	name varchar(50) not null --название категории
);

--таблица материалов (cвязываем с категорией)
create table if not exists Materials(
	material_id int primary key,
	category_id int references Categories(category_id) on delete cascade
);

--индекс для связи материалов с категорией
create index if not exists idx_materials_category_id on Materials(category_id);

--таблица пунктов приема
create table if not exists ReceptionPoints(
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

--индекс для оптимизации поиска по географическим данным
create index if not exists idx_reception_points_location on ReceptionPoints using gist(location);

--таблица связей пунктов приема и материалов
create table if not exists ReceptionPointMaterials(
	point_id int references ReceptionPoints(point_id) on delete cascade,
	material_id int references Materials(material_id) on delete cascade,
	custom_name text, --название материала
	custom_memo text, --памятка
	cost_per_unit decimal(10,2),--стоимость за единицу
	unit varchar(10), --единица измерения (шт, кг)
	primary key (point_id, material_id)
);

--индекс для оптимизации поиска материалов в пунктах приёма
create index if not exists id_rpm_point_material on ReceptionPointMaterials(point_id, material_id);

--таблица отзывов
create table if not exists Reviews (
	review_id serial primary key,
	user_id int references Users(user_id), --связываем с пользователем
	point_id int references ReceptionPoints(point_id),--связываем с пунктом
	rating int check (rating >=1 and rating <=5),--рейтинг
	review_text text,--отзыв
	feedback boolean,--смог ли пользователь отнести материал (да/нет)
	visit_issue text,--если нет то почему
	date_of_review timestamp default current_timestamp--текущая дата оставления отзыва
);

--индекс для связи отзывов с пунктами приёма
create index if not exists idx_reviews_point_id on Reviews(point_id);

insert into Categories (name)
select name from (values
	('Картон'),
	('Макулатура'),
	('Плёнка'),
	('Пластик'),
	('Металл'),
	('Стеклотара'),
	('Батарейки'),
	('Аккумуляторы'),
	('Техника'),
	('Дерево'),
	('Одежда'),
	('Книги'),
	('Автомобильные катализаторы')
) as new_categories(name)
where not exists (
	select 1 from Categories c where c.name = new_categories.name
);

insert into Materials (material_id, category_id)
select material_id, category_id from (values
	(1, (select category_id from Categories where name = 'Картон')),
	(2, (select category_id from Categories where name = 'Макулатура')),
	(3, (select category_id from Categories where name = 'Макулатура')),
	(4, (select category_id from Categories where name = 'Плёнка')),
	(5, (select category_id from Categories where name = 'Плёнка')),
	(6, (select category_id from Categories where name = 'Пластик')),
	(7, (select category_id from Categories where name = 'Пластик')),
	(8, (select category_id from Categories where name = 'Металл')),
	(9, (select category_id from Categories where name = 'Стеклотара')),
	(10, (select category_id from Categories where name = 'Батарейки')),
	(11, (select category_id from Categories where name = 'Аккумуляторы')),
	(12, (select category_id from Categories where name = 'Техника')),
	(13, (select category_id from Categories where name = 'Техника')),
	(14, (select category_id from Categories where name = 'Техника')),
	(15, (select category_id from Categories where name = 'Техника')),
	(16, (select category_id from Categories where name = 'Техника')),
	(17, (select category_id from Categories where name = 'Техника')),
	(18, (select category_id from Categories where name = 'Техника')),
	(19, (select category_id from Categories where name = 'Техника')),
	(20, (select category_id from Categories where name = 'Техника')),
	(21, (select category_id from Categories where name = 'Техника')),
	(22, (select category_id from Categories where name = 'Техника')),
	(23, (select category_id from Categories where name = 'Техника')),
	(24, (select category_id from Categories where name = 'Техника')),
	(25, (select category_id from Categories where name = 'Техника')),
	(26, (select category_id from Categories where name = 'Техника')),
	(27, (select category_id from Categories where name = 'Техника')),

	(28, (select category_id from Categories where name = 'Картон')),
	(29, (select category_id from Categories where name = 'Картон')),
	(30, (select category_id from Categories where name = 'Картон')),
	(31, (select category_id from Categories where name = 'Макулатура')),
	(32, (select category_id from Categories where name = 'Макулатура')),
	(33, (select category_id from Categories where name = 'Макулатура')),
	(34, (select category_id from Categories where name = 'Макулатура')),
	(35, (select category_id from Categories where name = 'Плёнка')),
	(36, (select category_id from Categories where name = 'Плёнка')),
	(37, (select category_id from Categories where name = 'Плёнка')),
	(38, (select category_id from Categories where name = 'Пластик')),
	(39, (select category_id from Categories where name = 'Пластик')),
	(40, (select category_id from Categories where name = 'Пластик')),
	(41, (select category_id from Categories where name = 'Дерево')),

	(42, (select category_id from Categories where name = 'Металл')),
	(43, (select category_id from Categories where name = 'Металл')),
	(44, (select category_id from Categories where name = 'Стеклотара')),
	(45, (select category_id from Categories where name = 'Стеклотара')),
	(46, (select category_id from Categories where name = 'Картон')),
	(47, (select category_id from Categories where name = 'Макулатура')),
	(48, (select category_id from Categories where name = 'Макулатура')),
	(49, (select category_id from Categories where name = 'Макулатура')),
	(50, (select category_id from Categories where name = 'Пластик')),
	(51, (select category_id from Categories where name = 'Пластик')),
	(52, (select category_id from Categories where name = 'Пластик')),
	(53, (select category_id from Categories where name = 'Пластик')),

	(54, (select category_id from Categories where name = 'Макулатура')),
	(55, (select category_id from Categories where name = 'Макулатура')),
	(56, (select category_id from Categories where name = 'Макулатура')),
	(57, (select category_id from Categories where name = 'Макулатура')),
	(58, (select category_id from Categories where name = 'Макулатура')),
	(59, (select category_id from Categories where name = 'Макулатура')),
	(60, (select category_id from Categories where name = 'Макулатура')),
	(61, (select category_id from Categories where name = 'Макулатура')),
	(62, (select category_id from Categories where name = 'Макулатура')),
	(63, (select category_id from Categories where name = 'Макулатура')),
	(64, (select category_id from Categories where name = 'Макулатура')),
	(65, (select category_id from Categories where name = 'Макулатура')),
	(66, (select category_id from Categories where name = 'Макулатура')),
	(67, (select category_id from Categories where name = 'Макулатура')),
	(68, (select category_id from Categories where name = 'Макулатура')),
	(69, (select category_id from Categories where name = 'Картон')),
	(70, (select category_id from Categories where name = 'Картон')),
	(71, (select category_id from Categories where name = 'Картон')),
	(72, (select category_id from Categories where name = 'Картон')),
	(73, (select category_id from Categories where name = 'Картон')),
	(74, (select category_id from Categories where name = 'Картон')),
	(75, (select category_id from Categories where name = 'Картон')),
	(76, (select category_id from Categories where name = 'Картон')),
	(77, (select category_id from Categories where name = 'Картон')),
	(78, (select category_id from Categories where name = 'Картон')),
	(79, (select category_id from Categories where name = 'Стеклотара')),
	(80, (select category_id from Categories where name = 'Стеклотара')),
	(81, (select category_id from Categories where name = 'Стеклотара')),
	(82, (select category_id from Categories where name = 'Стеклотара')),
	(83, (select category_id from Categories where name = 'Стеклотара')),
	(84, (select category_id from Categories where name = 'Стеклотара')),
	(85, (select category_id from Categories where name = 'Металл')),
	(86, (select category_id from Categories where name = 'Металл')),
	(87, (select category_id from Categories where name = 'Металл')),
	(88, (select category_id from Categories where name = 'Металл')),
	(89, (select category_id from Categories where name = 'Металл')),
	(90, (select category_id from Categories where name = 'Металл')),
	(91, (select category_id from Categories where name = 'Металл')),
	(92, (select category_id from Categories where name = 'Металл')),
	(93, (select category_id from Categories where name = 'Металл')),
	(94, (select category_id from Categories where name = 'Металл')),
	(95, (select category_id from Categories where name = 'Пластик')),
	(96, (select category_id from Categories where name = 'Пластик')),
	(97, (select category_id from Categories where name = 'Пластик')),
	(98, (select category_id from Categories where name = 'Пластик')),
	(99, (select category_id from Categories where name = 'Пластик')),
	(100, (select category_id from Categories where name = 'Пластик')),
	(101, (select category_id from Categories where name = 'Пластик')),
	(102, (select category_id from Categories where name = 'Пластик')),
	(103, (select category_id from Categories where name = 'Пластик')),
	(104, (select category_id from Categories where name = 'Пластик')),
	(105, (select category_id from Categories where name = 'Пластик')),
	(106, (select category_id from Categories where name = 'Пластик')),
	(107, (select category_id from Categories where name = 'Пластик')),
	(108, (select category_id from Categories where name = 'Пластик')),
	(109, (select category_id from Categories where name = 'Пластик')),
	(110, (select category_id from Categories where name = 'Пластик')),
	(111, (select category_id from Categories where name = 'Пластик')),
	(112, (select category_id from Categories where name = 'Пластик')),
	(113, (select category_id from Categories where name = 'Пластик')),
	(114, (select category_id from Categories where name = 'Пластик')),
	(115, (select category_id from Categories where name = 'Пластик')),
	(116, (select category_id from Categories where name = 'Пластик')),
	(117, (select category_id from Categories where name = 'Пластик')),
	(118, (select category_id from Categories where name = 'Пластик')),
	(119, (select category_id from Categories where name = 'Пластик')),
	(120, (select category_id from Categories where name = 'Пластик')),
	(121, (select category_id from Categories where name = 'Пластик')),
	(122, (select category_id from Categories where name = 'Батарейки')),
	(123, (select category_id from Categories where name = 'Аккумуляторы')),
	(124, (select category_id from Categories where name = 'Аккумуляторы')),
	(125, (select category_id from Categories where name = 'Техника')),
	(126, (select category_id from Categories where name = 'Техника')),
	(127, (select category_id from Categories where name = 'Техника')),
	(128, (select category_id from Categories where name = 'Техника')),
	(129, (select category_id from Categories where name = 'Техника')),
	(130, (select category_id from Categories where name = 'Техника')),
	(131, (select category_id from Categories where name = 'Техника')),

	(132, (select category_id from Categories where name = 'Металл')),
	(133, (select category_id from Categories where name = 'Металл')),
	(134, (select category_id from Categories where name = 'Металл')),
	(135, (select category_id from Categories where name = 'Металл')),
	(136, (select category_id from Categories where name = 'Металл')),
	(137, (select category_id from Categories where name = 'Металл')),
	(138, (select category_id from Categories where name = 'Металл')),
	(139, (select category_id from Categories where name = 'Металл')),
	(140, (select category_id from Categories where name = 'Металл')),
	(141, (select category_id from Categories where name = 'Металл')),
	(142, (select category_id from Categories where name = 'Металл')),
	(143, (select category_id from Categories where name = 'Металл')),
	(144, (select category_id from Categories where name = 'Металл')),
	(145, (select category_id from Categories where name = 'Металл')),
	(146, (select category_id from Categories where name = 'Металл')),
	(147, (select category_id from Categories where name = 'Металл')),
	(148, (select category_id from Categories where name = 'Металл')),
	(149, (select category_id from Categories where name = 'Металл')),
	(150, (select category_id from Categories where name = 'Металл')),
	(151, (select category_id from Categories where name = 'Металл')),
	(152, (select category_id from Categories where name = 'Металл')),
	(153, (select category_id from Categories where name = 'Металл')),
	(154, (select category_id from Categories where name = 'Металл')),
	(155, (select category_id from Categories where name = 'Металл')),
	(156, (select category_id from Categories where name = 'Металл')),
	(157, (select category_id from Categories where name = 'Металл')),
	(158, (select category_id from Categories where name = 'Металл')),
	(159, (select category_id from Categories where name = 'Металл')),
	(160, (select category_id from Categories where name = 'Металл')),
	(161, (select category_id from Categories where name = 'Металл')),
	(162, (select category_id from Categories where name = 'Металл')),
	(163, (select category_id from Categories where name = 'Металл')),
	(164, (select category_id from Categories where name = 'Металл')),
	(165, (select category_id from Categories where name = 'Металл')),
	(166, (select category_id from Categories where name = 'Металл')),

	(167, (select category_id from Categories where name = 'Одежда')),
	(168, (select category_id from Categories where name = 'Одежда')),
	(169, (select category_id from Categories where name = 'Одежда')),
	(170, (select category_id from Categories where name = 'Одежда')),
	(171, (select category_id from Categories where name = 'Одежда')),
	(172, (select category_id from Categories where name = 'Одежда')),
	(173, (select category_id from Categories where name = 'Одежда')),
	(174, (select category_id from Categories where name = 'Одежда')),

	(175, (select category_id from Categories where name = 'Одежда')),
	(176, (select category_id from Categories where name = 'Одежда')),
	(177, (select category_id from Categories where name = 'Одежда')),

	(178, (select category_id from Categories where name = 'Одежда')),
	(179, (select category_id from Categories where name = 'Одежда')),
	(180, (select category_id from Categories where name = 'Одежда')),
	(181, (select category_id from Categories where name = 'Книги')),

	(182, (select category_id from Categories where name = 'Металл')),
	(183, (select category_id from Categories where name = 'Металл')),
	(184, (select category_id from Categories where name = 'Металл')),
	(185, (select category_id from Categories where name = 'Металл')),
	(186, (select category_id from Categories where name = 'Металл')),
	(187, (select category_id from Categories where name = 'Металл')),
	(188, (select category_id from Categories where name = 'Металл')),
	(189, (select category_id from Categories where name = 'Металл')),
	(190, (select category_id from Categories where name = 'Металл')),
	(191, (select category_id from Categories where name = 'Металл')),
	(192, (select category_id from Categories where name = 'Металл')),
	(193, (select category_id from Categories where name = 'Металл')),
	(194, (select category_id from Categories where name = 'Макулатура')),
	(195, (select category_id from Categories where name = 'Макулатура')),
	(196, (select category_id from Categories where name = 'Макулатура')),
	(197, (select category_id from Categories where name = 'Макулатура')),
	(198, (select category_id from Categories where name = 'Макулатура')),
	(199, (select category_id from Categories where name = 'Макулатура')),
	(200, (select category_id from Categories where name = 'Макулатура')),
	(201, (select category_id from Categories where name = 'Макулатура')),
	(202, (select category_id from Categories where name = 'Макулатура')),
	(203, (select category_id from Categories where name = 'Плёнка')),
	(204, (select category_id from Categories where name = 'Плёнка')),
	(205, (select category_id from Categories where name = 'Плёнка')),
	(206, (select category_id from Categories where name = 'Плёнка')),
	(207, (select category_id from Categories where name = 'Плёнка')),
	(208, (select category_id from Categories where name = 'Пластик')),
	(209, (select category_id from Categories where name = 'Пластик')),

	(210, (select category_id from Categories where name = 'Металл')),
	(211, (select category_id from Categories where name = 'Металл')),
	(212, (select category_id from Categories where name = 'Металл')),
	(213, (select category_id from Categories where name = 'Металл')),
	(214, (select category_id from Categories where name = 'Металл')),
	(215, (select category_id from Categories where name = 'Металл')),
	(216, (select category_id from Categories where name = 'Металл')),
	(217, (select category_id from Categories where name = 'Металл')),
	(218, (select category_id from Categories where name = 'Металл')),
	(219, (select category_id from Categories where name = 'Металл')),
	(220, (select category_id from Categories where name = 'Металл')),
	(221, (select category_id from Categories where name = 'Металл')),
	(222, (select category_id from Categories where name = 'Металл')),
	(223, (select category_id from Categories where name = 'Металл')),
	(224, (select category_id from Categories where name = 'Металл')),

	(225, (select category_id from Categories where name = 'Макулатура')),
	(226, (select category_id from Categories where name = 'Макулатура')),
	(227, (select category_id from Categories where name = 'Макулатура')),
	(228, (select category_id from Categories where name = 'Макулатура')),
	(229, (select category_id from Categories where name = 'Макулатура')),
	(230, (select category_id from Categories where name = 'Пластик')),
	(231, (select category_id from Categories where name = 'Пластик')),
	(232, (select category_id from Categories where name = 'Плёнка')),
	(233, (select category_id from Categories where name = 'Пластик')),
	(234, (select category_id from Categories where name = 'Металл')),
	(235, (select category_id from Categories where name = 'Дерево')),

	(236, (select category_id from Categories where name = 'Автомобильные катализаторы')),

	(237, (select category_id from Categories where name = 'Металл')),
	(238, (select category_id from Categories where name = 'Металл')),
	(239, (select category_id from Categories where name = 'Металл')),
	(240, (select category_id from Categories where name = 'Металл')),
	(241, (select category_id from Categories where name = 'Металл')),
	(242, (select category_id from Categories where name = 'Металл')),
	(243, (select category_id from Categories where name = 'Металл')),
	(244, (select category_id from Categories where name = 'Металл')),
	(245, (select category_id from Categories where name = 'Металл')),
	(246, (select category_id from Categories where name = 'Металл')),
	(247, (select category_id from Categories where name = 'Металл')),
	(248, (select category_id from Categories where name = 'Металл')),

	(249, (select category_id from Categories where name = 'Автомобильные катализаторы')),
	(250, (select category_id from Categories where name = 'Автомобильные катализаторы')),
	(251, (select category_id from Categories where name = 'Автомобильные катализаторы')),
	(252, (select category_id from Categories where name = 'Автомобильные катализаторы')),
	(253, (select category_id from Categories where name = 'Автомобильные катализаторы')),

	(254, (select category_id from Categories where name = 'Металл')),
	(255, (select category_id from Categories where name = 'Металл')),
	(256, (select category_id from Categories where name = 'Металл')),
	(257, (select category_id from Categories where name = 'Металл')),
	(258, (select category_id from Categories where name = 'Металл')),
	(259, (select category_id from Categories where name = 'Металл')),
	(260, (select category_id from Categories where name = 'Металл')),
	(261, (select category_id from Categories where name = 'Металл')),
	(262, (select category_id from Categories where name = 'Металл')),
	(263, (select category_id from Categories where name = 'Металл')),
	(264, (select category_id from Categories where name = 'Металл')),
	(265, (select category_id from Categories where name = 'Металл')),
	(266, (select category_id from Categories where name = 'Металл')),
	(267, (select category_id from Categories where name = 'Металл')),
	(268, (select category_id from Categories where name = 'Металл')),

	(269, (select category_id from Categories where name = 'Металл')),
	(270, (select category_id from Categories where name = 'Металл')),
	(271, (select category_id from Categories where name = 'Металл')),
	(272, (select category_id from Categories where name = 'Металл')),
	(273, (select category_id from Categories where name = 'Металл')),
	(274, (select category_id from Categories where name = 'Металл')),
	(275, (select category_id from Categories where name = 'Металл')),
	(276, (select category_id from Categories where name = 'Металл')),
	(277, (select category_id from Categories where name = 'Металл')),
	(278, (select category_id from Categories where name = 'Металл')),
	(279, (select category_id from Categories where name = 'Металл')),
	(280, (select category_id from Categories where name = 'Металл')),
	(281, (select category_id from Categories where name = 'Металл')),
	(282, (select category_id from Categories where name = 'Металл')),
	(283, (select category_id from Categories where name = 'Металл')),
	(284, (select category_id from Categories where name = 'Металл')),
	(285, (select category_id from Categories where name = 'Металл')),
	(286, (select category_id from Categories where name = 'Металл')),
	(287, (select category_id from Categories where name = 'Металл')),
	(288, (select category_id from Categories where name = 'Металл')),
	(289, (select category_id from Categories where name = 'Металл')),
	(290, (select category_id from Categories where name = 'Металл')),
	(291, (select category_id from Categories where name = 'Металл')),
	(292, (select category_id from Categories where name = 'Металл')),
	(293, (select category_id from Categories where name = 'Металл')),
	(294, (select category_id from Categories where name = 'Металл')),
	(295, (select category_id from Categories where name = 'Металл')),
	(296, (select category_id from Categories where name = 'Металл')),
	(297, (select category_id from Categories where name = 'Металл')),
	(298, (select category_id from Categories where name = 'Металл')),
	(299, (select category_id from Categories where name = 'Металл')),
	(300, (select category_id from Categories where name = 'Металл')),
	(301, (select category_id from Categories where name = 'Металл')),
	(302, (select category_id from Categories where name = 'Металл')),
	(303, (select category_id from Categories where name = 'Металл')),
	(304, (select category_id from Categories where name = 'Металл')),
	(305, (select category_id from Categories where name = 'Металл'))
	
) as new_materials(material_id, category_id)
where not exists (
	select 1 from Materials m where m.material_id = new_materials.material_id
);

insert into ReceptionPoints(name, district, address, working_hours, phone_number, website, latitude, longitude, location)
select name, district, address, working_hours, phone_number, website, latitude, longitude, location
from (values
	('Исток', 'Автозаводский', 'пр. Кирова, 22а/1', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-32-23', 'https://istoknn.ru/', 56.251004, 43.843491, ST_SetSRID(ST_MakePoint(43.843491, 56.251004), 4326)),
	('Исток', 'Автозаводский', 'ул. Политбойцов, у д. 19к2', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-32-23', 'https://istoknn.ru/', 56.262437, 43.855499, ST_SetSRID(ST_MakePoint(43.855499, 56.262437), 4326)),
	('Исток', 'Автозаводский', 'ул. Львовская, у д. 13А', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-32-23', 'https://istoknn.ru/', 56.268506, 43.880111, ST_SetSRID(ST_MakePoint(43.880111, 56.268506), 4326)),
	('Исток', 'Автозаводский', 'ул. Дьяконова, у д. №20', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-32-23', 'https://istoknn.ru/', 56.259874, 43.882274, ST_SetSRID(ST_MakePoint(43.882274, 56.259874), 4326)),
	('Исток', 'Автозаводский', 'ул. Маковского, у д. 17В', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-32-23', 'https://istoknn.ru/', 56.233805, 43.836950, ST_SetSRID(ST_MakePoint(43.836950, 56.233805), 4326)),
	('Исток', 'Автозаводский', 'Южное шоссе, у д. 22В', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-32-23', 'https://istoknn.ru/', 56.226160, 43.862363, ST_SetSRID(ST_MakePoint(43.862363, 56.226160), 4326)),
	('Исток', 'Автозаводский', 'ул. Толбухина, 8', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-32-23', 'https://istoknn.ru/', 56.243825, 43.833046, ST_SetSRID(ST_MakePoint(43.833046, 56.243825), 4326)),
	('Исток', 'Канавинский', 'ул. Гороховецкая, 3', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (930) 665-15-46', 'https://istoknn.ru/', 56.286582, 43.851835, ST_SetSRID(ST_MakePoint(43.851835, 56.286582), 4326)),
	('Исток', 'Канавинский', 'Московское шоссе, у д. 284', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (930) 665-15-46', 'https://istoknn.ru/', 56.312710, 43.854149, ST_SetSRID(ST_MakePoint(43.854149, 56.312710), 4326)),
	('Исток', 'Канавинский', 'Московское шоссе, у д. 11А', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (930) 665-15-46', 'https://istoknn.ru/', 56.324205, 43.943721, ST_SetSRID(ST_MakePoint(43.943721, 56.324205), 4326)),
	('Исток', 'Канавинский', 'ул. Карла Маркса, 7Б', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (930) 665-15-46', 'https://istoknn.ru/', 56.344564, 43.927003, ST_SetSRID(ST_MakePoint(43.927003, 56.344564), 4326)),
	('Исток', 'Канавинский', 'ул. Карла Маркса, у д. 42А', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-05-35', 'https://istoknn.ru/', 56.340326, 43.944412, ST_SetSRID(ST_MakePoint(43.944412, 56.340326), 4326)),
	('Исток', 'Канавинский', 'ул. Чкалова, у д. 4A', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-05-35', 'https://istoknn.ru/', 56.316384, 43.942764, ST_SetSRID(ST_MakePoint(43.942764, 56.316384), 4326)),
	('Исток', 'Канавинский', 'Московское шоссе, 142', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (930) 665-15-46', 'https://istoknn.ru/', 56.313418, 43.881306, ST_SetSRID(ST_MakePoint(43.881306, 56.313418), 4326)),
	('Исток', 'Ленинский', 'пр. Ленина, 67', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-32-23', 'https://istoknn.ru/', 56.271488, 43.917314, ST_SetSRID(ST_MakePoint(43.917314, 56.271488), 4326)),
	('Исток', 'Ленинский', 'пл. Комсомольская, у д. 6/1', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-32-23', 'https://istoknn.ru/', 56.295737, 43.942422, ST_SetSRID(ST_MakePoint(43.942422, 56.295737), 4326)),
	('Исток', 'Ленинский', 'пр. Ленина, у д. 45А', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-32-23', 'https://istoknn.ru/', 56.282142, 43.923437, ST_SetSRID(ST_MakePoint(43.923437, 56.282142), 4326)),
	('Исток', 'Ленинский', 'ул. Профинтерна, у д. 10', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-32-23', 'https://istoknn.ru/', 56.281189, 43.937401, ST_SetSRID(ST_MakePoint(43.937401, 56.281189), 4326)),
	('Исток', 'Ленинский', 'ул. Героя Самочкина, у д. 29/2', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-32-23', 'https://istoknn.ru/', 56.288261, 43.925680, ST_SetSRID(ST_MakePoint(43.925680, 56.288261), 4326)),
	('Исток', 'Московский', 'ул. Куйбышева, 28', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (930) 665-15-46', 'https://istoknn.ru/', 56.331005, 43.917480, ST_SetSRID(ST_MakePoint(43.917480, 56.331005), 4326)),
	('Исток', 'Московский', 'ул. Баранова, 12А', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (930) 665-15-46', 'https://istoknn.ru/', 56.332869, 43.846894, ST_SetSRID(ST_MakePoint(43.846894, 56.332869), 4326)),
	('Исток', 'Московский', 'ул. Березовская, у д. 82В', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (930) 665-15-46', 'https://istoknn.ru/', 56.325417, 43.875077, ST_SetSRID(ST_MakePoint(43.875077, 56.325417), 4326)),
	('Исток', 'Нижегородский', 'ул. Ковалихинская, у д. 77', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-05-35', 'https://istoknn.ru/', 56.321536, 44.025319, ST_SetSRID(ST_MakePoint(44.025319, 56.321536), 4326)),
	('Исток', 'Нижегородский', 'ул. Усилова, у д. 3/3А', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-05-35', 'https://istoknn.ru/', 56.315117, 44.054403, ST_SetSRID(ST_MakePoint(44.054403, 56.315117), 4326)),
	('Исток', 'Нижегородский', 'Казанское шоссе, у д. 10', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-05-35', 'https://istoknn.ru/', 56.287046, 44.077051, ST_SetSRID(ST_MakePoint(44.077051, 56.287046), 4326)),
	('Исток', 'Нижегородский', 'ул. Белинского/Ашхабадская', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-05-35', 'https://istoknn.ru/', 56.313157, 44.006639, ST_SetSRID(ST_MakePoint(44.006639, 56.313157), 4326)),
	('Исток', 'Нижегородский', 'ул. Родионова, у д. 191', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-05-35', 'https://istoknn.ru/', 56.303855, 44.079760, ST_SetSRID(ST_MakePoint(44.079760, 56.303855), 4326)),
	('Исток', 'Приокский', 'ул. Маршала Голованова, у д. 19/3', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-32-23', 'https://istoknn.ru/', 56.237474, 43.965099, ST_SetSRID(ST_MakePoint(43.965099, 56.237474), 4326)),
	('Исток', 'Приокский', 'ул. Академика Сахарова, у д. 111', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-05-35', 'https://istoknn.ru/', 56.261560, 44.019120, ST_SetSRID(ST_MakePoint(44.019120, 56.261560), 4326)),
	('Исток', 'Приокский', 'пр. Гагарина, у д. 105/1', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-05-35', 'https://istoknn.ru/', 56.235731, 43.953181, ST_SetSRID(ST_MakePoint(43.953181, 56.235731), 4326)),
	('Исток', 'Советский', 'ул. Богородского, у д. 5/6', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-05-35', 'https://istoknn.ru/', 56.292281, 44.041042, ST_SetSRID(ST_MakePoint(44.041042, 56.292281), 4326)),
	('Исток', 'Советский', 'ул. Рокоссовского, у д. 13', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-05-35', 'https://istoknn.ru/', 56.283190, 44.047116, ST_SetSRID(ST_MakePoint(44.047116, 56.283190), 4326)),
	('Исток', 'Советский', 'ул. Бекетова, у д. 13', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-05-35', 'https://istoknn.ru/', 56.290008, 43.996501, ST_SetSRID(ST_MakePoint(43.996501, 56.290008), 4326)),
	('Исток', 'Советский', 'ул. Корнилова, у д. 8', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-05-35', 'https://istoknn.ru/', 56.299568, 44.043789, ST_SetSRID(ST_MakePoint(44.043789, 56.299568), 4326)),
	('Исток', 'Советский', 'ул. Ванеева, 25/88', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-05-35', 'https://istoknn.ru/', 56.310361, 44.021061, ST_SetSRID(ST_MakePoint(44.021061, 56.310361), 4326)),
	('Исток', 'Советский', 'Окский съезд, у д. 4', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (929) 053-05-35', 'https://istoknn.ru/', 56.305695, 43.980890, ST_SetSRID(ST_MakePoint(43.980890, 56.305695), 4326)),
	('Исток', 'Сормовский', 'ул. Иванова, у д. 14', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (930) 665-15-46', 'https://istoknn.ru/', 56.360274, 43.823997, ST_SetSRID(ST_MakePoint(43.823997, 56.360274), 4326)),
	('Исток', 'Сормовский', 'ул. Кораблестроителей, у д. 22/2', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (930) 665-15-46', 'https://istoknn.ru/', 56.364757, 43.814817, ST_SetSRID(ST_MakePoint(43.814817, 56.364757), 4326)),
	('Исток', 'Сормовский', 'пр. Союзный, у д. 43', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (930) 665-15-46', 'https://istoknn.ru/', 56.357728, 43.852479, ST_SetSRID(ST_MakePoint(43.852479, 56.357728), 4326)),
	('Исток', 'Сормовский', 'ул. Льва Толстого, у д. 6Б', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (930) 665-15-46', 'https://istoknn.ru/', 56.350407, 43.860230, ST_SetSRID(ST_MakePoint(43.860230, 56.350407), 4326)),
	('Исток', 'Сормовский', 'ул. Ясная, у д. 31', 'Пн-Пт 8:00-16:00 (обед 12:00-13:00), Сб 8:00-14:00 (без обеда), Вс-выходной', '+7 (930) 665-15-46', 'https://istoknn.ru/', 56.381717, 43.796968, ST_SetSRID(ST_MakePoint(43.796968, 56.381717), 4326)),
	
	('Сфера', 'Московский', 'Сормовское шоссе, 24А', 'Пн-Пт 8:00-17:00, Сб,Вс-выходной', '+7 (950) 629-56-16', 'https://sfera52.ru/', 56.336442, 43.893344, ST_SetSRID(ST_MakePoint(43.893344, 56.336442), 4326)),

	('ЭКОнижний', 'Нижегородский', 'Казанское шоссе 23', 'Круглосуточно', '+7 (969) 624-01-38', 'https://эконижний.рф', 56.286810, 44.074939, ST_SetSRID(ST_MakePoint(44.074939, 56.286810), 4326)),
	('ЭКОнижний', 'Советский', 'пр. Гагарина 23/5', 'Круглосуточно', '+7 (969) 624-01-39', 'https://эконижний.рф', 56.300399, 43.979010, ST_SetSRID(ST_MakePoint(43.979010, 56.300399), 4326)),
	('ЭКОнижний', 'Приокский', 'Парк Швейцария (ул. Медицинская)', 'Круглосуточно', '+7 (969) 624-01-40', 'https://эконижний.рф', 56.281571,  43.979618, ST_SetSRID(ST_MakePoint(43.979618, 56.281571), 4326)),
	('ЭКОнижний', 'Приокский', 'Экоториум (Парк Швейцария)', 'Пн: выходной, Вт-Вс: с 12:00 до 20:00', '+7 (920) 045-28-17', 'https://эконижний.рф', 56.265443, 43.973679, ST_SetSRID(ST_MakePoint(43.973679, 56.265443), 4326)),
	('ЭКОнижний', 'Нижегородский', 'ул. Верхнепечерская 7 к3', 'Круглосуточно', '+7 (969) 624-01-38', 'https://эконижний.рф', 56.287309, 44.067667, ST_SetSRID(ST_MakePoint(44.067667, 56.287309), 4326)),
	('ЭКОнижний', 'Автозаводский', 'Автозаводский парк культуры и отдыха', 'Круглосуточно', '+7 (969) 624-01-39', 'https://эконижний.рф', 56.240893,  43.857136, ST_SetSRID(ST_MakePoint(43.857136, 56.240893), 4326)),
	('ЭКОнижний', 'Московский', 'ул. Красных зорь 13', 'Круглосуточно', '+7 (969) 624-01-41', 'https://эконижний.рф', 56.321299, 43.873937, ST_SetSRID(ST_MakePoint(43.873937, 56.321299), 4326)),
	('ЭКОнижний', 'Нижегородский', 'ул. Лысогорская 89 к1', 'Круглосуточно', '+7 (969) 624-01-42', 'https://эконижний.рф', 56.300241, 44.084101, ST_SetSRID(ST_MakePoint(44.084101, 56.300241), 4326)),
	('ЭКОнижний', 'Нижегородский', 'ул. Родионова, 15', 'Круглосуточно', '+7 (969) 624-01-43', 'https://эконижний.рф', 56.319864, 44.051756, ST_SetSRID(ST_MakePoint(44.051756, 56.319864), 4326)),
	('ЭКОнижний', 'Советский', 'ул. Республиканская 43 к2 (напротив 43к1)', 'Круглосуточно', '+7 (969) 624-01-44', 'https://эконижний.рф', 56.312859, 44.030250, ST_SetSRID(ST_MakePoint(44.030250, 56.312859), 4326)),
	('ЭКОнижний', 'Советский', 'ул. Тимирязева 3 к2', 'В рабочее время офиса. 9:00-18:00', '+7 (969) 624-01-45', 'https://эконижний.рф', 56.304455, 43.997129, ST_SetSRID(ST_MakePoint(43.997129, 56.304455), 4326)),
	
	('РазДельно', 'Советский', 'Окский съезд, 8д', 'С 1 апреля по 31 октября: Вт, Чт 16:00-20:00, Сб 12:00-16:00. С 1 ноября по 31 марта: Вт, Чт 17:00-20:00, Сб 13:00-16:00', Null, 'https://vk.com/razdelnonn', 56.305485, 43.978983, ST_SetSRID(ST_MakePoint(43.978983, 56.305485), 4326)),

	('Волговятпром', 'Ленинский', 'ул. Деловая, 2Б', 'Пн-Пт 9:00-18:00, Сб 10:00-14:00, Вс-выходной', '+7 (920) 253-09-72', 'https://metal52.ru/', 56.307412, 44.054549, ST_SetSRID(ST_MakePoint(44.054549, 56.307412), 4326)),
	('Волговятпром', 'Сормовский', 'ул. Торфяная, 42', 'Пн-Пт 9:00-18:00, Сб 10:00-14:00, Вс-выходной', '+7 (920) 253-09-72', 'https://metal52.ru/', 56.350816, 43.828641, ST_SetSRID(ST_MakePoint(43.828641, 56.350816), 4326)),
	('Волговятпром', 'Советский', 'Новикова-Прибоя, 4к6', 'Пн-Пт 9:00-18:00, Сб 10:00-14:00, Вс-выходной', '+7 (920) 253-09-72', 'https://metal52.ru/', 56.258968, 43.925282, ST_SetSRID(ST_MakePoint(43.925282, 56.258968), 4326)),

	('Зелёный рыцарь', 'Нижегородский', 'ул. Родионова, д. 187-B, ТЦ Фантастика, 2 этаж. Магазин одежды Befree', 'пн-вск 10:00-22:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.307631, 44.073908, ST_SetSRID(ST_MakePoint(44.073908, 56.307631), 4326)),
	('Зелёный рыцарь', 'Советский', 'Советская пл., 5, ТЦ Жар-Птица. Магазин одежды Zarina', 'ежедневно, с 10:00-22:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.296299, 44.042485, ST_SetSRID(ST_MakePoint(44.042485, 56.296299), 4326)),
	('Зелёный рыцарь', 'Канавинский', 'площадь Революции, 9, Магазин одежды Zarina', 'ежедневно, с 10:00-22:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.320338, 43.947623, ST_SetSRID(ST_MakePoint(43.947623, 56.320338), 4326)),
	('Зелёный рыцарь', 'Канавинский', 'ул. Бетанкура, 1, ТЦ Седьмое небо, Магазин одежды Zarina', 'пн-вск 10:00-22:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.339402, 43.956211, ST_SetSRID(ST_MakePoint(43.956211, 56.339402), 4326)),
	('Зелёный рыцарь', 'Нижегородский', 'ул. Родионова, 187-B, ТЦ Фантастика, Магазин одежды Zarina', 'пн-вск 10:00-22:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.307631, 44.073908, ST_SetSRID(ST_MakePoint(44.073908, 56.307631), 4326)),
	('Зелёный рыцарь', 'Сормовский', 'ул.Культуры, д. 8, ПВЗ Яндекс Маркет', 'пн-вск 09:00-21:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.348602, 43.858905, ST_SetSRID(ST_MakePoint(43.858905, 56.348602), 4326)),
	('Зелёный рыцарь', 'Советский', 'бул. 60-летия Октября, д. 21, к.2, ПВЗ Яндекс Маркет', 'пн-вск 09:00-21:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.286283, 44.043518, ST_SetSRID(ST_MakePoint(44.043518, 56.286283), 4326)),
	('Зелёный рыцарь', 'Нижегородский', 'ул.Горького, д. 45, ПВЗ Яндекс Маркет', 'пн-вск 09:00-21:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.312345, 43.983672, ST_SetSRID(ST_MakePoint(43.983672, 56.312345), 4326)),
	('Зелёный рыцарь', 'Сормовский', 'ул. Машинная, д. 29, ПВЗ Яндекс Маркет', 'пн-вск 09:00-21:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.364825, 43.806057, ST_SetSRID(ST_MakePoint(43.806057, 56.364825), 4326)),
	('Зелёный рыцарь', 'Сормовский', 'пр. Союзный, д. 5А, ПВЗ Яндекс Маркет', 'пн-вск 09:00-21:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.358577, 43.856992, ST_SetSRID(ST_MakePoint(43.856992, 56.358577), 4326)),
	('Зелёный рыцарь', 'Советский', 'ул. Новокузнечихинская, д. 13, ПВЗ Яндекс Маркет', 'пн-вск 09:00-21:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.270936, 44.046770, ST_SetSRID(ST_MakePoint(44.046770, 56.270936), 4326)),
	('Зелёный рыцарь', 'Автозаводский', 'ул. Плотникова, д. 3, ПВЗ Яндекс Маркет', 'пн-вск 09:00-21:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.260378, 43.85842, ST_SetSRID(ST_MakePoint(43.85842, 56.260378), 4326)),
	('Зелёный рыцарь', 'Советский', 'ул. Рокоссовского, д. 17, ПВЗ Яндекс Маркет', 'пн-вск 09:00-21:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.283944, 44.041039, ST_SetSRID(ST_MakePoint(44.041039, 56.283944), 4326)),
	('Зелёный рыцарь', 'Сормовский', 'ул. Коммуны, д. 37, ПВЗ Яндекс Маркет', 'пн-вск 09:00-21:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.338694, 43.841361, ST_SetSRID(ST_MakePoint(43.841361, 56.338694), 4326)),
	('Зелёный рыцарь', 'Сормовский', 'ул. Коминтерна, д. 184, ПВЗ Яндекс Маркет', 'пн-вск 09:00-21:00', '8 (800) 200-62-83', 'https://zeler.online/',56.35347,43.863954, ST_SetSRID(ST_MakePoint(43.863954, 56.35347), 4326)),
	('Зелёный рыцарь', 'Нижегородский', 'ул. Нижне-Печерская, д. 8, ПВЗ Яндекс Маркет', 'пн-вск 09:00-21:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.284544, 44.064009, ST_SetSRID(ST_MakePoint(44.064009, 56.284544), 4326)),
	('Зелёный рыцарь', 'Нижегородский', 'ул. Хохлова, д. 3, ПВЗ Яндекс Маркет', 'пн-вск 09:00-21:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.303382, 44.071492, ST_SetSRID(ST_MakePoint(44.071492, 56.303382), 4326)),
	('Зелёный рыцарь', 'Советский', 'ул. Богородского, д3, к1, ПВЗ Яндекс Маркет', 'пн-вск 09:00-21:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.294651, 44.039404, ST_SetSRID(ST_MakePoint(44.039404, 56.294651), 4326)),
	('Зелёный рыцарь', 'Московский', 'ул. Куйбышева д.7, ПВЗ Яндекс Маркет', 'пн-вск 09:00-21:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.328469, 43.915248, ST_SetSRID(ST_MakePoint(43.915248, 56.328469), 4326)),
	('Зелёный рыцарь', 'Приокский', 'ул. Сахарова, д. 111, ПВЗ Яндекс Маркет', 'пн-вск 09:00-21:00', '8 (800) 200-62-83', 'https://zeler.online/', 56.261868, 44.018195, ST_SetSRID(ST_MakePoint(44.018195, 56.261868), 4326)),

	('Доброделы', 'Приокский', 'ЖК "Цветы", ул.Ак.Сахарова, д.111 к.1', 'Круглосуточно', '+7 (920) 033 52 14', 'https://dobrodelynn.ru/pomoch-veshchami', 56.262587, 44.017763, ST_SetSRID(ST_MakePoint(44.017763, 56.262587), 4326)),
	('Доброделы', 'Советский', 'ЖК "Зенит", ул.Краснозвездная, д.35', 'Круглосуточно', '+7 (920) 033 52 14', 'https://dobrodelynn.ru/pomoch-veshchami', 56.284379, 43.988065, ST_SetSRID(ST_MakePoint(43.988065, 56.284379), 4326)),

	('Спасибо', 'Нижегородский', 'ул. Родионова, 200', '11:00-21:00', '+7 (812) 332-54-40', 'https://www.spasiboshop.org/', 56.300969, 44.082523, ST_SetSRID(ST_MakePoint(44.082523, 56.300969), 4326)),
	('Спасибо', 'Канавинский', 'Московское ш., 30', '11:00-21:00', '+7 (812) 332-54-40', 'https://www.spasiboshop.org/', 56.317153, 43.918482, ST_SetSRID(ST_MakePoint(43.918482, 56.317153), 4326)),

	('Фортис', 'Автозаводский', 'ул. Юлиуса Фучика, 60, корп. 4', 'пн-пт 8-00 до 18-00, сб 8-00 до 17-00', '+7 (831) 234-17-17', 'https://fortisnn.ru/', 56.228603, 43.900923, ST_SetSRID(ST_MakePoint(43.900923, 56.228603), 4326)),

	('Металлпрофи', 'Автозаводский', 'ул. Героя Сов. Союза Поющева,16', 'с 9:00 до 18:00', '424-77-84', 'https://metallprofi52.ru/', 56.250507, 43.869955, ST_SetSRID(ST_MakePoint(43.869955, 56.250507), 4326)),
	('Металлпрофи', 'Ленинский', 'ул. Лейтенанта Шмидта 6', 'круглосуточно, без выходных', '424-34-84', 'https://metallprofi52.ru/', 56.292887, 43.924752, ST_SetSRID(ST_MakePoint(43.924752, 56.292887), 4326)),
	('Металлпрофи', 'Приокский', 'пр. Гагарина 121Б', 'круглосуточно, без выходных', '424-25-84', 'https://metallprofi52.ru/', 56.225688, 43.939304, ST_SetSRID(ST_MakePoint(43.939304, 56.225688), 4326)),
	('Металлпрофи', 'Канавинский', 'ул. Электровозная 7А', 'круглосуточно, без выходных', '424-24-84', 'https://metallprofi52.ru/', 56.298662, 43.864349, ST_SetSRID(ST_MakePoint(43.864349, 56.298662), 4326)),
	('Металлпрофи', 'Сормовский', 'ул. Торфяная, 34', 'круглосуточно, без выходных', '424-14-84', 'https://metallprofi52.ru/', 56.346467, 43.825452, ST_SetSRID(ST_MakePoint(43.825452, 56.346467), 4326)),
	('Металлпрофи', 'Сормовский', 'ул. Федосеенко, 45А', 'круглосуточно, без выходных', '424-30-84', 'https://metallprofi52.ru/', 56.340630, 43.816640, ST_SetSRID(ST_MakePoint(43.816640, 56.340630), 4326)),

	('ARMAK52', 'Сормовский', 'ул. Федосеенко, д.50 к. 2', null , '+7 (831) 214-18-38', 'https://armak-nn.ru/', 56.340849, 43.807971, ST_SetSRID(ST_MakePoint(43.807971, 56.340849), 4326)),

	('Выхлопoff', 'Сормовский', 'ул. Свободы, 65А', 'Пн-Вс: 9:00 – 21:00' , '8 (800) 600-86-27', 'https://vyhlopof.ru/', 56.364386, 43.860217, ST_SetSRID(ST_MakePoint(43.860217, 56.364386), 4326)),

	('Промконтракт', 'Канавинский', 'ул. Московское шоссе, 302А', 'пн-пт 09:00 - 17:00' , '8(904)065-44-73, 8(953)415-04-70', 'https://pk-metall.ru/', 56.308550, 43.823754, ST_SetSRID(ST_MakePoint(43.823754, 56.308550), 4326)),

	('ELEMENT 52', 'Ленинский', 'ул. Шекспира, 1Б к4', 'Пн-Пт, 10:00 до 18:30' , '8(930) 678-5555, 8(930) 678-2222', 'https://element-52.ru/',  56.261428, 43.941838, ST_SetSRID(ST_MakePoint(43.941838, 56.261428), 4326)),

	('Волга Металл', 'Ленинский', 'ул Порт-Артурская, д. 1В.', 'Пн-Пт: 8.00-18.30, Cб: 8.00-15.00' , '8 (831)261-95-39', 'https://volga-metall.ru/',  56.298052, 43.912768, ST_SetSRID(ST_MakePoint(43.912768, 56.298052), 4326)),
	('Волга Металл', 'Автозаводский', 'Молодёжный проспект, 80', 'Пн-Пт: 8.00-18.30, Cб: 8.00-15.00' , '8-904-050-23-74', 'https://volga-metall.ru/',  56.246126, 43.820646, ST_SetSRID(ST_MakePoint(43.820646, 56.246126), 4326)),
	('Волга Металл', 'Нижегородский', ' Бойновский переулок, 17', 'Пн-Пт: 8.00-18.30, Cб: 8.00-15.00' , '8-905-196-50-24', 'https://volga-metall.ru/',  56.317692, 44.037445, ST_SetSRID(ST_MakePoint(44.037445, 56.317692), 4326)),
	('Волга Металл', 'Сормовский', 'Сормовское шоссе, 24 К', 'Пн-Пт: 8.00-18.30, Cб: 8.00-15.00' , '8-910-792-83-88', 'https://volga-metall.ru/', 56.335900, 43.889664, ST_SetSRID(ST_MakePoint(43.889664, 56.335900), 4326)),

	('Нижметалл', 'Советский', 'ул. Артельная, 9 в', 'Пн-Сб 08:00 - 19:00' , '8(906) 358-83-63', 'https://lom152.ru/', 56.298162, 43.995961, ST_SetSRID(ST_MakePoint(43.995961, 56.298162), 4326)),
	('Нижметалл', 'Московский', 'ул. Камская, 50 а', 'Пн-Сб 08:00 - 19:00' , '8(906) 358-83-63', 'https://lom152.ru/', 56.331608, 43.833636, ST_SetSRID(ST_MakePoint(43.833636, 56.331608), 4326))
	
) as new_points (name, district, address, working_hours, phone_number, website, latitude, longitude, location)
where not exists (
	select 1 from ReceptionPoints rp
	where rp.name = new_points.name
		and rp.address = new_points.address
		and rp.latitude = new_points.latitude
		and rp.longitude = new_points.longitude
);


insert into ReceptionPointMaterials (point_id, material_id, custom_name, custom_memo, cost_per_unit, unit)
select 
    rp.point_id, 
    m.material_id,
	new_data.custom_name, 
    new_data.custom_memo, 
    new_data.cost_per_unit, 
    new_data.unit
from (
	select 
		rp.name as point_name,
		m.material_id,
    	case m.material_id 
        	when 1 then 'Картон' 
        	when 2 then 'Бумага' 
			when 3 then 'Архив, книги с обложками' 
			when 4 then 'ПВД' 
			when 5 then 'Стрейч' 
			when 6 then 'Флакон ПНД' 
			when 7 then 'ПЭТ бутылки' 
			when 8 then 'Алюминиевые банки' 
			when 9 then 'Стеклянные бутылки' 
			when 10 then 'Батарейки' 
			when 11 then 'Аккумуляторы' 
			when 12 then 'Мобильные устройства, телефония' 
			when 13 then 'Компьютерная техника' 
			when 14 then 'Крупное электрооборудование' 
			when 15 then 'Компьютерная техника' 
			when 16 then 'Аудио-видео техника' 
			when 17 then 'Аудио - Видео - Фото техника' 
			when 18 then 'Компьютерная техника' 
			when 19 then 'Крупное электрооборудование' 
			when 20 then 'Телефония' 
			when 21 then 'Бытовая техника' 
			when 22 then 'Торговое электрооборудование' 
			when 23 then 'Компьютерная техника' 
			when 24 then 'Электроинструмент' 
			when 25 then 'Автомобильные электроприборы' 
			when 26 then 'Бытовая и оргтехника' 
			when 27 then 'Косметические приборы' 
    	end as custom_name, 
    	case m.material_id 
        	when 1 then 'увязанный либо сложенный в коробки' 
        	when 2 then '(журналы, газеты, книги без обложек) – увязанные, уложенные в коробки, пакеты, мешки.' 
			when 3 then '(скидка 10% на засор - обложки от книг, файлы и т.д.) – увязанные, уложенные в коробки, пакеты, мешки.' 
			when 4 then 'прозрачный' 
			when 5 then 'прозрачный' 
			when 6 then 'Флакон ПНД' 
			when 7 then 'Принимаем обозначенные цифрой 2 или HDPE из-под моющих средств, '
			'шампуней, канистры из-под пищевых и нефтепродуктов, бутылочки из под йогуртов' 
			when 8 then NULL 
			when 9 then 'до 5 литров (принимаем: только целые бутылки и банки, не принимаем: в разбитом виде, листовое стекло, стеклобой)' 
			when 10 then 'Принимаются только в пунктах обозначенных не более 10 отработанных батареек от одного клиента' 
			when 11 then 'Принимаются только в пунктах обозначенных. Принимаем: свинцово-кислотные аккумуляторы; ' 
			'гелевые аккумуляторы; без повреждений корпуса, трещин, следов вскрытия, потеков жидкости; на корпусе '
			'должен стоять знак треугольник со стрелками и буквами Pb (Pb - означает свинец). Мы не принимаем: '
			'универсальные батареи, щелочные аккумуляторы, кальциевые аккумуляторы, а также поврежденные и вскрытые аккумуляторы.' 
			when 12 then 'телефоны мобильные сенсорные и кнопочные' 
			when 13 then 'платы электронные компьютерные, компьютеры портативные (ноутбуки), системный блок компьютера '
			'укомплектованный, компьютер-моноблок, платы электронные (все, кроме компьютерных).' 
			when 14 then 'кондиционеры, сплит-системы кондиционирования, холодильники , машины посудомоечные, '
			'витрины холодильные, морозильные камеры, плиты газовые' 
			when 15 then 'стабилизаторы напряжения, модемы, коммутаторы, маршрутизаторы сетевые, ТВ тюнеры, '
			'ТВ приставки, оборудование автоматических телефонных станций, проекторы' 
			when 16 then 'стабилизаторы напряжения, модемы, коммутаторы, маршрутизаторы сетевые, ТВ тюнеры, '
			'ТВ приставки, оборудование автоматических телефонных станций, проекторы' 
			when 17 then 'видеоплееры, видеокамеры, музыкальные центры, магнитофоны бытовые, мониторы компьютерные '
			'с электроннолучевой трубкой, телевизоры цветного изображения с электронно-лучевой трубкой, видеомагнитофоны бытовые, рации портативные' 
			when 18 then 'POS-компьютеры, POS-терминалы, Коммутаторы, Блоки питания, Геймпады, ИБП (источник бесперебойного питания), '
			'Копировальное оборудование, Медиаконвертеры, МФУ (много функциональное устройство), Оптические приводы, Плоттеры, '
			'Преобразователи напряжения, Принтеры, Системный блок (грабленный, остались платы и еще 1 компонент (блок питания)), '
			'Сетевые адаптеры, Сканеры, Стабилизаторы напряжения' 
			when 19 then 'банкомат, машины стиральные бытовые, машины сушильные, радиостанции, вентилятор бытовой' 
			when 20 then 'телефоны стационарные, телефоны IP, Радиотрубки и факсимильные аппараты' 
			when 21 then 'Микроволновые печи, Электрические печи, Мультиварки, Мясорубки, Обогреватели, '
			'Оверлоки, Орешницы, Осушители воздуха, Отпариватели, Пароварки, Паровые станции, Паровые швабры, '
			'Парогенераторы, Проточные водонагреватели, Пылесосы, Роботы-пылесосы, Соковыжималки, Сушилки для рук, '
			'Сушки для фруктов и овощей, Сэндвичницы, Тепловентиляторы, Термопоты, Тостеры, Увлажнители воздуха, '
			'Умные колонки, Утюги, Фритюрницы, Хлебопечи, Чайники электрические, Швейные машины, кулер для воды' 
			when 22 then 'информационно-платежный терминал, электронное программно техническое устройство для '
			'приема к оплате платежных карт (POS терминал), электронный кассир, счетчики электрические, '
			'темпокасса, детекторы валют, контрольно-кассовый аппарат' 
			when 23 then 'клавиатура, манипулятор «мышь» с соединительными проводами, принтеры, сканеры, '
			'многофункциональные устройства (МФУ), ламинатор, машины копировальные , уничтожитель бумаг (шредер), '
			'диски магнитные жесткие, блок питания от системного блока' 
			when 24 then 'оборудование садовое для кошения травы, Аккумуляторный электроинструмент, '
			'Сетевой электроинструмент, Электроизмерительные щитовые приборы, приборы КИПиА , манометры' 
			when 25 then 'Bluetooth адаптеры, Bluetooth гарнитуры, FM трансмиттеры, Web-камеры, '
			'Автомобильные зарядные устройства, Автомобильные пылесосы, Автосигнализации, Алкотестеры, '
			'Автомобильные компрессоры, Кондиционеры для машины, Навигаторы, Радар-детекторы, Усилители автомобильные' 
			when 26 then 'Системный блок (грабленный, только корпус или корпус + блок питания, '
			'корпус плюс дисковод, корпус + флоппик), Аэрогрили, Блендеры, Весы напольные, Видеорегистраторы, '
			'Вспышки для фотоаппаратов, Джойстик, Док-станции для планшетов, Домофоны, Зарядные устройства, '
			'Масляные радиаторы, Микрофоны, Наушники, Погодные станции, Портативные колонки, Пульты ДУ, '
			'Радиобудильники, Регистраторы видеонаблюдения, Сетевые разветвители, Сетевые фильтры, Смарт-часы, '
			'Стедикамы, Считыватели магнитных карт, Фискальные накопители, Фискальные регистраторы онлайн, Фитнес-браслеты, Штативы' 
			when 27 then 'Бритвы и эпиляторы, Выпрямители для волос, Гидромассажные ванночки для ног, Зубные щетки, Ингаляторы, '
			'Массажеры, Машинки для стрижки волос, Мультистайлеры, Стетоскопы, Термометры, Тонометры, Триммеры, Фены, '
			'Фотоэпиляторы, Щипцы для завивки волос, Электробигуди, Электробритвы, Эпиляторы' 
    	end as custom_memo, 
    	case m.material_id 
        	when 1 then 5 
        	when 2 then 9
			when 3 then 9
			when 4 then 25
			when 5 then 15
			when 6 then 8
			when 7 then 28
			when 8 then 0.9 
			when 9 then 4 
			when 10 then NULL
			when 11 then 20
			when 12 then 50 
			when 13 then 15
			when 14 then 5
			when 15 then 5
			when 16 then 5
			when 17 then 3.5
			when 18 then 3.5
			when 19 then 3.5 
			when 20 then 3.5
			when 21 then 3.5
			when 22 then 3.5
			when 23 then 3.5 
			when 24 then 3.5
			when 25 then 0.01 
			when 26 then 0.01
			when 27 then 0.01 
    	end as cost_per_unit, 
		case m.material_id 
        	when 1 then 'руб/кг'
        	when 2 then 'руб/кг'
			when 3 then 'руб/кг'
			when 4 then 'руб/кг'
			when 5 then 'руб/кг'
			when 6 then 'руб/кг'
			when 7 then 'руб/кг'
			when 8 then 'руб/шт'
			when 9 then 'руб/кг'
			when 10 then NULL
			when 11 then 'руб/кг'
			when 12 then 'руб/кг'
			when 13 then 'руб/кг'
			when 14 then 'руб/кг'
			when 15 then 'руб/кг'
			when 16 then 'руб/кг'
			when 17 then 'руб/кг'
			when 18 then 'руб/кг'
			when 19 then 'руб/кг'
			when 20 then 'руб/кг'
			when 21 then 'руб/кг'
			when 22 then 'руб/кг'
			when 23 then 'руб/кг'
			when 24 then 'руб/кг'
			when 25 then 'руб'
			when 26 then 'руб'
			when 27 then 'руб' 
    	end as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'Исток'
	and m.material_id between 1 and 27
	
	union all 
	select 
		rp.name as point_name,
		m.material_id,
		case m.material_id
	 		when 28 then 'Картонные коробки'
			when 29 then 'Банановая коробка'
			when 30 then 'Картонная втулка'
			when 31 then 'Офисная бумага'
			when 32 then 'Книги'
			when 33 then 'Газеты'
			when 34 then 'Журналы'
			when 35 then 'Стрейч'
			when 36 then 'ПВД'
			when 37 then 'ПНД'
			when 38 then 'Пластиковые ящики'
			when 39 then 'Канистра'
			when 40 then 'Бутылка ПЭТ'
			when 41 then 'Поддоны деревянные'
		end as custom_name,
		case m.material_id
			when 28 then 'Первичного и вторичного использования'
			when 29 then 'Низ и верх, чистая упаковка, не рваная'
			when 30 then 'Голая без остатков, стенки до 1,5 см'
			when 31 then 'Использованная бумага форматов от А1 до А8'
			when 32 then 'Любые'
			when 33 then 'Из почтовых ящиков, остатки производственного брака'
			when 34 then 'Глянцевые катлоги и журналы'
			when 35 then 'Прозрачная, Б/У после обмотки паллетов и товаров'
			when 36 then 'После поддонов, газировки и т.д.'
			when 37 then 'После поддонов, газировки и т.д'
			when 38 then 'Б/У, из-под продуктов (фруктовые, молочные)'
			when 39 then 'Голая без остатков, толщина стенки до 1,5 см'
			when 40 then 'Прозрачная, Б/У после обмотки паллетов и товаров'
			when 41 then 'Б/У, разные размеры, облегченные'
		end as custom_memo,
		case m.material_id
			when 28 then 5
			when 29 then 15
			when 30 then 2
			when 31 then 10
			when 32 then 8
			when 33 then 12
			when 34 then 8
			when 35 then 15
			when 36 then 15
			when 37 then 10
			when 38 then 4
			when 39 then 15
			when 40 then 5
			when 41 then 100
		end as cost_per_unit,
		case m.material_id
			when 28 then 'руб/кг'
			when 29 then 'руб/шт'
			when 30 then 'руб/кг'
			when 31 then 'руб/кг'
			when 32 then 'руб/кг'
			when 33 then 'руб/кг'
			when 34 then 'руб/кг'
			when 35 then 'руб/кг'
			when 36 then 'руб/кг'
			when 37 then 'руб/кг'
			when 38 then 'руб/шт'
			when 39 then 'руб/кг'
			when 40 then 'руб/кг'
			when 41 then 'руб/шт'
		end as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'Сфера'
	and m.material_id between 28 and 41

	union all 
	select 
		rp.name as point_name,
		m.material_id,
		case m.material_id 
        	when 42 then 'Несжатые алюминиевые банки'
			when 43 then 'Алюминиевые банки'
			when 44 then 'Банка из-под масла'
			when 45 then 'Стеклянная тара'
			when 46 then 'Картон'
			when 47 then 'Книги и журналы'
			when 48 then 'Пачки газет'
			when 49 then 'Плотная бумага'
			when 50 then 'Несжатые пластиковые бутылки'
			when 51 then 'Пластиковые бутылки'
			when 52 then 'Пластиковые бутылки (5 литров и более)'
			when 53 then 'Цветной ПЭТ'
		end as custom_name,
		case m.material_id
			when 42 then NULL
			when 43 then 'До 2 литров'
			when 44 then NULL
			when 45 then 'Принимают только на ул. Тимирязева 3 к2'
			when 46 then NULL
			when 47 then 'Без обложки, в пачках размером до 40х40х20 см (ШхГхВ)'
			when 48 then NULL
			when 49 then 'Архив, листовки, брошюры, тетради, картон, бумажные пакеты и мешки, упаковочная бумага, бумага тишью светлых цветов'
			when 50 then 'Прозрачные'
			when 51 then 'Из-под напитков (бесцветные, голубые, коричневые, зеленые)'
			when 52 then 'Из-под омывающей жидкости'
			when 53 then NULL
		end as custom_memo,
		case m.material_id
			when 42 then 0.20
			when 43 then 0.80
			when 44 then 0.10
			when 45 then 0.20
			when 46 then 1.50
			when 47 then 4.50
			when 48 then 4.50
			when 49 then 7.50
			when 50 then 0.20
			when 51 then 0.70
			when 52 then 0.80
			when 53 then 0.20
		end as cost_per_unit,
		'руб' as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'ЭКОнижний'
	and m.material_id between 42 and 53

	union all 
	select 
		rp.name as point_name,
		m.material_id,
		case m.material_id 
        	when 54 then 'офисная и писчая бумага'
			when 55 then 'бумажная упаковка'
			when 56 then 'крафт-бумага'
			when 57 then 'цветная бумага'
			when 58 then 'книги, газеты, журналы (включая глянцевые)'
			when 59 then 'тонкий картон и изделия из него: цветной картон, открытки, картонная упаковка'
			when 60 then 'глянцевая (мелованная) бумага'
			when 61 then 'бумага для рисования, в том числе исписанная и изрисованная'
			when 62 then 'офисная бумага'
			when 63 then 'газеты'
			when 64 then 'фольгированная бумага'
			when 65 then 'фотобумага'
			when 66 then 'композитная бумага (C/PAP, 80-84)'
			when 67 then 'чеки и бумага для факса'
			when 68 then 'калька, пергаментная, вощеная, копировальная бумага, бумага с силиконовым слоем, с пластиковым покрытием'
			when 69 then 'серый картон, картон с гофрированной структурой'
			when 70 then 'коробки из-под напитков'
			when 71 then 'бумажные стаканчики'
			when 72 then 'ламинированные картон и бумага'
			when 73 then 'детские картонные книги'
			when 74 then 'пазлы'
			when 75 then 'картонные втулки, тубы'
			when 76 then 'сигаретные пачки из картона'
			when 77 then 'изделия с двухсторонней ламинацией '
			when 78 then 'коробки из-под пиццы с масляными пятнами (без остатков еды)'
			when 79 then 'стеклянные бутылки'
			when 80 then 'банки'
			when 81 then 'посудное стекло (кроме жаропрочного)'
			when 82 then 'битое тарное стекло'
			when 83 then 'ампулы не битые'
			when 84 then 'флаконы от духов'
			when 85 then 'алюминиевые банки из-под напитков'
			when 86 then 'баллончики от аэрозолей с маркировкой 41 ALU'
			when 87 then 'алюминиевые крышки'
			when 88 then 'алюминиевые консервные банки'
			when 89 then 'алюминиевые баночки (как от крема Nivea)'
			when 90 then 'алюминиевые тубусы (как от Бифиформа)'
			when 91 then 'металлические тюбики от крема, зубной пасты и т. п. промытые'
			when 92 then 'алюминиевые и жестяные консервные банки'
			when 93 then 'винтовые крышки от стеклотары, крышки для закрутки'
			when 94 then 'жестяные и алюминиевые баллончики (проткнутые)'
			when 95 then 'ПЭТ-бутылки, флаконы, канистры от пищевой и непищевой продукции'
			when 96 then 'ПЭТ-банки от пищевой и непищевой продукции'
			when 97 then 'ПЭТ-преформы'
			when 98 then 'иные выдувные (с точкой на дне) изделия с маркировкой 1, PET, PETE, PETP, ПЭТ, ПЭТФ, PET-R, R-PET'
			when 99 then 'бутылки, флаконы, канистры, банки и пузырьки (2, HDPE)'
			when 100 then 'крышки с маркировкой 2, HDPE'
			when 101 then 'крышки с маркировкой TetraPak'
			when 102 then 'крышки с маркировкой Bericap ("B" в перевернутом треугольнике), кроме крышек от бутылок с уксусом'
			when 103 then 'крышки со значком звёздочки'
			when 104 then 'ребристые крышки от дойпаков'
			when 105 then 'ручки от ПЭТ-бутылок'
			when 106 then 'крышки-шестигранники от дойпаков “ФрутоНяни”'
			when 107 then 'крышки от коробок с городецким молоком (с буквой S внутри крышки)'
			when 108 then 'крышки с маркировкой 7 (например, от йогурта “Чудо”)'
			when 109 then 'навинчивающиеся крышки от ПЭТ-бутылок без логотипа и маркировки'
			when 110 then 'крышки от ПЭТ-бутылок со вкладышем'
			when 111 then 'любые крышки (даже с маркировкой 3, 7, без маркировки)'
			when 112 then 'гладкие крышки от дойпаков с детским пюре (кроме шестигранников '
			when 113 then 'крышки-соски и спорткапы'
			when 114 then 'крышки от бутылей для воды с уплотнительной резинкой'
			when 115 then 'навинчивающиеся крышки'
			when 116 then 'колпачки от распылителей'
			when 117 then 'крышки с наклейками (кроме крышек 2)'
			when 118 then 'крышки-клапаны от тетрапака'
			when 119 then 'колечки от крышек'
			when 120 then 'горлышки от тетрапаков'
			when 121 then 'блестящие крышки от кофе'
			when 122 then 'батарейки'
			when 123 then 'аккумуляторы'
			when 124 then 'пауэр-банки'
			when 125 then 'провода и удлинители'
			when 126 then 'строительная, садовая, бытовая, офисная, техника, электроинструмент'
			when 127 then 'телефоны, смартфоны'
			when 128 then 'ноутбуки, компьютеры'
			when 129 then 'телевизоры, аудио- и видеотехника'
			when 130 then 'фото- и видеокамеры, системы безопасности'
			when 131 then 'автомобильная электроника'
		end as custom_name,
		case 
			when m.material_id between 54 and 58 then 'Без примесей (фольги, металла и пластика), без скоб, '
			'скрепок, пружин, скотча, файлов. (маркировка 22)'
			when m.material_id = 59 then 'С белой гладкой обратной стороной или белой “начинкой” при надрыве, (маркировка 22)'
			when m.material_id between 60 and 61 then '(маркировка 22)'
			when m.material_id = 62 then 'Белая с черно-белой печатью или надписями ручкой, простыми карандашами, '
			'допускаются со следами маркера, печатей, цветных карандашей, порванная вручную бумага'
			when m.material_id = 63 then 'Увзанные бечёвкой'
			when m.material_id between 64 and 68 then  null
			when m.material_id = 69 then 'Без скотча, скоб, скрепок, пружин'
			when m.material_id = 70 then 'Без слоя алюминия'
			when m.material_id = 71 then 'Без крышки'
			when m.material_id = 72 then 'Принимают как тонкий, так и гофрированный'
			when m.material_id between 73 and 74 then  null
			when m.material_id = 75 then 'Если донышко металлическое, то обязательно надо отрезать '
			'(можно сдать в металл), максимально расплющить и горлышко срезать не надо'
			when m.material_id between 76 and 79 then  null
			when m.material_id between 80 and 81 then  'крышки снять'
			when m.material_id = 82 then 'упаковать в коробку'
			when m.material_id = 83 then 'упаковать в отдельную целую банку'
			when m.material_id = 84 then 'распылитель можно не удалять'
			when m.material_id = 85 then 'без наклейки'
			when m.material_id = 86 then 'Без наклеек, вкладышей, купол у баллончиков '
			'нужно проверять магнитом: если магнитится, то баллончик надо разобрать или сдать целиком в жесть.'
			when m.material_id = 87 then 'без уплотнительной резинки.'
			when m.material_id = 88 then null
			when m.material_id between 89 and 91 then 'разрезать, промыть и расправить в пласт. '
			'Если горлышко пластиковое - пластиковую часть надо удалить или же часть с этим горлышком сдать в жесть'
			when m.material_id = 92 then 'Консервные банки следует сплющить, вырезав дно и крышку, для экономии места, '
			'бумажные этикетки лучше снять и сдать в макулатуру, но можно оставить'
			when m.material_id = 93 then 'бумажные этикетки лучше снять и сдать в макулатуру, без уплотняющей резинки'
			when m.material_id = 94 then 'Баллоны должны быть пустыми, их нужно проткнуть шилом или ножом и сплющить. Пластиковые части упаковки надо удалить'
			when m.material_id between 95 and 98 then 'объёмом до 6 л, прозрачные, чистые и сухие,  должны быть '
			'сплющены или скручены, крышки, распылители, дозаторы должны быть сняты, допускаются разрезанные бутылки, '
			'снять термоусадочную плёнку, Стандартные цвета: бесцветные, прозрачно-голубые, зелёные, коричневые и их оттенки'
			when m.material_id = 99 then 'Требуется разделить на три отдельные фракции: 1) белый и бесцветный, 2) цветной, 3) с наклейками. '
			'С тарных изделий необходимо снять термоусадочную пленку, а также крышки, носики, дозаторы и т. п. и проверить  маркировку на них. '
			'Если на них стоит маркировка (чаще всего 5,РР или 2,HDPE), их можно сдать с соответствующим видом пластика. С фракций “белый и '
			'бесцветный ПНД” и “цветной ПНД” необходимо удалить все наклейки, колечки, плёнку, фольгу. На фракции “ПНД с наклейками” всё, '
			'кроме термоусадочной плёнки, можно оставить. Крупную тару  сплющить.'
			when m.material_id between 100 and 106 then 'Крышки должны быть чистыми и сухими, без наклеек. '
			'Внутри крышек не должно быть вкладыша. Если вкладыш легко удаляется, то такая крышка принимается. Впаянные вкладыши не принимаются.'
			when m.material_id between 107 and 121 then 'Крышки должны быть чистыми и сухими. Вкладыш допускается только на крышках от '
			'ПЭТ-бутылок из-под напитков (как, например, у "Боржоми"). Крышки 2  HDPE с наклейкой НЕ принимаются в эту '
			'фракцию: наклейку необходимо удалить (руками, ножом, водой или маслом), а крышку сдать во фракцию “Крышки 2 HDPE”'
			when m.material_id = 122 then 'К этой категории относятся бытовые батарейки и аккумуляторы (AAA, AA, C, D, 3V, 4.5V, 9V). '
			'Если батарейка протекает, необходимо её герметично упаковать! Если вы храните батарейки в 5-литровых бутылях, '
			'приносите прямо в них, предварительно проверив бутыль на отсутствие инородных предметов (ластики, пружинки, пробки и т.д.).'
			when m.material_id between 123 and 124 then 'Принимаются аккумуляторные батареи, аккумуляторы от телефонов и ноутбуков (съёмные) '
			', пауэр-банки (портативные аккумуляторы "Power Bank").'
			when m.material_id = 125 then null
			when m.material_id = 126 then 'без картриджей и систем подачи чернил'
			when m.material_id between 127 and 131 then null
		end as custom_memo,
		null as cost_per_unit,
		null as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'РазДельно'
	and m.material_id between 54 and 131

	union all 
	select 
		rp.name as point_name,
		m.material_id,
		case m.material_id 
        	when 132 then 'Медь'
			when 133 then 'Медь (Лужёная)'
			when 134 then 'Медь (Колонка)'
			when 135 then 'Медный кабель'
			when 136 then 'Латунь'
			when 137 then 'Алюминий'
			when 138 then 'Алюминий электротехничиский'
			when 139 then 'Алюминевый кабель'
			when 140 then 'Алюминиевые банки'
			when 141 then 'Нержавейка 10% (1500*500*500)'
			when 142 then 'Нержавейка 8%'
			when 143 then 'Нержавейка (Негабаритный) 10%'
			when 144 then 'Стружка нержавейка'
			when 145 then 'Цинк'
			when 146 then 'Свинец'
			when 147 then 'Свинец кабельный'
			when 148 then 'Стружка латунная'
			when 149 then 'Стружка стальная'
			when 150 then 'Стружка медная'
			when 151 then 'Электродвигатели'
			when 152 then 'АКБ (кислотные)'
			when 153 then 'АКБ (гелевые)'
			when 154 then 'Титан'
			when 155 then 'Стружка алюминия'
			when 156 then 'Магний'
			when 157 then 'Никель'
			when 158 then 'Нихром'
			when 159 then 'Олово'
			when 160 then 'ПОС 61'
			when 161 then 'Р18'
			when 162 then 'Р6М5'
			when 163 then 'Вольфрам'
			when 164 then 'Молибден'
			when 165 then 'Твердосплавный ТК,ВК (чистый)'
			when 166 then 'Черный лом'
		end as custom_name,
		case 
			when m.material_id = 132 then 'Сдаче подлежит очищенное от изоляции, не окисленное сырье.'
			when m.material_id between 133 and 144 then null
			when  m.material_id = 145 then 'Возможна сдача с примесями алюминия и магния.'
			when  m.material_id = 146 then 'Могут сдаваться в виде переплавленных частей, пластин или оплеток.'			
			when m.material_id between 147 and 150 then null
			when  m.material_id = 151 then 'Принимаются электрические двигатели любого вида.'
			when  m.material_id = 152 then 'Принимаются автомобильные акб, обязательно без кислоты.'
			when m.material_id between 153 and 158 then null
			when  m.material_id = 159 then 'Принимается в чистом виде.'
			when m.material_id between 160 and 165 then null
			when  m.material_id = 166 then 'Принимается черный лом практически всех видов, и любых объемов.'
		end as custom_memo,
		case m.material_id
			when 132 then 740
			when 133 then 595
			when 134 then 595
			when 135 then 75
			when 136 then 445
			when 137 then 130
			when 138 then 200
			when 139 then 25
			when 140 then 95
			when 141 then 65
			when 142 then 52
			when 143 then 62
			when 144 then 30
			when 145 then 145
			when 146 then 130
			when 147 then 135
			when 148 then 360
			when 149 then 9
			when 150 then 595
			when 151 then 50
			when 152 then 60
			when 153 then 60
			when 154 then 230
			when 155 then 75
			when 156 then 75
			when 157 then 800
			when 158 then 500
			when 159 then 1500
			when 160 then 1050
			when 161 then 200
			when 162 then 200
			when 163 then 1600
			when 164 then 2000
			when 165 then 1350
			when 166 then 16.5
		end as cost_per_unit,
		'руб/кг' as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'Волговятпром'
	and m.material_id between 132 and 166

	union all 
	select 
		rp.name as point_name,
		m.material_id,
		case m.material_id 
        	when 167 then 'Верхняя одежда'
			when 168 then 'Штаны'
			when 169 then 'Легкая одежда'
			when 170 then 'Теплая одежда'
			when 171 then 'Спецодежда'
			when 172 then 'Неодежда'
			when 173 then 'Детская одежда'
			when 174 then 'Аксессуары'
		end as custom_name,
		case m.material_id
			when 167 then 'Принимается только чистая верхняя одежда без утеплителя (плащи, джинсовые '
			'куртки, ветровки, пиджаки, жакеты и т.п.). Не принимается верхняя одежда с утеплителем '
			'(куртки, шубы, пуховики, пальто и т.п.). Исключение: изделие с этикетками.'
			when 168 then 'Принимаются только чистые брюки, джинсы, штаны, шорты. Не принимается нижнее бельё.'
			when 169 then 'Принимаются только чистые рубашки, сорочки, футболки, майки, юбки, кофты, платья, '
			'блузки, халаты, сарафаны. '
			when 170 then 'Принимаются только чистые свитера, кофты, джемперы, кардиганы, водолазки, жилетки, толстовки, худи'
			when 171 then 'Принимается только чистая специальная и форменная одежда'
			when 172 then 'Принимается только чистое постельное бельё, полотенца. Не принимаются подушки, одеяла, '
			'шторы, портьеры, тюль, игрушки, изделия из натуральной или искусственной кожи, замши и меха, войлока, '
			'медицинские изделия, изделия из 100% синтетики, с масло-и водоотталкивающими пропитками.'
			when 173 then 'Принимаются только чистые пеленки, ползунки, распашонки.'
			when 174 then 'Принимаются только чистые вязаные перчатки, варежки, шарфы, шапки. Не принимаются '
			'не вязанные головные уборы, сумки, ремни, обувь, бижютерию.'
		end as custom_memo,
		null as cost_per_unit,
		null as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'Зелёный рыцарь'
	and m.material_id between 167 and 174

	union all 
	select 
		rp.name as point_name,
		m.material_id,
		case m.material_id 
        	when 175 then 'Верхняя одежда'
			when 176 then 'Штаны'
			when 177 then 'Легкая одежда'
		end as custom_name,
		case m.material_id
			when 175 then 'Можно сдать чистую одежду в пакетах с завязанными ручками. Нельзя сдавать обувь, '
			'нижнее бельё, носки, колготки, чулки, муж. костюмы/пиджаки, шубы/дублёнки.'
			when 176 then 'Можно сдать чистые текстильные изделия с содержанием в составе '
			'ткани хлопка > 50%. Всё это необходимо упаковать в пакеты с завязанными ручками. '
			'Это постельное бельё, пелёнки, полотенца, детский и взрослый трикотаж/махра/фланель/хлопок (футболки, сорочки и т.п.). '
			'Нельзя сдавать нижнее бельё, верхнюю одежду, многослойные изделия и всё, что не относится к хлопковому текстилю.'
			when 177 then 'Можно сдать кроватки, коляски, детские ванночки, велосипеды, самокаты, техника и т.п. 1) если '
			'вещь есть в списке "актуальных потребностей" на сайте - откликнитесь, с Вами свяжемся, обсудим передачу и отправим адресату 2) '
			'если Вашей вещи нет в списке, свяжитесь с нами по тел. 8(920) 033-52-14 и предложите её. Мы разместим объявление в наших пунктах '
			'и, в случае отклика от наших подопечных, заберём Вашу вещь'
		end as custom_memo,
		null as cost_per_unit,
		null as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'Доброделы'
	and m.material_id between 175 and 177

	union all 
	select 
		rp.name as point_name,
		m.material_id,
		case m.material_id 
        	when 178 then 'Вещи из натуральной ткани'
			when 179 then 'Одежда и обувь'
			when 180 then 'Детская одежда, обувь, игрушки'
			when 181 then 'Книги'
		end as custom_name,
		case m.material_id
			when 178 then 'Принимаются вещи из натуральной ткани в любом состоянии'
			when 179 then 'Принимается чистая одежда и обувь без существенных дефектов'
			when 180 then 'Принимается детская одежда, обувь, игрушки (кроме мягких)'
			when 181 then 'Принимаютя книги в хорошем состоянии'
		end as custom_memo,
		null as cost_per_unit,
		null as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'Спасибо'
	and m.material_id between 178 and 181

	union all 
	select 
		rp.name as point_name,
		m.material_id,
		case m.material_id 
        	when 182 then '17А Чугун'
			when 183 then '20А Чугун негабарит'
			when 184 then '3А Габарит'
			when 185 then '5А Негабарит'
			when 186 then '12А Жесть'
			when 187 then '12А2 Жесть оцинкованная'
			when 188 then 'Лом 3А'
			when 189 then 'Лом 5А'
			when 190 then 'Лом 12А'
			when 191 then 'Лом 17А'
			when 192 then 'Лом стружка'
			when 193 then 'Алюминиевая банка'
			when 194 then 'Картон'
			when 195 then 'Кипа картона 5Б'
			when 196 then 'Архив'
			when 197 then 'Кипа архив 7Б'
			when 198 then 'Банановая коробка (комплект)'
			when 199 then 'Книги'
			when 200 then 'Газеты'
			when 201 then 'Мешки бумажные'
			when 202 then 'Яичная прокладка'
			when 203 then 'Кипа стрейч'
			when 204 then 'Кипа ПВД'
			when 205 then 'Стрейч'
			when 206 then 'ПВД'
			when 207 then 'Плёнка смешанная'
			when 208 then 'ПНД канистры'
			when 209 then 'Ящик фруктовый'
		end as custom_name,
		null as custom_memo,
		case m.material_id 
        	when 182 then 12500
			when 183 then 12500
			when 184 then 12500
			when 185 then 12500
			when 186 then 12500
			when 187 then 12500
			when 188 then 15
			when 189 then 10
			when 190 then 10
			when 191 then 10
			when 192 then 8
			when 193 then 30
			when 194 then 4.5
			when 195 then 5
			when 196 then 9
			when 197 then 10
			when 198 then 10
			when 199 then 7
			when 200 then 7
			when 201 then 0.5
			when 202 then 2
			when 203 then 40
			when 204 then 40
			when 205 then 25
			when 206 then 25
			when 207 then 10
			when 208 then 10
			when 209 then 3
		end as cost_per_unit,
		'руб/кг' as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'Фортис'
	and m.material_id between 182 and 209

	union all 
	select 
		rp.name as point_name,
		m.material_id,
		case m.material_id 
        	when 210 then 'Лом чёрный 3А'
			when 211 then 'Лом чёрный 5А, 12А'
			when 212 then 'Медь'
			when 213 then 'Медная колонка'
			when 214 then 'Латунь'
			when 215 then 'Бронза'
			when 216 then 'Радиатор медно-латунный'
			when 217 then 'Алюминий'
			when 218 then 'Алюминия профиль'
			when 219 then 'Алюминий пищевой'
			when 220 then 'Алюминий эл.тех'
			when 221 then 'Нержавейка'
			when 222 then 'Свинец'
			when 223 then 'Титан'
			when 224 then 'Стружка латунная'
		end as custom_name,
		'Указанная стоимость металлолома распространяется на оплату по безналичному расчету для партии от 100 кг. '
		'Просьба запрашивать стоимость на приемных пунктах.' as custom_memo,
		case m.material_id 
        	when 210 then 16
			when 211 then 16
			when 212 then 720
			when 213 then 500
			when 214 then 430
			when 215 then 450
			when 216 then 425
			when 217 then 125
			when 218 then 170
			when 219 then 180
			when 220 then 190
			when 221 then 50
			when 222 then 100
			when 223 then 150
			when 224 then 250
		end as cost_per_unit,
		'руб/кг' as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'Металлпрофи'
	and m.material_id between 210 and 224

	union all 
	select 
		rp.name as point_name,
		m.material_id,
		case m.material_id 
        	when 225 then 'картонные коробки'
			when 226 then 'Офисная бумага'
			when 227 then 'Книги и лишние тиражи'
			when 228 then 'Журналы и листовки'
			when 229 then 'Газеты'
			when 230 then 'Канистры'
			when 231 then 'ПЭТ бутылки'
			when 232 then 'Стрейч-плёнка'
			when 233 then 'Пластиковые ящики'
			when 234 then 'Алюминиевые банки'
			when 235 then 'Деревянные подддоны'
		end as custom_name,
		null as custom_memo,
		case  
        	when m.material_id = 225 then 5.7
			when m.material_id = 226 then 7.5
			when m.material_id = 227 then 8
			when m.material_id = 228 then 8
			when m.material_id = 229 then 8
			when m.material_id between 230 and 235 then null
		end as cost_per_unit,
		'руб/кг' as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'ARMAK52'
	and m.material_id between 225 and 235

	union all 
	select 
		rp.name as point_name,
		m.material_id,
		case m.material_id 
        	when 236 then 'Автомобильные катализаторы'
		end as custom_name,
		null as custom_memo,
		null as cost_per_unit,
		null as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'Выхлопoff'
	and m.material_id = 236

	union all 
	select 
		rp.name as point_name,
		m.material_id,
		case m.material_id 
        	when 237 then 'Алюминий'
			when 238 then 'Бронза'
			when 239 then 'Латунь'
			when 240 then 'Лом цинка'
			when 241 then 'Лом чёрного металла'
			when 242 then 'Лом цветных металлов'
			when 243 then 'Медь'
			when 244 then 'Нержавейка'
			when 245 then 'Никель'
			when 246 then 'Аккумуляторы'
			when 247 then 'Свинец'
			when 248 then 'Электронный лом'
		end as custom_name,
		null as custom_memo,
		case m.material_id 
        	when 237 then 130
			when 238 then 320
			when 239 then 420
			when 240 then 75
			when 241 then 15
			when 242 then 480
			when 243 then 720
			when 244 then 70
			when 245 then 48
			when 246 then 54
			when 247 then 30
			when 248 then 35
		end as cost_per_unit,
		'руб/кг' as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'Промконтракт'
	and m.material_id between 237 and 248

	union all 
	select 
		rp.name as point_name,
		m.material_id,
		case m.material_id 
        	when 249 then 'Керамика отечественные'
			when 250 then 'Керамика иномарки'
			when 251 then 'Керамика дизельные'
			when 252 then 'Сажевые фильтры (DPF/FAP)'
			when 253 then 'Металлические'
		end as custom_name,
		'Анализ материала (XRF рентгенофлуоресцентная спектрометрия) проводится промышленным спектрометром Niton. '
		'Металлы платиновой группы два раза в день меняются в цене, если у Вас большая партия, проконсультируйтесь '
		'с нашими специалистами когда лучше сдавать катализаторы, чтобы получить максимальную стоимость.' as custom_memo,
		case m.material_id 
        	when 249 then 25000
			when 250 then 130000
			when 251 then 50000
			when 252 then 9000
			when 253 then 18000
		end as cost_per_unit,
		'руб/кг' as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'ELEMENT 52'
	and m.material_id between 249 and 253

	union all 
	select 
		rp.name as point_name,
		m.material_id,
		case m.material_id 
        	when 254 then 'Лом цветных металлов'
			when 255 then 'Алюминий (дюраль)'
			when 256 then 'Алюминий (электротехнический)'
			when 257 then 'Алюминий (пищевой)'
			when 258 then 'Алюминий (банки)'
			when 259 then 'Медь (2-1)'
			when 260 then 'НСС (нержавейка)'
			when 261 then 'Латунь (3-1)'
			when 262 then 'Магний'
			when 263 then 'Цинк'
			when 264 then 'Свинец (рубашка)'
			when 265 then 'Свинец'
			when 266 then 'Титан'
			when 267 then 'Победит'
			when 268 then 'АКБ'
		end as custom_name,
		null as custom_memo,
		case m.material_id 
        	when 254 then null
			when 255 then 110
			when 256 then 140
			when 257 then 135
			when 258 then 60
			when 259 then 715
			when 260 then 60
			when 261 then 415
			when 262 then 65
			when 263 then 125
			when 264 then 105
			when 265 then 95
			when 266 then 220
			when 267 then null
			when 268 then 45
		end as cost_per_unit,
		'руб/кг' as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'Волга Металл'
	and m.material_id between 254 and 268

	union all 
	select 
		rp.name as point_name,
		m.material_id,
		case m.material_id 
        	when 269 then 'Алюминий электротехнический'
			when 270 then 'Алюминий пишевой'
			when 271 then 'Алюминий Профиль'
			when 272 then 'Алюминий моторный'
			when 273 then 'Алюминий микс'
			when 274 then 'Алюминий банка'
			when 275 then 'Алюминий стружка'
			when 276 then 'Алюминий кабель'
			when 277 then 'ВКТК'
			when 278 then 'Медь блеск'
			when 279 then 'Медь шина'
			when 280 then 'Медь кусок'
			when 281 then 'Медь микс'
			when 282 then 'Медь стружка'
			when 283 then 'медные провода в изоляции'
			when 284 then 'Латунь микс'
			when 285 then 'Латунь кусок'
			when 286 then 'Латунь стружка'
			when 287 then 'Бронза микс'
			when 288 then 'Бронза стружка'
			when 289 then 'Нержавеющая сталь с содержанием никеля 10%'
			when 290 then 'Нержавеющая сталь с содержанием никеля 10% (негабарит)'
			when 291 then 'Нержавеющая сталь с содержанием никеля 8%'
			when 292 then 'Нержавеющая сталь стружка'
			when 293 then 'Свинец кабельный'
			when 294 then 'Свинец плавленый'
			when 295 then 'АКБ полипропиленовые'
			when 296 then 'АКБ эбонитовые'
			when 297 then 'АКБ гелевые'
			when 298 then 'Титан кусок'
			when 299 then 'титан микс'
			when 300 then 'титан стружка'
			when 301 then 'цинк'
			when 302 then 'Нихром Ni 19% и более'
			when 303 then 'Никель аноды/катоды'
			when 304 then 'Лом аккумуляторов залит / слит'
			when 305 then 'лом электродвигателей'
		end as custom_name,
		null as custom_memo,
		case m.material_id 
        	when 269 then 115
			when 270 then 115
			when 271 then 115
			when 272 then 50
			when 273 then 65
			when 274 then 25
			when 275 then 33
			when 276 then 65
			when 277 then null
			when 278 then 740
			when 279 then 740
			when 280 then 740
			when 281 then 500
			when 282 then 350
			when 283 then 130
			when 284 then 420
			when 285 then 420
			when 286 then 210
			when 287 then 270
			when 288 then 146
			when 289 then 40
			when 290 then 40
			when 291 then 30
			when 292 then 25
			when 293 then 80
			when 294 then 80
			when 295 then 50
			when 296 then 50
			when 297 then 50
			when 298 then 100
			when 299 then 100
			when 300 then 85
			when 301 then 100
			when 302 then 100
			when 303 then 150
			when 304 then 40
			when 305 then 25
		end as cost_per_unit,
		'руб/кг' as unit
	from ReceptionPoints rp, Materials m
	where rp.name = 'Нижметалл'
	and m.material_id between 269 and 305
	
) as new_data 
join ReceptionPoints rp on rp.name = new_data.point_name
join Materials m on m.material_id = new_data.material_id
where not exists (
	select 1
	from ReceptionPointMaterials rpm
	where rpm.point_id = rp.point_id
	and rpm.material_id = m.material_id
)
on conflict (point_id, material_id) do nothing;

select rpm.*
from ReceptionPointMaterials rpm
join ReceptionPoints rp on rpm.point_id = rp.point_id
where rp.name = 'Нижметалл';

--запрос
/*select
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
order by distance;*/