#!/bin/bash

docker run -t --rm mysql mysql -h127.0.0.1 -uroot "-p$(cat ~/.my.password) --protocol=tcp"
