#   Copyright 2018 NephoSolutions SPRL, Sebastian Trebitz
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

ARG ALPINE_VERSION=3.7

FROM alpine:${ALPINE_VERSION} as downloader
ENV TERRAFORM_VERSION 0.11.7

COPY releases_public_key .

RUN apk add --no-cache --update curl gnupg

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS terraform_${TERRAFORM_VERSION}_SHA256SUMS

RUN gpg --import releases_public_key
RUN gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS

RUN grep linux_amd64 terraform_${TERRAFORM_VERSION}_SHA256SUMS >terraform_${TERRAFORM_VERSION}_SHA256SUMS_linux_amd64
RUN sha256sum -cs terraform_${TERRAFORM_VERSION}_SHA256SUMS_linux_amd64

RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin


FROM alpine:${ALPINE_VERSION}
LABEL maintainer="sebastian@nephosolutions.com"

RUN apk add --no-cache --update git jq make openssh python py-pip
RUN pip install awscli

RUN addgroup circleci && \
    adduser -G circleci -D circleci

USER circleci
WORKDIR /home/circleci

COPY --from=downloader /usr/local/bin/terraform /usr/local/bin/terraform
COPY --chown=circleci:circleci .terraform.d /home/circleci/.terraform.d
