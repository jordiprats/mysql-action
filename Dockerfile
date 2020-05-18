FROM docker:stable

LABEL "maintainer"="Jordi Prats <https://github.com/jordiprats/>"

RUN apk add --no-cache bash

COPY entrypoint.sh /entrypoint.sh
COPY mysql-docker.sh /bin/mysql

RUN ["chmod", "+x", "/entrypoint.sh"]
RUN ["chmod", "+x", "/bin/mysql"]


ENTRYPOINT ["/entrypoint.sh"]
CMD ["./"]
