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

Docker-compose
---
#### 1. Запуск приложения reddit с помощью Docker Compose
##### Запуск docker-compose под кейс с множеством сетей, сетевых алиасов
- определяем сети _front_net_ и _back_net_ в верхнеуровневом элементе _network_
- для каждого сервиса определяем соответствующие сети в директиве _networks_
##### Параметризация docker-compose.yml с помощью переменных окружений
- переменные вынесены в файл _.env_. В репозиторий добавлен пример такого файла
- для каждого сервиса указана директива _env_file_ , в которой указан путь к файлу с переменными
##### Определение имени проекта
- Чтобы определить префикс для контейнеров, запускаемых через `docker compose`, требуется добавить флаг **-p** или **--project-name**
Например:
```
# docker compose -p otus up -d
# docker compose --project-name otus up -d
```

#### 2. Дополнительные настройки проекта reddit в docker-compose.override.yml
##### Изменение кода приложения без пересборки образа
Чтобы не пересобирать образ с компонентами приложения для каждого компонента, директорию с кодом необходимо подключить к Volume:
- определяем тома для каждого компонента в верхнеуровневом элементе _volumes_
- подключаем соответствующие тома к директории _/data_ для каждого сервиса
##### Запуск puma для ruby-приложений в дебаг-режиме и с двумя воркерами
- переопределяем `CMD` команду из Dockerfile при помощи директивы _command_

Устройство GitLab CI
---
#### 1. Omnibus-установка GitLab CI
- устанавливаем Docker на сервер
- создаем директории для GitLab
```
# mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs
```
- настраиваем compose-файл для установки GitLab
```
web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://51.250.70.70'
  ports:
    - '80:80'
    - '443:443'
    - '2222:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'
```

#### 2. Автоматизация установки GitLab при помощи Ansible
- docker-monolith/infra/ansible/gitlab.yml

#### 3. Подключение репозитория GitLab к локальному репозиторию
- локально выполняем команды:
```
# git checkout -b gitlab-ci-1
# git remote add gitlab http://51.250.70.70/homework/example.git
# git push gitlab gitlab-ci-1
```
где 
- http://51.250.70.70 - пример адреса GitLab-сервера,
- /homework/example.git - пример GitLab-репозитория

#### 4. Определение CI/CD Pipeline
- создаем в корне GitLab-репозитория файл _.gitlab-ci.yml_

#### 5. GitLab-runner для запуска Pipeline
- добавляем раннер на сервер
```
docker run -d --name gitlab-runner --restart always -v /srv/gitlabrunner/
config:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock
gitlab/gitlab-runner:latest
```
- регистрируем раннер
```
docker exec -it gitlab-runner gitlab-runner register \
  --url http://51.250.70.70/ --non-interactive --locked=false \
  --name DockerRunner --executor docker --docker-image alpine:latest \
  --registration-token GR134894129WutKtGssRtCYxrniyb \
  --tag-list "linux,xenial,ubuntu,docker" --run-untagged \
  --docker-privileged
```

#### 6. Добавление приложения и тестов в проект
- добавляем reddit-приложение
```
# git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
# git add reddit/
# git commit -m "Add reddit app"
# git push gitlab gitlab-ci-1
```
- добавляем файл с тестами: reddit/simpletest.rb
- подключаем тесты в задаче test_unit_job в .gitlab-ci.yml
- добавляем библиотеку rack-test в reddit/Gemfile

### 7. Окружения
- в .gitlab-ci.yml определены окружения dev, beta, production
- в .gitlab-ci.yml настроены динамические окружения с помощью переменных $CI_COMMIT_REF_NAME и $CI_ENVIRONMENT_SLUG

### 8. Автоматизация развертывания GitLab Runner
- добавлена задача _Start GitLab Runner container_ в плейбук docker-monolith/infra/ansible/gitlab.yml

### 9. Запуск reddit на динамически создаваемых окружениях
- добавлена задача reddit_start в .gitlab-ci.yml, в которой:
a) определен docker-executor
b) добавлен скрипт для подключения внешнего реестра образов
c) добавлены скрипты для создания и выгрузки образа reddit
d) определены динамически создаваемые окружения
- в задачу branch review добавлен скрипт запуска контейнера с reddit

