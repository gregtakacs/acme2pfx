# syntax=docker/dockerfile:1
FROM alpine
ENV CERT_KEY_FILE=/source/cert_key
ENV TMP_DIR=/var/cache
VOLUME [ "/source:ro" ]
VOLUME [ "/dest" ]
RUN ["apk", "add", "--no-cache", "jq", "openssl", "tini"]
ENTRYPOINT [ "/sbin/tini", "--" ]
COPY acme2pfx.sh /etc/periodic/daily/default
COPY startup.sh /startup.sh
RUN ["chmod", "+x", "/etc/periodic/daily/default"]
RUN ["chmod", "+x", "/startup.sh"]
CMD ["/startup.sh"]