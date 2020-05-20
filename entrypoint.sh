#!/bin/sh

DOCKERUN="docker run"

echo "[client]" > ~/.my.cnf
echo "user=root" >> ~/.my.cnf
echo "host=127.0.0.1" >> ~/.my.cnf
echo "port=3307" >> ~/.my.cnf
echo "protocol=tcp" >> ~/.my.cnf

if [ ! -z "$INPUT_MYSQL_ROOT_PASSWORD" ];
then
  echo "setting root password"
  DOCKERUN="$DOCKERUN -e MYSQL_ROOT_PASSWORD=$INPUT_MYSQL_ROOT_PASSWORD"
  echo "password=$INPUT_MYSQL_ROOT_PASSWORD" >> ~/.my.cnf
else
  echo "default mysql password"
  DOCKERUN="$DOCKERUN -e MYSQL_ROOT_PASSWORD=sha256"
  echo "password=sha256" >> ~/.my.cnf
fi

chmod 0600 ~/.my.cnf

cat ~/.my.cnf

DOCKERUN="$DOCKERUN -d -p 3307:3307 --mount type=bind,source="$(pwd)",target=/testing mysql:$INPUT_MYSQL_VERSION --port=3307"

CONTAINER_ID=$(sh -c "$DOCKERUN")

# let mysql start
sleep 30s

echo $DOCKERUN

docker ps --all

echo == ls $(pwd) ==
ls $(pwd)

echo == docker ls ==
docker exec -t "$CONTAINER_ID" ls

echo == docker testing ==
docker exec -t "$CONTAINER_ID" ls /testing

docker exec -t "$CONTAINER_ID" bash -c "echo 'show processlist' | mysql"
docker exec -t "$CONTAINER_ID" bash -c "echo 'show databases' | mysql"


RETURN=1

if [ ! -z "${INPUT_TEST_DIR}" ];
then
  FIND_DIR="${INPUT_TEST_DIR}"
else
  FIND_DIR="."
fi

for i in $(/usr/bin/find "${FIND_DIR}" -iname '*.sh')
do
  docker exec -t "$CONTAINER_ID" bash "/testing/$i"
  if [ "$?" -eq 0 ] && [ "$RETURN" -ne 2 ];
  then
    echo "OK: $i"
    RETURN=0
  elif [ "$?" -eq 0 ];
  then
    echo "OK: $i"
  else
    echo "FAILED: $i"
    RETURN=2
  fi
done

exit $RETURN
