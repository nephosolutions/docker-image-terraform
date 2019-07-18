#   Copyright 2019 NephoSolutions SPRL, Sebastian Trebitz
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

ARG ALPINE_VERSION
ARG ANSIBLE_VERSION
ARG RUBY_VERSION

FROM alpine:${ALPINE_VERSION} as downloader

RUN apk add --no-cache --update \
      gnupg

WORKDIR /tmp

ARG GCLOUD_SDK_VERSION
ENV GCLOUD_SDK_VERSION ${GCLOUD_SDK_VERSION}

ADD https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz
RUN tar -xzf google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz

COPY hashicorp-releases-public-key.asc .
RUN gpg --import hashicorp-releases-public-key.asc

ARG TERRAFORM_VERSION
ENV TERRAFORM_VERSION ${TERRAFORM_VERSION}

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS terraform_${TERRAFORM_VERSION}_SHA256SUMS

RUN gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS

RUN grep linux_amd64 terraform_${TERRAFORM_VERSION}_SHA256SUMS >terraform_${TERRAFORM_VERSION}_SHA256SUMS_linux_amd64
RUN sha256sum -cs terraform_${TERRAFORM_VERSION}_SHA256SUMS_linux_amd64

WORKDIR /usr/local/bin

RUN unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip


FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION}
LABEL maintainer="sebastian@nephosolutions.com"

RUN apk add --no-cache --update \
  bash \
  build-base \
  ca-certificates \
  git \
  groff \
  libc6-compat \
  libsodium \
  make \
  openssh-client \
  openssl \
  python

RUN ln -s /lib /lib64

ARG GIT_CRYPT_VERSION
ENV GIT_CRYPT_VERSION ${GIT_CRYPT_VERSION}

ADD https://raw.githubusercontent.com/sgerrand/alpine-pkg-git-crypt/master/sgerrand.rsa.pub /etc/apk/keys/sgerrand.rsa.pub
ADD https://github.com/sgerrand/alpine-pkg-git-crypt/releases/download/${GIT_CRYPT_VERSION}/git-crypt-${GIT_CRYPT_VERSION}.apk /var/cache/apk/
RUN apk add /var/cache/apk/git-crypt-${GIT_CRYPT_VERSION}.apk

COPY --from=downloader /tmp/google-cloud-sdk /opt/google/cloud-sdk
COPY --from=downloader /usr/local/bin/terraform /usr/local/bin/terraform

RUN addgroup alpine && \
    adduser -G alpine -D alpine

USER alpine
ENV USER alpine

ENV PATH $PATH:/opt/google/cloud-sdk/bin
