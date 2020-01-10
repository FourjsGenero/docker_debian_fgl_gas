# MIT License
#
# Copyright (c) 2019 Four Js Genero
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


#!/usr/bin/env bash

fail()
{
  echo "$@"
  exit 1
}

# Docker image name
GENERO_DOCKER_IMAGE=${GENERO_DOCKER_IMAGE:-genero}

# Defaults
HOST_HOSTNAME=${HOST_HOSTNAME:-localhost}
HOST_APACHE_PORT=${HOST_APACHE_PORT:-8080}

##### Apache file where passwords will be stored
APACHE_AUTH_FILE=${APACHE_AUTH_FILE:-apache-auth}

##### gasadmin user password for apache
GASADMIN_PASSWD=${GASADMIN_PASSWD:-gasadmin}

##### Provide ROOT_URL_PREFIX base on HOST_HOSTNAME and HOST_APACHE_PORT
ROOT_URL_PREFIX=http://${HOST_HOSTNAME}:${HOST_APACHE_PORT}/gas

##### FGLGWS package
FGLGWS_PACKAGE=${FGLGWS_PACKAGE:-$(ls -tr fjs-fglgws-*l64xl212.run | tail -n 1)}

##### GAS package
GAS_PACKAGE=${GAS_PACKAGE:-$(ls -tr fjs-gas-*l64xl212.run | tail -n 1)}

##### Ensure packages to install are provided.
[ -z "${FGLGWS_PACKAGE}" ] && fail "No fglgws package provided. FGLGWS_PACKAGE environment variable is missing."
[ -z "${GAS_PACKAGE}" ] && fail "No gas package provided. GAS_PACKAGE environment variable is missing."

cp ${FGLGWS_PACKAGE} fglgws-install.run ||  fail "Failed to copy ${FGLGWS_PACKAGE} to ./fglgws-install.run"
cp ${GAS_PACKAGE} gas-install.run ||  fail "Failed to copy ${GAS_PACKAGE} to ./gas-install.run"

##### Generate the password file
htpasswd -cb apache-auth gasadmin ${GASADMIN_PASSWD}

##### Build the Genero GAS image
docker build --pull --force-rm --build-arg FGLGWS_PACKAGE=fglgws-install.run \
     --build-arg GAS_PACKAGE=gas-install.run          \
     --build-arg ROOT_URL_PREFIX=${ROOT_URL_PREFIX}   \
     --build-arg APACHE_AUTH_FILE=${APACHE_AUTH_FILE} \
     -t ${GENERO_DOCKER_IMAGE} .

rm -f fglgws-install.run gas-install.run
