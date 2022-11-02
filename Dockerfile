FROM ubuntu:22.10

RUN apt-get update && \
    apt-get install -y gcc git libffi-dev libgdbm-dev libsqlite3-dev libssl-dev zlib1g-dev make pkg-config && \
    apt-get clean

RUN git config --global user.email "urllib3@dev.to"
RUN git config --global user.name "urllib3"

WORKDIR /src

RUN git clone https://github.com/tiran/cpython.git

WORKDIR /src/cpython

RUN git remote add python https://github.com/python/cpython.git
RUN git pull && git checkout py312_ssl_removal
RUN git fetch python && git rebase python/main

RUN ./configure \
    --prefix=/opt/python/3.12.0a1 \
    --enable-shared \
    --enable-optimizations \
    LDFLAGS=-Wl,-rpath=/opt/python/3.12.0a1/lib,--disable-new-dtags

RUN make && make install

RUN ln -s /opt/python/3.12.0a1/bin/python3.12 /usr/bin/python
RUN ln -s /opt/python/3.12.0a1/bin/python3.12 /usr/bin/python3.12
RUN ln -s /opt/python/3.12.0a1/bin/pip3.12 /usr/bin/pip

RUN python --version

WORKDIR /app

RUN git clone https://github.com/Ousret/urllib3.git

WORKDIR /app/urllib3

RUN git pull && git checkout provisional-py12-support

COPY noxfile.py ./
COPY test_pyopenssl.py ./test/contrib/test_pyopenssl.py

RUN pip install -U pip setuptools
RUN pip install nox

RUN ln -s /opt/python/3.12.0a1/bin/nox /usr/bin/nox

RUN apt-get -y install g++

COPY entrypoint.sh /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint

CMD ["entrypoint"]
