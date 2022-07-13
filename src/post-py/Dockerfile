FROM python:3.9.13-alpine

WORKDIR /app
ADD . /app

RUN apk --no-cache --update add build-base gcc musl-dev && \
    pip install -r /app/requirements.txt && \
    apk del build-base

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

ENTRYPOINT ["python3", "post_app.py"]
