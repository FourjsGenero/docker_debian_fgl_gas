 MIT License
 
Copyright (c) 2019 Four Js Genero
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

How to build Genero GAS docker image
====================================

First copy all required installer, archives and fglprofile
files to the docker directory.

Fill an fglprofile file with appropriate licensing information:

```
flm.license.number="XXX#XXXXXXXX"
flm.license.key="XXXXXXXXXXXX"
flm.server="hostname"
flm.service="6399"
```

Export following environment variables:

```bash
# FGLGWS package to install
export FGLGWS_PACKAGE=fjs-fglgws-3.10.01-build1486651223-l64xl212.run

# GAS package to install
export GAS_PACKAGE=fjs-gas-3.10.00-build154169-l64xl212.run
```

The following environment variables are used to configure the ROOT_URL_PREFIX
in the GAS configuration:
* HOST_HOSTNAME, default value 'localhost'
* HOST_APACHE_PORT, default value: 8080

Then execute the `docker_build_genero_image.sh`

By default a genero gas docker image has been generated.

Now start the container by executing the `docker_run_genero_image.sh` script.

Then open the following url:

    http://localhost:8080/gas/ua/r/gwc-demo

The authentication parameters are:
  - user: gasadmin
  - password: gasadmin

