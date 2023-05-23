DECLARE @answer NVARCHAR(MAX);

--EXEC dbo.pr N'{"action" : "Получить список авто на складе"}', @output=@answer OUTPUT;

--SELECT @answer;

EXEC dbo.pr N'{
    "action" : "Получить список авто на складе определенной марки",
    "description" : {
            "Name" : "Toyota"
        } 
    }', @output=@answer OUTPUT;

SELECT @answer;

-- Проверка валидации
EXEC dbo.pr N'{
    "action" : "Получить список авто на складе определенной марки",
    "description" : {
            "Name" : "Какая-то noName марка"
        } 
    }', @output=@answer OUTPUT;

SELECT @answer;


EXEC dbo.pr N'{
    "action" : "Продать указав марку, менеджера по продажам",
    "description" : {
            "client": {
                "Name" : "Samanta",
                "Numbwer" : ""
            },
            "agent_Name" : "Jack",
            "auto_Name" : "Camry",
            "Date" : "9-05-2002"
        } 
    }', @output=@answer OUTPUT;

SELECT @answer;


SELECT TOP(1) id, id_client, id_agent, id_auto, Price, Date
FROM dbo.sales
ORDER BY id DESC;

-- Проверка добавления клиента
EXEC dbo.pr N'{
    "action" : "Продать указав марку, менеджера по продажам",
    "description" : {
            "client": {
                "Name" : "Marta",
                "Number" : "500-600"
            },
            "agent_Name" : "Jack",
            "auto_Name" : "Camry",
            "Date" : "12-05-2002"
        } 
    }', @output=@answer OUTPUT;

SELECT @answer;

SELECT TOP(1) id, id_client, id_agent, id_auto, Price, Date
FROM dbo.sales
ORDER BY id DESC;

SELECT TOP(1) id, Name, Number
FROM dbo.clients
ORDER BY id DESC;

-- Проверка количества машин
EXEC dbo.pr N'{
    "action" : "Продать указав марку, менеджера по продажам",
    "description" : {
            "client": {
                "Name" : "Marta",
                "Number" : "500-600"
            },
            "agent_Name" : "Jack",
            "auto_Name" : "222",
            "Date" : "10-05-2002"
        } 
    }', @output=@answer OUTPUT;

SELECT @answer;

-- Проверка валидации
EXEC dbo.pr N'{
    "action" : "Продать указав марку, менеджера по продажам",
    "description" : {
            "client": {
                "Name" : "Samanta",
                "Number" : ""
            },
            "agent_Name" : "Незнакомец",
            "auto_Name" : "Camry",
            "Date" : "11-05-2002"
        } 
    }', @output=@answer OUTPUT;

SELECT @answer;

-- Проверка валидации
EXEC dbo.pr N'{
    "action" : "Продать указав марку, менеджера по продажам",
    "description" : {
            "client": {
                "Name" : "Marta",
                "Number" : "500-600"
            },
            "agent_Name" : "Jack",
            "auto_Name" : "Какая-то noName марка",
            "Date" : "15-05-2002"
        } 
    }', @output=@answer OUTPUT;

SELECT @answer;

EXEC dbo.pr N'{
    "action" : "Получить список продаж менеджера по ид менеджера, начало периода, конец периода",
    "description" : {
            "agent_Name" : "Jack",
            "date_start" : "10-05-2002",
            "date_end" : "12-05-2002"
        } 
    }', @output=@answer OUTPUT;

SELECT @answer;

-- Проверка валидации
EXEC dbo.pr N'{
    "action" : "Получить список продаж менеджера по ид менеджера, начало периода, конец периода",
    "description" : {
            "agent_Name" : "Незнакомец",
            "date_start" : "10-05-2002",
            "date_end" : "15-05-2002"
        } 
    }', @output=@answer OUTPUT;

SELECT @answer;

-- Проверка валидации
EXEC dbo.pr N'{
    "action" : "Получить список продаж менеджера по ид менеджера, начало периода, конец периода",
    "description" : {
            "agent_Name" : "Jack",
            "date_start" : "20-05-2002",
            "date_end" : "15-05-2002"
        } 
    }', @output=@answer OUTPUT;

SELECT @answer;

EXEC dbo.pr N'{"action" : "Получить список менеджеров"}', @output=@answer OUTPUT;

SELECT @answer;

EXEC dbo.pr N'{"action" : "Получить список марок авто"}', @output=@answer OUTPUT;

SELECT @answer;