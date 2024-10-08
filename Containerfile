# Copyright The ORAS Authors.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM docker.io/library/golang:1.22.3-alpine as builder
ARG TARGETPLATFORM
RUN apk add git make
ENV ORASPKG /oras
ADD . ${ORASPKG}
WORKDIR ${ORASPKG}/oras
RUN go mod vendor
RUN make "build-$(echo $TARGETPLATFORM | sed s/\\/v8// | tr / -)"
RUN mv ${ORASPKG}/oras/bin/$(echo $TARGETPLATFORM | sed s/\\/v8//)/oras /usr/bin/oras
RUN mkdir /licenses && mv LICENSE /licenses/LICENSE

ENV DOTFILESPKG /dotfiles
ADD . ${DOTFILESPKG}
WORKDIR ${DOTFILESPKG}/dotfiles
RUN cat ./lazygit/.config/lazygit/config.yml

FROM quay.io/konflux-ci/yq:latest@sha256:974dea6375ee9df561ffd3baf994db2b61777a71f3bcf0050c5dca91ac9b3430 as yq

FROM registry.access.redhat.com/ubi9:latest@sha256:d98fdae16212df566150ac975cab860cd8d2cb1b322ed9966d09a13e219112e9
RUN mkdir /licenses
RUN useradd -r  --uid=65532 --create-home --shell /bin/bash oras

COPY --from=yq /usr/bin/yq /usr/bin/yq

COPY --from=builder /usr/bin/oras /usr/bin/oras
COPY --from=builder /licenses/LICENSE /licenses/LICENSE

WORKDIR /home/oras
USER 65532:65532

LABEL name="oras" \
      summary="OCI registry client - managing content like artifacts, images, packages" \
      com.redhat.component="oras" \
      description="ORAS is the de facto tool for working with OCI Artifacts. It treats media types as a critical piece of the puzzle. Container images are never assumed to be the artifact in question. ORAS provides CLI and client libraries to distribute artifacts across OCI-compliant registries." \
      io.k8s.display-name="oras" \
      io.k8s.description="ORAS is the de facto tool for working with OCI Artifacts. It treats media types as a critical piece of the puzzle. Container images are never assumed to be the artifact in question. ORAS provides CLI and client libraries to distribute artifacts across OCI-compliant registries." \
      io.openshift.tags="oci"

ENTRYPOINT  ["/usr/bin/oras"]
