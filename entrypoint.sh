#!/bin/sh

DOCKERUN="docker run"

if [ ! -z "$INPUT_MYSQL_ROOT_PASSWORD" ];
then
  echo "setting root password"
  DOCKERUN="$DOCKERUN -e MYSQL_ROOT_PASSWORD=$INPUT_MYSQL_ROOT_PASSWORD"
  echo "$INPUT_MYSQL_ROOT_PASSWORD" >> ~/.my.password
else
  echo "default mysql password"
  DOCKERUN="$DOCKERUN -e MYSQL_ROOT_PASSWORD=sha256"
  echo "sha256" >> ~/.my.password
fi

chmod 0600 ~/.my.cnf

DOCKERUN="$DOCKERUN -d -p $INPUT_HOST_PORT:$INPUT_CONTAINER_PORT mysql:$INPUT_MYSQL_VERSION --port=$INPUT_CONTAINER_PORT"
DOCKERUN="$DOCKERUN --character-set-server=$INPUT_CHARACTER_SET_SERVER --collation-server=$INPUT_COLLATION_SERVER"

sh -c "$DOCKERUN"

docker ps

cat ~/.my.cnf

find . -type f

echo "show processlist" | mysql

if [ ! -z "${INPUT_TEST_DIR}" ];
then
	/usr/bin/find "${INPUT_TEST_DIR}" -iname '*.sh' -exec {} \;
else
  /usr/bin/find . -iname '*.sh' -exec {} \;
fi
