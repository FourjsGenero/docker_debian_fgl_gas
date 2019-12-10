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


FROM debian:latest

ARG USER=genero
ARG GROUP=fourjs
ARG UID=500
ARG GID=2000

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends --no-install-suggests \
      apache2 \
      bzip2 \
      binutils \
      file \
      sqlite3 \
      libncurses5 \
      libncursesw5

# Debugging helpers - Add sudo, ssh-client, vim
# Uncomment to enabled
#RUN apt-get install -y --no-install-recommends --no-install-suggests \
#      ssh-client \
#      sudo \
#      vim \
# && echo "%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sudo-for-all \
# && chmod 0440 /etc/sudoers.d/sudo-for-all \
# && adduser "${USER}" sudo

RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=noninteractive

ENV HOME="/home/${USER}"
RUN set -eufx \
 && groupadd -g "${GID}" "${GROUP}" \
 && useradd -d "${HOME}" -u "${UID}" -g "${GID}" -M -N -r -s /bin/bash "${USER}" \
 && mkdir -p "${HOME}" \
 && chown "${USER}:${GROUP}" "${HOME}"

WORKDIR ${HOME}

##### FGLGWS Installation #####################################################
# Dependencies: .run package to install
USER root
ARG FGLGWS_PACKAGE

# 1- Copy the fglgws package to /tmp/fglgws-install.run
COPY ${FGLGWS_PACKAGE} /tmp/fglgws-install.run

# 2- Create /opt/fourjs - Root installation directory for all FourJs products
#    And change owner/group
RUN mkdir -p /opt/fourjs \
 && chown ${USER}:${GROUP} /opt/fourjs /tmp/fglgws-install.run


# 3- Install fglgws package as ${USER}
USER ${USER}
ENV FGLDIR /opt/fourjs/fglgws
ENV PATH ${FGLDIR}/bin:${PATH}
RUN /tmp/fglgws-install.run --accept --install --quiet --target ${FGLDIR} \
 && rm -f /tmp/fglgws-install.run


##### Patch FGLGWS license software ###########################################
# Dependencies: .tgz archive to install
#
# Uncomment following lines
# and add --build-arg FGLWRT_PACKAGE=Path_to_fglWrt_archive.tgz

# USER root
# ARG FGLWRT_PACKAGE
#
# # 1- Copy the fglWrt package to /tmp/fglWrt-package.tgz
# COPY ${FGLWRT_PACKAGE} /tmp/fglWrt-package.tgz
# RUN chown ${USER}:${GROUP} /tmp/fglWrt-package.tgz
#
# #2- Install license software patch
# USER ${USER}
# RUN cd ${FGLDIR} \
#  && tar xvfz /tmp/fglWrt-package.tgz \
#  && cd ${FGLDIR}/msg/en_US \
#  && fglmkmsg flm.msg flm.iem \
#  && rm -f /tmp/fglWrt-package.tgz

##### Add license configuration in fglprofile if any ##########################
# Comment following lines to disable fglprofile licensing.
USER root
ADD fglprofile /tmp/fglprofile
RUN chown ${USER}:${GROUP} /tmp/fglprofile

USER ${USER}
RUN cat /tmp/fglprofile >> /opt/fourjs/fglgws/etc/fglprofile \
 && rm -f /tmp/fglprofile

##### Install GAS package #####################################################
# Dependencies: .run archive to install
USER root
ARG GAS_PACKAGE
ARG ROOT_URL_PREFIX

# 1- Copy the fglgws package to /tmp/fglgws-install.run
COPY ${GAS_PACKAGE} /tmp/gas-install.run
RUN chown ${USER}:${GROUP} /tmp/gas-install.run

# 2- Install GAS package as ${USER}
USER ${USER}
ENV FGLASDIR /opt/fourjs/gas
ENV PATH ${FGLASDIR}/bin:${FGLDIR}/bin:${PATH}
RUN /tmp/gas-install.run --accept --install --quiet --target ${FGLASDIR} --dvm ${FGLDIR} \
 && rm -f /tmp/gas-install.run

# 3- Update ROOT_URL_PREFIX
RUN sed -i -e "s#\(.*<INTERFACE_TO_CONNECTOR>.*\)#\1<ROOT_URL_PREFIX>${ROOT_URL_PREFIX}</ROOT_URL_PREFIX>#" -e "s#NOBODY#ALL#g" ${FGLASDIR}/etc/as.xcf

##### Configure apache ########################################################
EXPOSE 80

USER root
ARG APACHE_AUTH_FILE

ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
ADD ${APACHE_AUTH_FILE} /opt/fourjs/gas/apache-auth


# Enable required modules
RUN a2enmod dir alias rewrite proxy proxy_fcgi setenvif authn_core authz_core \
 && a2ensite 000-default \
 && chown www-data:www-data /opt/fourjs/gas/apache-auth


##### Entry point and Command #################################################
USER root

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
