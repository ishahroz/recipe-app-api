# Using Python 3.8.16 Base Image
FROM python:3.8.16-slim-buster

# Adding maintainers label
LABEL maintainers = "ishahrozahmad90"

# This allows Python to send outputs direct to console without being buffered first
ENV PYTHONUNBUFFERED 1

# Copying project files from actual project directory to image directory
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false

# Running Python commands to install / configure / clean packages
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Setting PATH env variable \
ENV PATH="/py/bin:$PATH"

# Setting current user (root user) as django-user we created earlier
USER django-user