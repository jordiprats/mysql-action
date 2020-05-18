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

chmod 0600 ~/.my.password

DOCKERUN="$DOCKERUN -d -p 3306:3306 mysql:$INPUT_MYSQL_VERSION --port=3306"

echo $DOCKERUN
sh -c "$DOCKERUN"

docker ps
docker ps --all

echo "show processlist" | bash -x /bin/mysql
echo "show databases" | bash -x /bin/mysql

RETURN=0

if [ ! -z "${INPUT_TEST_DIR}" ];
then
  FIND_DIR="${INPUT_TEST_DIR}"
else
  FIND_DIR="."
fi

for i in $(/usr/bin/find "${FIND_DIR}" -iname '*.sh')
do
  bash $i
  if [ "$?" -ne 0 ];
  then
    RETURN = 1
  fi
done

exit $RETURN
