FROM ubuntu:14.10
MAINTAINER Wichert Akkerman <wichert@wiggy.net>
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install --no-install-recommends -y curl python-virtualenv python-lxml python-pillow python-psycopg2 git

WORKDIR /tmp
RUN curl -L https://github.com/nijel/weblate/archive/weblate-2.1.tar.gz | tar xfz -

WORKDIR /app
RUN python -m virtualenv --system-site-packages .
ADD requirements.txt /tmp/requirements.txt
RUN bin/pip install -r /tmp/requirements.txt
RUN bin/pip install /tmp/weblate-weblate-2.1

WORKDIR /tmp
RUN useradd --shell /bin/sh --user-group weblate

RUN install -d -o weblate -g weblate -m 755 /app/data
RUN install -d -o root -g root -m 755 /app/etc
ADD settings.py /app/etc/settings.py
RUN ln -s /app/etc/settings.py /app/lib/python2.7/site-packages/weblate/settings.py
ENV DJANGO_SETTINGS_MODULE weblate.settings

VOLUME ["/app/etc", "/app/data"]
USER weblate

EXPOSE 8000
ENTRYPOINT ["/app/bin/django-admin"]
CMD ["runserver"]
