# FROM python:slim-bullseye

# RUN apt update 
# # RUN apt install pipx
# RUN mkdir -p /app

# WORKDIR /app

# RUN apt install -y curl 
# RUN curl https://downloads.mitmproxy.org/10.3.0/mitmproxy-10.3.0-linux-x86_64.tar.gz -o mitproxy
# CMD ["bash"]

# FROM python:3.11-bullseye as wheelbuilder
FROM python:3.9.19-slim-bullseye as wheelbuilder

ARG MITMPROXY_WHEEL
COPY $MITMPROXY_WHEEL /wheels/
RUN pip install wheel && pip wheel --wheel-dir /wheels /wheels/${MITMPROXY_WHEEL}

FROM python:3.11-slim-bullseye

RUN useradd -mU mitmproxy
RUN apt-get update \
    && apt-get install -y --no-install-recommends gosu nano \
    && rm -rf /var/lib/apt/lists/*

COPY --from=wheelbuilder /wheels /wheels
RUN pip install --no-index --find-links=/wheels mitmproxy
RUN rm -rf /wheels

VOLUME /home/mitmproxy/.mitmproxy

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 8080 8081

CMD ["mitmproxy"]