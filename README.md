# Библиотека бизнес-логики заявки на услугу социальной защиты

Библиотека предоставляет бизнес-логику заявки на услугу социальной защиты
сервису `case_core`. Поддерживает услуги, при оказании которых передача пакета
документов и выдача результата осуществляется в электронном виде.

## Запуск тестов

Для запуска тестов рекомендуется использовать виртуальную машину, которую можно
запустить с помощью следующей команды в терминале в корневой директории
Git-репозитория библиотеки:

```
vagrant up
```

После создания, запуска и настройки виртуальной машины необходимо зайти в неё с
помощью команды

```
vagrant ssh
```

Если виртуальная машина была только создана, необходимо установить требуемые
библиотеки с помощью следующей команды в терминале виртуальной машины:

```
bundle install
```

Запустить тесты можно с помощью следующей команды в терминале виртуальной
машины:

```
make test
```

## Сборка

Для сборки библиотеки в Gem-файл можно использовать следующую команду:

```
make build
```

Gem-файл создаётся в корневой директории Git-репозитория библиотеки.

## Непрерывная интеграция Gitlab

При создании нового тега с номером версии Gitlab автоматически собирает
библиотеку и помещает её в [сервер библиотек](http://nexus.it2.vm).

## Использование

Для установки бизнес-логики, предоставляемой библиотекой, необходимо
использовать следующую команду в терминале в директории с запущенным сервисом
`case_core`:

```
bundle exec rake case_core:fetch_logic[sd_full_auto_case]
```

При этом произойдёт загрузка последней версии библиотеки с сервера библиотек, а
также распаковка загруженного Gem-файла в директорию с бизнес-логикой сервиса
`case_core`. Сервис автоматически загрузит последнюю версию библиотеки в память
своего процесса.
