FROM ubuntu:18.04

LABEL "maintainer"="Jordi Prats <https://github.com/jordiprats/>"

COPY entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["./"]
