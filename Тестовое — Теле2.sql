Задание № 1
В Таблице Table_SQL данные о посещении абонентами некоторой локации. 
Необходимо с помощью алгоритма на языке SQL привести её 
к следующему виду:
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
subs_id          START_DTTM    END_DTTM
1452214526665    01.01.2021    05.01.2021
1452214526665    07.01.2021    11.01.2021
1452214526665    13.01.2021    13.01.2021
1452214526665    18.01.2021    26.01.2021
1452214526665    28.01.2021    31.01.2021
2458741444746    03.01.2021    06.01.2021
2458741444746    27.01.2021    31.01.2021
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Table_SQL

SubsID              DateID  
1452214526665    01.01.2021
1452214526665    02.01.2021
1452214526665    03.01.2021 1
1452214526665    04.01.2021 1
1452214526665    05.01.2021 0
1452214526665    07.01.2021 1
1452214526665    08.01.2021 1
1452214526665    09.01.2021 1
1452214526665    10.01.2021 1
1452214526665    11.01.2021 1
1452214526665    18.01.2021 0
1452214526665    19.01.2021 1
1452214526665    20.01.2021 1
1452214526665    21.01.2021 1
1452214526665    22.01.2021 1
1452214526665    23.01.2021 1
1452214526665    24.01.2021 1
1452214526665    25.01.2021 1
1452214526665    26.01.2021 0
1452214526665    28.01.2021
1452214526665    29.01.2021
1452214526665    30.01.2021
1452214526665    31.01.2021
2458741444746    03.01.2021
2458741444746    04.01.2021
2458741444746    05.01.2021
2458741444746    06.01.2021
2458741444746    27.01.2021
2458741444746    28.01.2021
2458741444746    29.01.2021
2458741444746    30.01.2021
2458741444746    31.01.2021



----------------------
РЕШЕНИЕ


SELECT
    subs_id AS subs_id,
    MIN(date_id) AS START_DTTM,
    MAX(date_id) AS END_DTTM
FROM

    (

	SELECT
		rw,
		subs_id,
		date_id,
		_FLAG,
		ROW_NUMBER() OVER (PARTITION BY subs_id, _FLAG ORDER BY date_id) rn1,
		ROW_NUMBER() OVER (PARTITION BY subs_id ORDER BY date_id) rn2,
		CASE 
			WHEN _FLAG = 1 THEN 
				ROW_NUMBER() OVER (PARTITION BY subs_id, _FLAG ORDER BY date_id) - _FLAG 
			ELSE 
				ROW_NUMBER() OVER (PARTITION BY subs_id ORDER BY date_id) 
				- ROW_NUMBER() OVER (PARTITION BY subs_id, _FLAG ORDER BY date_id) 
			END AS grp
	FROM	
				(   
					SELECT
					ROW_NUMBER() OVER () AS rw,
						subs_id,
						date_id,
					CASE WHEN 
					LEAD(date_id) OVER (partition by subs_id ORDER BY date_id) - date_id > 1 THEN 1 ELSE 0 END as _FLAG
					FROM users_tele_2
				) t1		
    ) t2
	
GROUP BY
    subs_id,
    grp
ORDER BY
    subs_id,
    START_DTTM;








----------------------
Текс запроса:

Задание № 2

Написать запрос, который выведет модель последнего устройства у клиента (user_id / vendor_name / start_date / end_date)

Table
-----------------------------------------------------------------------------------------------------------------------------------------
              Справочник мобильных устройств (devices):
    device_id    vendor_name        price
    1            Apple             85000                                                                                       
    2            Samsung           60000                                                                                   
    3            Xiaomi            25000                                                                               
    4            Huawei            30000



    История смен мобильных устройств пользователями (history_log):
    user_id    device_id       start_date    end_date
    1            1            21.02.2020    16.08.2020
    1            2            17.08.2020    18.10.2020
    1            3            19.10.2020    13.02.2021
    2            2            18.01.2019    22.03.2021
    2            2            23.03.2021    31.12.2999
    3            2            02.02.2015    03.09.2017
    3            3            04.09.2017    21.03.2019
    3            1            22.03.2019    02.02.2021

----------------------
РЕШЕНИЕ


SELECT * 
FROM
(    
SELECT
    user_id
    ,vendor_name
    ,start_date
    ,end_dat
    row_number() over (PARTITION BY user_id order by end_date desc) as _rank
FROM t1
    LEFT JOIN t2 ON t1.device_id = t2.device_id
    )
    
WHERE   _rank = 1 
    
   
    
    














