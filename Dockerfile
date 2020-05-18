FROM docker:stable

LABEL "maintainer"="Jordi Prats <https://github.com/jordiprats/>"

RUN apk add --no-cache bash
RUN apk add --no-cache mysql-client

COPY entrypoint.sh /entrypoint.sh

RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./"]
