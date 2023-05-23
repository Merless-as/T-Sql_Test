SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC dbo.pr (
@input NVARCHAR(MAX),        -- Входной параметр
@output NVARCHAR(MAX) OUTPUT -- Выходной параметр
)

AS
BEGIN 

    -- Инициализирование переменной для работы с полем "action"
    DECLARE @in NVARCHAR(MAX);
    SET @in = JSON_VALUE(@input, '$.action');

    IF (@in = N'Получить список авто на складе')  

        SET @output = (
            SELECT b.Name, s.Name, s.Count, s.Price 
            FROM dbo.stock s
            JOIN dbo.brand b ON b.id=s.id_brand
            FOR JSON AUTO
        );

    ELSE IF (@in = N'Получить список авто на складе определенной марки')
        BEGIN

            -- Валидация на существование марки в таблице
            IF (EXISTS (
                    SELECT b.Name 
                    FROM dbo.brand b
                    WHERE b.Name = JSON_VALUE(@input, '$.description.Name')
                )
            )
                SET @output = (
                    SELECT b.Name, s.Name, s.Count, s.Price 
                    FROM dbo.stock s
                    JOIN dbo.brand b ON b.id=s.id_brand
                    WHERE b.Name = JSON_VALUE(@input, '$.description.Name')
                    FOR JSON AUTO
                ); 
                
            ELSE 
                SET @output = (
                    SELECT 400 as code, N'Такой марки нет' as answer 
                    FOR JSON PATH
                );

        END;

    ELSE IF (@in = N'Продать указав марку, менеджера по продажам')
        BEGIN
            -- Валидация на существование марки и менеджера в таблицах
            IF (EXISTS (SELECT a.id 
                FROM agents a
                WHERE a.Name =  JSON_VALUE(@input, '$.description.agent_Name')
                ) AND EXISTS (
                    SELECT s.id 
                    FROM dbo.stock s
                    WHERE s.Name = JSON_VALUE(@input, '$.description.auto_Name')
                )
            )
                BEGIN
                    -- Проверка количества авто на складе
                    IF (
                        (SELECT s.Count
                        FROM dbo.stock s
                        WHERE s.Name =  JSON_VALUE(@input, '$.description.auto_Name')
                        ) > 0
                    )
                        BEGIN
                            -- Проверка нахождения клиента в таблице
                            IF (NOT EXISTS (
                                SELECT c.Name
                                FROM dbo.clients c
                                WHERE c.Name = JSON_VALUE(@input, '$.description.client.Name')
                                )
                            )
                            BEGIN
                                INSERT INTO dbo.clients (Name, Number) 
                                (
                                    SELECT js.client_Name, js.Number
                                    FROM OPENJSON(@input) WITH (
                                        client_Name NVARCHAR(40) '$.description.client.Name',
                                        Number NVARCHAR(40) '$.description.client.Number'
                                    ) js
                                )
                            END;

                            -- Вставка записи в таблицу продаж
                            INSERT INTO dbo.sales (id_client, id_agent, id_auto, Price, Date)
                            (
                                SELECT c.id as id_client, a.id as id_agent,
                                s.id as id_auto, s.Price as Price, js.Date as Date
                                FROM OPENJSON(@input) WITH (
                                    client_Name NVARCHAR(40) '$.description.client.Name',
                                    agent_Name NVARCHAR(40) '$.description.agent_Name',
                                    auto_Name NVARCHAR(40) '$.description.auto_Name',
                                    Date DATE '$.description.Date'
                                ) js
                                JOIN dbo.clients c ON c.Name=js.client_Name
                                JOIN dbo.agents a ON a.Name = js.agent_Name
                                JOIN dbo.stock s ON s.Name=js.auto_Name
                            );

                            -- Изменение количества авто на складе
                            UPDATE dbo.stock 
                            SET Count = Count - 1
                            WHERE Name =  JSON_VALUE(@input, '$.description.auto_Name');

                            SET @output = (
                                SELECT 200 as code, N'Продажа прошла успешно' as answer 
                                FOR JSON PATH
                            )
                        END

                    ELSE 
                        SET @output = (
                            SELECT 400 as code, N'Количество автомобилей равно 0' as answer 
                            FOR JSON PATH
                        );

                END;

            ELSE 
                SET @output = (
                    SELECT N'Такой марки или менеджера нет' as answer 
                    FOR JSON PATH
                );
        END;

    ELSE IF (@in = N'Получить список продаж менеджера по ид менеджера, начало периода, конец периода')

        BEGIN
            /*  Валидация на существование менеджера в таблице 
                Проверка на правильный ввод даты  */
            IF (EXISTS (
                        SELECT a.id 
                        FROM agents a
                        WHERE a.Name =  JSON_VALUE(@input, '$.description.agent_Name')
                    ) AND 
                    JSON_VALUE(@input, '$.description.date_start') <=
                    JSON_VALUE(@input, '$.description.date_end')
                )
                SET @output = (
                    SELECT a.Name, s.id, s.Date, s.Price
                    FROM dbo.agents a
                    JOIN dbo.sales s ON s.id_agent=a.id
                    JOIN (
                        SELECT agent_Name, Date_Start, Date_End
                        FROM OPENJSON(@input) WITH (
                            agent_Name NVARCHAR(40) '$.description.agent_Name',
                            Date_Start DATE '$.description.date_start',
                            Date_End DATE '$.description.date_end'
                        )
                    ) js ON js.agent_Name=a.Name
                    WHERE s.Date BETWEEN js.Date_Start AND js.Date_End
                    AND s.Date IS NOT NULL 
                    FOR JSON AUTO
                );

            ELSE 
                SET @output = (
                    SELECT 400 as code, N'Такого менеджера нет или время было указано неверно' as answer 
                    FOR JSON PATH
                );
        END;

    ELSE IF (@in = N'Получить список менеджеров')

        SET @output = (
            SELECT a.Name, a.Date
            FROM dbo.agents a
            FOR JSON AUTO
        );

    ELSE IF (@in = N'Получить список марок авто')   

        SET @output = (
            SELECt b.Name, b.Country
            FROM dbo.brand b
            FOR JSON AUTO
        );

    ELSE 
        -- Ответ при неправильном/отсутсвуещем параметре "action"
        SET @output = (
            SELECT 400 as code,  N'Я не знаю такой инструкции' as answer 
            FOR JSON PATH
        );
END
GO