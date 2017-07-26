#   Copyright 2017 Sebastian Trebitz
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

FROM alpine:3.6
MAINTAINER "Sebastian Trebitz <sebastian@strebitz.com>"

ENV TERRAFORM_VERSION=0.9.11

COPY releases_public_key .

RUN apk add --no-cache --update curl git gnupg jq make openssh python py-pip

RUN pip install awscli

RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig > terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS > terraform_${TERRAFORM_VERSION}_SHA256SUMS

RUN gpg --import releases_public_key
RUN gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS

RUN grep linux_amd64 terraform_${TERRAFORM_VERSION}_SHA256SUMS >terraform_${TERRAFORM_VERSION}_SHA256SUMS_linux_amd64
RUN sha256sum -cs terraform_${TERRAFORM_VERSION}_SHA256SUMS_linux_amd64

RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin
RUN rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
