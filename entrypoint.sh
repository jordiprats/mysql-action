#!/bin/sh

DOCKERUN="docker run"

echo "[client]" > ~/docker-mycnf

if [ ! -z "$INPUT_MYSQL_ROOT_PASSWORD" ];
then
  echo "setting root password"
  DOCKERUN="$DOCKERUN -e MYSQL_ROOT_PASSWORD=$INPUT_MYSQL_ROOT_PASSWORD"
  echo "password=$INPUT_MYSQL_ROOT_PASSWORD" >> ~/docker-mycnff
else
  echo "default mysql password"
  DOCKERUN="$DOCKERUN -e MYSQL_ROOT_PASSWORD=sha256"
  echo "password=sha256" >> ~/docker-mycnf
fi

chmod 0600 ~/docker-mycnf

cat ~/docker-mycnf

DOCKERUN="$DOCKERUN -d -p 3307:3307 mysql:$INPUT_MYSQL_VERSION --port=3307"

CONTAINER_ID=$(sh -c "$DOCKERUN")

# let mysql start
echo "sleeping 20s..."
sleep 20s

echo $DOCKERUN

echo cat
docker exec "$CONTAINER_ID" bash -c "cat" < ~/docker-mycnf
echo cat to file
docker exec "$CONTAINER_ID" bash -c "cat > /root/.my.cnf" < ~/docker-mycnf
docker exec "$CONTAINER_ID" "chmod 600 ~/.my.cnf"

echo == docker my.cnf ==
docker exec "$CONTAINER_ID" "cat ~/.my.cnf"

docker ps --all

echo == ls $(pwd) ==
ls $(pwd)

echo == docker ls ==
docker exec -t "$CONTAINER_ID" ls

echo == docker testing ==
docker exec -t "$CONTAINER_ID" mkdir -p /testing
docker exec -t "$CONTAINER_ID" ls /testing

docker exec "$CONTAINER_ID" bash -c "echo 'show processlist' | mysql"
docker exec "$CONTAINER_ID" bash -c "echo 'show databases' | mysql"


RETURN=1

if [ ! -z "${INPUT_TEST_DIR}" ];
then
  FIND_DIR="${INPUT_TEST_DIR}"
else
  FIND_DIR="."
fi

for i in $(/usr/bin/find "${FIND_DIR}" -iname '*.sh')
do
  BASENAME=$(basename $i)
  cat "$i"
  cat "$i" | docker exec "$CONTAINER_ID" bash -c "cat > /testing/${BASENAME}"
  docker exec "$CONTAINER_ID" cat "/testing/${BASENAME}"
  docker exec "$CONTAINER_ID" bash "/testing/${BASENAME}"

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