Введение в мониторинг. Системы мониторинга
---
#### 1. Prometheus
- подготовлено окружение для установки Prometheus с использованием Docker Machine
- выполнен запуск контейнера Prometheus
- выполнены инструкции по знакомству с основными элементами интерфейса
- сконфигурирован запуск Prometheus через Docker Compose
#### 2. Мониторинг состояния микросервисов
- выполнены инструкции по осуществлению мониторинга микросервисов с использованием healthcheck'ов
#### 3. Сбор метрик с использованием экспортера
- в docker-compose.yml добавлена директива для запуска контейнера с node-exporter, который собирает метрики с докер-хоста
- добавлен соответствующий job в конфигурационный файл Prometheus
- пересобран образ Prometheus
#### 4. Мониторинг MongoDB
- настроен запуск контейнера mongodb_exporter с метриками --collector.topmetrics
- в конфигурационный файл Prometheus добавлен job mongodb
#### 5. Мониторинг приложения при помощи blackbox-exporter
- добавлен конфигурационный файл blackbox.yml с указанием модулей http_2xx, http_post_2xx и http_2xx_example
- в конфигурационный файл Prometheus добавлен job _blackbox-exporter_, собирающий метрики с приложения reddit
- добавлен Dockerfile для сборки образа экспортера с конфигурационным файлом
- настроен запуск контейнера blackbox_exporter

Логирование и распределенная трассировка
---
#### 1. Логирование Docker-контейнеров
- настроен Compose-файл для системы логирования (_docker-compose-logging.yml_)
- собран образ fluentd с настроенным файлом конфигурации (_fluent.conf_)
#### 2. Сбор структурированных логов
- собраны новые образы reddit с добавлением функционала логирования (добавлен тег _logging_)
- обновлен основной Compose-файл с заменой образов на образы с тегом _logging_
- для компонента _post_ в Compose-файле добавлена директива logging для перенаправления логов во fluentd
#### 3. Визуализация логов
- изучен интерфейс Kibana, настроен индекс fluentd
- настроены фильтры fluentd для парсинга json-логов
- выполнена работа с логами (поиск по полям, по структурированным логам)
#### 4. Сбор неструктурированных логов
- для компонента _ui_ в Compose-файле добавлена директива logging для перенаправления логов во fluentd
- настроены регулярные выражения для парсинга неструктурированных логов
- настроены grok-шаблоны для парсинга неструктурированных логов
- в рамках дополнительного задания настроен дополнительный grok-шаблон
#### 5. Распределенный трейсинг
- в Compose-файл для системы логирования добавлен сервис zipkin с подключением к сетям
- в Compose-файл для компонентов reddit добавлена переменная ZIPKIN_ENABLED со значением _true_
- изучен интерфейс Zipkin, просмотрены трейсы компонента _ui_

Введение в Kubernetes
---
#### 1. Знакомство с основными примитивами Kubernetes
- подготовлены Deployment-манифесты для reddit-приложения
- развернут k8s-кластер на двух нодах при помощи kubeadm
- применены манифесты reddit-приложения в созданном кластере
#### 2. Подготовка инфраструктуры для k8s-кластера при помощи Terraform

#### 3. Подготовка плейбука и инвентори-файла Ansible для развертывания k8s-кластера
- для создания динамического инвентори-файла подготовлен скрипт _inventory.sh_

Kubernetes. Запуск кластера и приложения
---
#### 1. Запускаем reddit-приложение в кластере Kubernetes
- манифесты расположены в папке kubernetes/reddit
#### 2. Разворачиваем кластер Kubernetes при помощи модуля Terraform
- конфигурация кластера расположена в папке kubernetes/terraform-k8s-cluster
- конфигурация группы узлов расположена в папке kubernetes/terraform-k8s-node-group
#### 3. Готовим YAML-манифесты для включения Kubernetes Dashboard
- манифесты расположены в папке kubernetes/dashboard

Kubernetes. Networks, storages
---
#### 1. Сетевое взаимодействие
- установлен Ingress-контроллер
- настроен Ingress для компонента ui
- настроен прием только HTTPS-трафика при помощи Secret
- в рамках дополнительного задания TLS-Secret описан в виде YAML-манифеста
- к k8s-кластеру подключен плагин Calico для использования NetworkPolicy
- настроена сетевая политика (NetworkPolicy) для компонента mongo: разрешены входящие подключения от компонентов comment и post
#### 2. Хранилище
- в Yandex Cloud создан диск
- настроены PersistentVolume (PV) и PersistentVolumeClaim (PVC)
- PVC подключен к развертыванию mongo для постоянного хранения данных БД

CI/CD в Kubernetes
---
#### 1. Работа с Helm
- установлен Helm
- настроены чарты для компонентов reddit-приложения
#### 2. Развертывание Gitlab в Kubernetes
- добавлен helm-репозиторий Gitlab
- установлен gitlab-omnibus (внесены изменения в шаблоны для успешного запуска)
#### 3. Запуск CI/CD в Kubernetes
- добавлены пайплайны (.gitlab-ci.yml) для компонентов reddit-приложения
