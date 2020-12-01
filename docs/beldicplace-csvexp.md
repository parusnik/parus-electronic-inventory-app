# Экспорт местонахождений инвентарных объектов

Процедура экспорта местонахождений инвентарных объектов посредством механизма **Обмен/Экспорт в файл**.

## Установка

Скомпилировать процедуру [p_beldicplace_csvexp](..\src\p_beldicplace_csvexp.sql).

Добавить в Парус-Бюджет 8 пользовательскую процедуру:

|Мнемокод|Наименование|Тип|Способ выполнения|Имя хранимой процедуры|Блокировка при выполнении|Пиктограмма|
|---|---|---|---|---|---|---|
|BelObjPlaceExp|Экспорт местоположений для инвентаризации|Процедура|Ручной|P_BELDICPLACE_CSVEXP|Нет|

Настроить параметры:

|Позиция|Наименование параметра|Тип данных|Тип параметра|Описание параметра|Визуализация|Привязка|Обязательный|Раздел|Метод вызова|Параметр|Родительский параметр|Дополнительный словарь|
|---|---|---|---|---|---|---|---|---|---|---|---|---|
|1|NCOMPANY|Число (number)|Входной (in)|NCOMPANY|Нет|К организации|Да||||||
|2|NIDENT|Число (number)|Входной (in)|NIDENT|Нет|К идентификатору ведомости|Да||||||
|3|SDOC_NUMB|Строка (varchar2)|Входной (in)|SDOC_NUMB|Нет|Нет|Нет||||||
|4|SDOC_PREF|Строка (varchar2)|Входной (in)|SDOC_PREF|Нет|Нет|Нет||||||
|5|SDOC_TYPE|Строка (varchar2)|Входной (in)|SDOC_TYPE|Нет|Нет|Нет||||||

Добавить пользовательскую форму и загрузить ее описание из [p_beldicplace_csvexp.xml](../forms/p_beldicplace_csvexp.xml).