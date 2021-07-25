# Тестовое задание "Регистр счетов в банке"

## Описание приложения
Создать систему учета банковских счетов пользователей.

### Функциональность
* Создание пользователя с указанием тегов.
	Для создания пользователя нужно заполнить поля: ФИО,идентификационный номер, теги.
	Ограничения: нельзя создать двух пользователей с одинаковым идентификационным номером.
	Сделать максимально просто. Пример: отдельный эндпоинт, rake-task или часть "меню" cli.
	
* Открытие счета для пользователя по идентификационному номеру пользователя.
	Для открытия счета нужно заполнить поля: валюта (по стандарту ISO4217), идентификационный номер пользователя. После открытия счета система указывает уникальный номер нового счета.
	Ограничения: пользователь не может создать два счета с одной и той жевалютой, сумма должна быть неотрицательной.
* Пополнение счета по идентификационному номеру пользователя и валюте на определенную сумму. Если у получателя нет счета в данной валюте, необходимо создать и провести операцию.
* Перевод между счетами по идентификационному номеру пользователя-отправителя, валюте и идентификационному номеру получателя. Если уполучателя нет счета в данной валюте, необходимо создать и провести операцию.
* Отчет "О сумме пополнений за период времени по-валютно" свозможностью фильтрации по пользователям.
* Отчет "Средняя, максимальная и минимальная сумма переводов по тегам пользователей за период времени" с возможностью фильтрации по тегам.
* Отчет "Сумма всех счетов на текущий момент времени повалютно" с фильтрацией по тегам пользователей.

## Требования

* Реализовать проект на языке ruby.
* Для реализации можно использовать:
	* любой веб-фреймворк в режиме json api (пример: rails, sinatra, hanami-api, roda);
	* или консольное приложение без веб-интерфеса.
* Для работы с проектом, зависимостями и gems использовать bundler.
* Написать тесты с использованием rspec на функционал "Перевод между счетами" и отчет "о сумме пополнений за период времени по-валютно".
* Можно добавлять ограничения на функциональность по своему усмотрению, но они должны быть логичны и причины описаны в Readme-файле.
* Разрешается добавлять дополнительные сущности, индексы, связи,классы, модули и ограничения  и т.п. по мере необходимости. В Readme-файле указать причины добавления.
* Предоставить выполненное задание в виде ссылки на открытый репозиторий на github. Все замечания, идеи для проверяющего просьба поместить в Readme-файл.

### Дополнительно будет учитываться

* дополнительное покрытие тестами
* документация о том, как разворачивать приложение и работать с приложением 
* дополнительный функционал, что все отчеты могут быть выведены на экран или в csv файл на диске
* docker-контейнер или деплой проекта


## Взаимодействие с приложением

Для взаимодействия с приложением можно использовать программу cURL:
на локальном сервере: http://localhost:3000
на Heroku: https://bankregister.herokuapp.com

### Создание нового пользователя

curl -d '{"first_name":"1","last_name":"2","patronimic":"3","identification_number":"pp1111222"}' -H "Content-Type: application/json" -X POST http://localhost:3000/users

В ответ получим либо словарь с новым юзером: 

{"id":5,"first_name":"1","last_name":"2","patronimic":"3","identification_number":"pp1111222","created_at":"2021-07-23T09:10:05.104Z","updated_at":"2021-07-23T09:10:05.104Z"}

Либо словарь с сообщением, что пользователь с таким идентификационным номером уже существует:

{"identification_number":["has already been taken"]}

### Открытие счета для пользователя по идентификационному номеру пользователя

curl -d '{"account":{"currency":"pln"}, "identification_number":"pp1111222"}' -H "Content-Type: application/json" -X POST http://127.0.0.1:3000/accounts/

Ответ:

{"id":9,"user_id":5,"currency":"pln","amount":"0.0","created_at":"2021-07-23T11:49:22.255Z","updated_at":"2021-07-23T11:49:22.255Z"}

### Пополнение счета по идентификационному номеру пользователя и валюте на определенную сумму

curl -d '{"account":{"currency":"pln","amount":"0.3"}}' -H "Content-Type: application/json" -X POST http://127.0.0.1:3000/transactions/1213a1aa/deposit

Ответ: 

{"id":8,"user_id":4,"currency":"pln","amount":"0.6","created_at":"2021-07-23T09:48:06.597Z","updated_at":"2021-07-23T09:48:06.597Z"}

### Перевод между счетами по идентификационному номеру пользователя-отправителя, валюте и идентификационному номеру получателя

curl -d '{"account":{"currency":"rub","amount":"0.1"},"recipient_identification_number":"123aa2a","sender_identification_number":"1213a1aa"}' -H "Content-Type: application/json" -X POST http://127.0.0.1:3000/transactions/transfer 

Ответ в случае неудачи:

{"error":"Validation failed: Amount must be greater than or equal to 0"} или {"recipient":["must exist"]}