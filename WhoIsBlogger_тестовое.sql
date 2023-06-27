-- Создаем таблицы

CREATE TABLE users (
    userid SERIAL PRIMARY KEY,                  --  уникальный ид   
    age INTEGER NOT NULL          
);

CREATE TABLE items (  
    itemid SERIAL PRIMARY KEY,                  --  уникальный ид  
    price DECIMAL(5,0)
);

CREATE TABLE purchases  ( 
    purchaseid SERIAL PRIMARY KEY,              --  уникальный ид 
	userid INTEGER REFERENCES users(userid),    -- ссылка на первичный ключ таблицы users
    itemid INTEGER REFERENCES items(itemid),    -- ссылка на первичный ключ таблицы items
    date DATE
);

--------------------------------------------------------------

-- Заполняем таблицы данными

INSERT INTO users (age)
SELECT (random() * 45 + 16)::integer    -- возраст покупателей от 16 до 60
FROM generate_series(1, 200);           -- 200 записей

SELECT * FROM users;


INSERT INTO items (price) 
SELECT (random()* 5000)::decimal        -- цены на товары от 0 до 5000
FROM generate_series(1, 200);           -- 200 записей

SELECT * FROM items;

-- создадим таблицу случайных дат в интервале 2023-**-**
CREATE TABLE dates (             
    DATES DATE          
);
INSERT INTO dates (DATES)
SELECT 
	MAKE_DATE(2023, 1 + CAST(RANDOM() * 11 AS INTEGER), 1 + CAST(RANDOM() * 27 AS INTEGER))
FROM generate_series(1, 1000);

-- Заполняем таблицу purchases данными 

INSERT INTO purchases (userid, itemid, date)
SELECT 
	u.userid, 
	i.itemid, 
	d.dates     -- интервал 2023 год
FROM users u, items i, dates d
ORDER BY random()
LIMIT 1000;                                                                      -- 1000 записей
						 					 
SELECT * FROM purchases;


--------------------------------------------------------------
-- Задание №1
-- Какую сумму в среднем в месяц тратит:
-- - пользователи в возрастном диапазоне от 18 до 25 лет включительно
-- - пользователи в возрастном диапазоне от 26 до 35 лет включительно

-- соединяем по ключам таблицы purchases, items, users
-- извлекаем из даты месяц, устанавливаем условия для выбора возрастной категории, создаем временную колонку AGE_CATEGORY
-- проводим группировку по месяцу и возрастной категории, сортируем по месяцам

SELECT 
	EXTRACT(MONTH FROM p.date) AS month,
	CASE
		WHEN u.age >=18 AND u.age <= 25 THEN 'AGE_18_25'
		WHEN u.age >=26 AND u.age <= 35 THEN 'AGE_26_35' ELSE 'other' END AS "AGE_CATEGORY",
	ROUND(AVG(i.price), 2) AS avg_spending
FROM purchases p
	JOIN items i ON p.itemid = i.itemid
	JOIN users u ON p.userid = u.userid
GROUP BY EXTRACT(MONTH FROM date), "AGE_CATEGORY"
ORDER BY EXTRACT(MONTH FROM date);



--------------------------------------------------------------
-- Задание №2
-- В каком месяце года выручка от пользователей в возрастном диапазоне 35+ самая большая

-- соединяем по ключам таблицы purchases, items, users
-- группируем выручку по месяцам, устанавливаем возрастное условие, после сортировки по убыванию берем первую строку

SELECT to_char(p.date, 'Month') AS month, SUM(i.price) AS revenue
FROM purchases p
	JOIN items i ON p.itemid = i.itemid
	JOIN users u ON p.userid = u.userid
WHERE u.age >= 35
GROUP BY month
ORDER BY revenue DESC
LIMIT 1;

--------------------------------------------------------------
-- Задание №3
-- Какой товар обеспечивает, дает наибольший вклад в выручку за последний год

-- соединяем по ключам таблицы purchases, items, users
-- выполняем условие последнего года
-- группируем по товару и считаем выручку, после сортировки по убыванию берем первую строку

SELECT i.itemId, SUM(i.price) AS revenue
FROM purchases p
	JOIN items i ON p.itemid = i.itemid
	JOIN users u ON p.userid = u.userid
WHERE p.date >= NOW() - INTERVAL '1 year'
GROUP BY i.itemId
ORDER BY revenue DESC
LIMIT 1;

--------------------------------------------------------------
-- Задание №4
-- Топ-3 товаров по выручке и их доля в общей выручке за любой год

-- во вложенной талице t1 соединяем по ключам таблицы purchases, items, users
-- группируем данные по году и по itemid, считаем сумму выручки
-- в основном запросе считаем выручку по кажому товару и долю от общей выручки, оставляем топ-3

WITH t1 AS (
	SELECT 
	    EXTRACT(YEAR FROM p.date) AS _YEAR,
		i.itemid,
		SUM(i.price) AS item_revenue
	FROM purchases p
		JOIN items i ON p.itemid = i.itemid
		JOIN users u ON p.userid = u.userid
	GROUP BY 1, 2
	ORDER BY item_revenue DESC
)

SELECT 
	_YEAR,
	itemid, 
	item_revenue, 
	ROUND(100* item_revenue / (SELECT SUM(item_revenue) FROM t1),2) AS revenue_rate
FROM t1
LIMIT 3;