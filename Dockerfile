FROM node:16-alpine AS node

FROM grafana/grafana-oss

USER root

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

ADD ./custom-run.sh /custom-run.sh

RUN apk update \
    && apk upgrade \
    && apk add --no-cache git \
    && git clone https://github.com/yaroslav-hnatiuk/mongodb-grafana $GF_PATHS_PLUGINS/mongodb-grafana \
    && sed -i 's/grafana-mongodb-datasource/jamesosgood-grafana-mongodb-datasource/g' $GF_PATHS_PLUGINS/mongodb-grafana/dist/plugin.json \
    && rm -rf $GF_PATHS_PLUGINS/mongodb-grafana/.git \
    && npm install --silent --prefix $GF_PATHS_PLUGINS/mongodb-grafana \
    && npm cache clean --force --prefix $GF_PATHS_PLUGINS/mongodb-grafana \
    && apk del --no-cache git \
    && chmod +x /custom-run.sh \
    && sed -i 's/;allow_loading_unsigned_plugins =.*/allow_loading_unsigned_plugins = jamesosgood-grafana-mongodb-datasource/g' $GF_PATHS_CONFIG

ENTRYPOINT ["/custom-run.sh"]
