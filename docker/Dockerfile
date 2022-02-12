#
# Image: ext-alpine
#

# IMPORT alpine-ext/_main

### Trying Combined Dockerfile ###
FROM alpine:3.12 AS alpine-files

ADD files /files
RUN chmod a+x /files/alpine/bin/*

### Base Alpine
FROM alpine:3.12 AS base--image--alpine

### Add initial files
COPY --from=alpine-files /files/alpine /

### Hugo Extended edition
FROM debian:11.0-slim AS fetcher-extended
ARG VERSION_ARG=0.92.1
ENV HUGO_VERSION=${VERSION_ARG}
ARG TARGETPLATFORM="linux/amd64"
RUN apt update && apt install -y wget
#COPY --from=base--files--script /hugo-extended.sh hugo.sh
ADD _script/hugo-extended.sh hugo.sh
RUN sh hugo.sh

FROM scratch AS base--hugo--extended
COPY --from=fetcher-extended /files /

### Certs
FROM base--image--alpine AS cert-source
RUN apk --no-cache add ca-certificates

FROM scratch as base--certs
COPY --from=cert-source /etc/ssl/certs /etc/ssl/certs

### Nodejs musl
FROM base--image--alpine AS fetcher-musl
ARG TARGETPLATFORM="linux/amd64"
ADD _script/nodejs-musl.sh nodejs.sh
RUN sh nodejs.sh

FROM scratch AS base--nodejs--musl
COPY --from=fetcher-musl /files /

### golang
FROM base--image--alpine AS fetcher
ARG TARGETPLATFORM="linux/amd64"
ADD _script/golang.sh golang.sh
#COPY --from=base--files--scripts golang.sh golang.sh
RUN sh golang.sh

FROM scratch AS base--golang
COPY --from=fetcher /files /

### Ext Alpine
FROM scratch as image

### Copy from all bases
COPY --from=base--image--alpine / /
COPY --from=base--hugo--extended / /
COPY --from=base--certs / /
COPY --from=base--nodejs--musl / /
COPY --from=base--golang / /

# FROM base--image--alpine AS main ### Changed ---
FROM base--image--alpine AS ext-alpine

# IMPORT ../_imports/version_arg
ARG VERSION_ARG=0.92.1
ENV HUGO_VERSION=${VERSION_ARG}

ENV HUGO_BIND="0.0.0.0" \
    HUGO_DESTINATION="public" \
    HUGO_ENV="production" \
    HUGO_EDITION="extended" \
    HUGO_CACHEDIR="/tmp" \
    NODE_PATH=".:/usr/local/node/lib/node_modules" \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/node/bin" \
    GOROOT="/usr/local/lib/go" \
    HOME="/tmp"

RUN apk add --no-cache libc6-compat libstdc++ busybox-suid bash bash-completion git tzdata make \
    # Python 3
    python3 py-pip py-setuptools

COPY --from=image / /

RUN true \
 && apk update \
 #
 # Install npm packages
 && npm install -g autoprefixer@10.2.4 postcss@8.2.6 postcss-cli@8.3.1 yarn@1.22.10 @babel/cli @babel/core  \
 #
 # Install rst2html
 && pip install rst2html \
 #
 # Cleaning
 && apk del py-pip py-setuptools \ 
 && find /tmp -mindepth 1 -maxdepth 1 | xargs rm -rf \
 #
 # Prepare folders
 && mkdir -p /src /target \
 && chmod a+w /src /target

EXPOSE 1313

WORKDIR /src

ENTRYPOINT ["hugo"]

### RM - hugo path: /usr/lib/hugo/hugo

### -------

### IMPORT ../_imports/ci.df --- not needed?
# FROM main AS ci

# ENV HUGO_ENV="production"

# ENTRYPOINT [ "" ]
# CMD [ "hugo" ]


# ### IMPORT ../_imports/onbuild.df --- not needed?
# FROM main AS onbuild

# ONBUILD ARG HUGO_CMD
# ONBUILD ARG HUGO_DESTINATION_ARG
# ONBUILD ARG HUGO_ENV_ARG
# ONBUILD ARG HUGO_DIR
# ONBUILD ARG ONBUILD_SCRIPT

# ONBUILD ENV HUGO_DESTINATION="${HUGO_DESTINATION_ARG:-/target}" \
#             HUGO_ENV="${HUGO_ENV_ARG:-DEV}" \
#             ONBUILD_SCRIPT_VALUE="${ONBUILD_SCRIPT:-.hugo-onbuild.sh}"

# ONBUILD COPY . /src
# ONBUILD WORKDIR ${HUGO_DIR:-/src}
# ONBUILD RUN if [ -e "$ONBUILD_SCRIPT_VALUE" ]; then exec sh $ONBUILD_SCRIPT_VALUE; else exec hugo $HUGO_CMD; fi


# FROM ext-alpine # --- RM not needed


### IMPORT ext-asciidoctor AS ext-asciidoctor
FROM ext-alpine AS ext-asciidoctor

RUN apk --no-cache add asciidoctor \
 && gem install coderay asciidoctor-rouge --no-document \
 && find /tmp -mindepth 1 -maxdepth 1 | xargs rm -rf


# IMPORT ../_imports/ci.df

# IMPORT ../_imports/onbuild.df


# FROM ext-asciidoctor # --- RM not needed

### COPY --from=base--pandoc / /
FROM base--image--alpine AS fetcher-pandoc
ARG TARGETPLATFORM="linux/amd64"
ADD _script/pandoc.sh pandoc.sh
RUN sh pandoc.sh
ADD pandoc /files

FROM ext-asciidoctor AS ext-pandoc
COPY --from=fetcher-pandoc /files /

### IMPORT ext-pandoc AS ext-pandoc

FROM ext-pandoc AS main

### IMPORT ../_imports/ci.df
ENV HUGO_ENV="production"

ENTRYPOINT [ "" ]
CMD [ "hugo" ]

### IMPORT ../_imports/onbuild.df
ARG HUGO_CMD
ARG HUGO_DESTINATION_ARG=/target
ARG HUGO_ENV_ARG=production
ARG HUGO_DIR=/src
ARG ONBUILD_SCRIPT

ENV HUGO_DESTINATION="${HUGO_DESTINATION_ARG:-/target}" \
    HUGO_ENV="${HUGO_ENV_ARG:-DEV}"
# ONBUILD_SCRIPT_VALUE="${ONBUILD_SCRIPT:-.hugo-onbuild.sh}"

# COPY . /src

WORKDIR ${HUGO_DIR:-/src}

# RUN if [ -e "$ONBUILD_SCRIPT_VALUE" ]; then exec sh $ONBUILD_SCRIPT_VALUE; else exec hugo $HUGO_CMD; fi

FROM main


# RUN rm -rf /var/cache/apk/* && \
#     rm -rf /tmp/*