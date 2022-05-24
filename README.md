# nikey176_microservices
nikey176 microservices repository

Технология контейнеризации. Введение в Docker
---
#### 1. Создание образа reddit
1. Добавлен Dockerfile
2. Добавлены файлы, необходимые для запуска Dockerfile

#### 2. Самостоятельные задания
1. Все действия выполнялись в папке **docker-monolith/infra**
2. Созданы плейбуки для:  
   - установки Docker  
   - запуска контейнера _otus-reddit_ из репозитория в Docker Hub  
3. Создан динамический инвентори
4. Создан шаблон packer для упаковки docker'а в образ
5. Настроен terraform для поднятия инстансов из образа с docker'ом  
   - идентификатор образа передается в переменной _docker_disk_image_  
   - добавлена output-переменная _hostname_, необходимая для динамического инвентори Ansible  

Docker-образы. Микросервисы
---
#### 1. Новая структура приложения
1. Приложение разбито на 3 компонента
   - post-py
   - comment
   - ui
2. Для каждого компонента настроен Dockerfile
3. Добавлена bridge-сеть reddit
4. Подключен том (volume) к контейнеру с БД для хранения постоянных данных
```
docker volume create reddit_db
docker container run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
```
#### 2. Дополнительные задания
1. Запуск контейнеров с сетевыми алиасами, отличными от Dockerfile
```
docker run -d --network=reddit --network-alias=post_db_1 --network-alias=comment_db_1 -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post_1 -e POST_DATABASE_HOST='post_db_1' nchernukha/post:1.0
docker run -d --network=reddit --network-alias=comment_1 -e COMMENT_DATABASE_HOST='comment_db_1' nchernukha/comment:1.0
docker run -d --network=reddit -p 9292:9292 -e POST_SERVICE_HOST='post_1' -e COMMENT_SERVICE_HOST='comment_1' nchernukha/ui:3.0
```
2. Оптимизация размера образов comment и ui
   - в качестве базового образа использован образ alpine:3.14.6
   - для менеджера пакетов apk использован ключ --no-cache
   - при установке библиотеки bundler использован ключ --no-document
