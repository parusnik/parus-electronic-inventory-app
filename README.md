# Parus Electronic Inventory

[![Join the chat at https://gitter.im/parussmartinventory/parussmartinventory](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/parussmartinventory/parussmartinventory?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Электронная инвентаризация для Парус 8.

## Описание

В данном репозитории содержатся вспомогательные объекты Парус-Бюджет 8 для проведения электронной инвентаризации.

### Расширения для Парус-Бюджет 8
* [Местонахождение инвентарных объектов: Сгенерировать штрих-код](src/p_beldicplace_gen_barcode.sql)
* [Местонахождение инвентарных объектов: Экспорт в Parus Smart Inventory](src/p_beldicplace_csvexp.sql)
* [Инвентаризирующие лица: Экспорт в Parus Smart Inventory](src/p_belinvpersons_csvexp.sql)
* [Электронные инвентаризации: Экспорт в Parus Smart Inventory](src/p_belinventory_csvexp.sql)
* [Электронные инвентаризации: Импорт из Parus Smart Inventory](src/p_belinventory_csvimp.sql)
* [Электронные инвентаризации: Импорт из Parus Smart Inventory (Postgres)](src/p_belinventory_csvimp.pgsql)

Так же для корректной работы в СУБД Oracle Database требуется предварительная установка пакета [lob2table](addons/lob2table.sql).

### Формирование штрих-кода

Для формирования пользовательского отчета с этикетками, содежащими штрих-кода, необходимо наличие пакета [pkg_barcode](addons/pkg_barcode.sql).

*При этом необходимо скомпилировать все версии пакета pkg_barcode*.sql*

На сервере и рабочем месте пользователя должен быть установлен шрифт [LibreBarcode128-Regular.ttf](addons/LibreBarcode128-Regular.ttf)).

### Пользовательские отчеты

Для печати этикеток разработан отчет [Печать штрих-кодов 2022](src/p_belinventory_barcode_2022.sql).
Шаблон отчета [BELINVENTORY_BARCODE_2022](templates/BELINVENTORY_BARCODE_2022.xlsx)

#### Описание отчета

| Мнемокод       | Наименование            | Файл                           | Хранимая процедура          | Размер файла | Тип             | Пользовательский | Сохранять историю печати | Блокировать при формировании | Создать PDF | Пиктограмма |
|----------------|-------------------------|--------------------------------|-----------------------------|--------------|-----------------|------------------|--------------------------|------------------------------|-------------|-------------|
| BELBARCODE2022 | Печать штрих-кодов 2022 | BELINVENTORY_BARCODE_2022.XLSX | P_BELINVENTORY_BARCODE_2022 | 10 KB        | Microsoft Excel | Да               | Нет                      | Да                           | Нет         |

#### Параметры отчета

| Порядок сортировки | Наименование | Тип данных           | Приглашение ко вводу               | Привязка                         | Обязательный | Раздел | Метод вызова | Параметр | Наименование родительского параметра | Дополнительный словарь | Параметр хранимой процедуры |
|--------------------|--------------|----------------------|------------------------------------|----------------------------------|--------------|--------|--------------|----------|--------------------------------------|------------------------|-----------------------------|
| 1                  | NIDENT       | Число (number)       | NIDENT                             | Идентификатор помеченных записей | Да           |        |              |          |                                      |                        | NIDENT                      |
| 2                  | NONLY_PLACE  | Логический (boolean) | Формировать только местонахождения | Нет                              | Да           |        |              |          |                                      |                        | NONLY_PLACE                 |

## Мобильное приложение

|Платформа|Статус|Релиз|
|---|---|---|
|Android|[![Build Status](https://dev.azure.com/parussmartinventoryeng/ParusSmartInventory-mobile-apps/_apis/build/status/ParusSmartInventory-mobile-apps.CI)](https://dev.azure.com/parussmartinventoryeng/ParusSmartInventory-mobile-apps/_build/latest?definitionId=1)|[Android App](https://install.appcenter.ms/orgs/parusnik-belgorod/apps/parus-smart-inventory/distribution_groups/public)|

Мобильное приложение позволяет производить инвентаризацию объектов выгруженных из Парус-Бюджет 8, а так же сформировать файл экспорта результатов инвентаризации с последующим импортом в Парус.

<img src="docs/images/logo.png" Width="210" /> <img src="docs/images/signin.png" Width="210" /> <img src="docs/images/menu.png" Width="210" /> <img src="docs/images/home.png" Width="210" /> <img src="docs/images/locations.png" Width="210" /> <img src="docs/images/items.png" Width="210" /> <img src="docs/images/user.png" Width="210" /> <img src="docs/images/import_export.png" Width="210" /> 