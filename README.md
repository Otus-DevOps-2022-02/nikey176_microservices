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
