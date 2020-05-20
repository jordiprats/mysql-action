#!/bin/sh

DOCKERUN="docker run"

DOCKERUN="$DOCKERUN -e MYSQL_ROOT_PASSWORD=$INPUT_MYSQL_ROOT_PASSWORD"

echo -e "[client]\npassword=${INPUT_MYSQL_ROOT_PASSWORD-sha256}" > ./docker-mycnf
chmod 0600 ./docker-mycnf

DOCKERUN="$DOCKERUN -d -p 3307:3307 mysql:$INPUT_MYSQL_VERSION --port=3307"

echo -n "deploying mysql container... "
CONTAINER_ID=$(sh -c "$DOCKERUN") 2>/dev/null
echo "OK - mysql container deployed."
# let mysql start
echo "sleeping 20s..."
sleep 20s

docker exec -i "$CONTAINER_ID" tee /root/.my.cnf < ./docker-mycnf > /dev/null
docker exec "$CONTAINER_ID" cat /root/.my.cnf
docker exec "$CONTAINER_ID" chmod 600 /root/.my.cnf

docker ps --all

RETURN=1

if [ ! -z "${INPUT_TEST_DIR}" ];
then
  FIND_DIR="${INPUT_TEST_DIR}"
else
  FIND_DIR="."
fi

for i in $(/usr/bin/find "${FIND_DIR}" -iname '*.sh')
do
  DIRNAME=$(dirname "$i")
  BASENAME=$(basename "$i")
  COMPANION_FILES=$(echo "$BASENAME" | sed 's/\.sh$//g')
  tar czhf "${COMPANION_FILES}.tgz" "$DIRNAME/$COMPANION_FILES"
  tar tvf "${COMPANION_FILES}.tgz"
  docker exec "$CONTAINER_ID" mkdir /testing/
  docker exec -i "$CONTAINER_ID" tee "/testing/${BASENAME}" < "$i" > /dev/null
  docker exec -i "$CONTAINER_ID" tee "/testing/${COMPANION_FILES}.tgz" < "${COMPANION_FILES}.tgz" > /dev/null
  docker exec "$CONTAINER_ID" tar xzvf "/testing/${COMPANION_FILES}.tgz"
  docker exec "$CONTAINER_ID" find /testing -type f

  if [ "${INPUT_DEBUG-0}" = 1 ];
  then
    docker exec "$CONTAINER_ID" bash -x "/testing/${BASENAME}"
  else
    docker exec "$CONTAINER_ID" bash "/testing/${BASENAME}"
  fi

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
