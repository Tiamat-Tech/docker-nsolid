# This should be built after nsolid-argon.dockerfile to ensure this image inherits
# from the right base layers. We want the proxy that we are shipping to run on
# the version of N|Solid that was shipped with it
FROM nodesource/nsolid:argon
MAINTAINER NodeSource <https://nodesource.com/>

# Add and unpack the proxy tarball
COPY ./nsolid-bundle-*/nsolid-storage*.tar.gz .

# Install N|Solid Storage
RUN groupadd -r nsolid \
 && useradd -m -r -g nsolid nsolid \
 && mkdir /usr/src/app \
 && tar -xzC /usr/src/app --strip-components 1 -f nsolid-storage*.tar.gz \
 && chown -R nsolid:root /usr/src/app \
 && chmod -R 0770 /usr/src/app \
 && rm nsolid-storage*.tar.gz

# Artifacts & Settings Storage
RUN mkdir -p /var/lib/nsolid/storage \
 && chown -R nsolid:root /var/lib/nsolid/storage \
 && chmod -R 0770 /var/lib/nsolid/storage 

USER nsolid

WORKDIR /usr/src/app

ENV NODE_ENV production
ENV NSOLID_STORAGE_DATA_DIR /var/lib/nsolid/storage/data
ENV NSOLID_STORAGE_LOGS_INFLUX /var/lib/nsolid/storage/influxdb.log

ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "nsolid", "nsolid-storage.js"]