# Parus Electronic Inventory for Oracle

[![Join the chat at https://gitter.im/parussmartinventory/parussmartinventory](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/parussmartinventory/parussmartinventory?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Электронная инвентаризация для Парус 8.

## Описание

В данном репозитории содержатся вспомогательные объекты Парус-Бюджет 8 для проведения электронной инвентаризации.

### Расширения для Парус-Бюджет 8
* [Массовое формирование штрих-кода](docs/beldicplace-gen-barcode.md)
* [Экспорт местонахождений инвентарных объектов](docs/beldicplace-csvexp.md)
* [Экспорт инвентаризирующих лиц](docs/belinvpersons-csvexp.md)
* [Экспорт инвентарных объектов](docs/belinventory-csvexp.md)
* [Импорт результатов инвентаризации](docs/belinventory-csvimp.md)

Так же для корректной работы требуется предварительная установка пакета [lob2table](addons/lob2table.sql).

## Мобильное приложение

|Платформа|Статус|Релиз|
|---|---|---|
|Android|[![Build Status](https://dev.azure.com/parussmartinventoryeng/ParusSmartInventory-mobile-apps/_apis/build/status/ParusSmartInventory-mobile-apps.CI)](https://dev.azure.com/parussmartinventoryeng/ParusSmartInventory-mobile-apps/_build/latest?definitionId=1)|[Android App](https://install.appcenter.ms/orgs/parusnik-belgorod/apps/parus-smart-inventory/distribution_groups/public)|

Мобильное приложение позволяет производить инвентаризацию объектов выгруженных из Парус-Бюджет 8, а так же сформировать файл экспорта результатов инвентаризации с последующим импортом в Парус.

<img src="docs/images/logo.png" Width="210" /> <img src="docs/images/signin.png" Width="210" /> <img src="docs/images/menu.png" Width="210" /> <img src="docs/images/home.png" Width="210" /> <img src="docs/images/locations.png" Width="210" /> <img src="docs/images/items.png" Width="210" /> <img src="docs/images/user.png" Width="210" /> <img src="docs/images/import_export.png" Width="210" /> 