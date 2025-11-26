# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
# Simple Alpine Linux container for interactive demo

FROM alpine:latest

RUN apk add --no-cache \
    coreutils \
    procps \
    util-linux \
    btop

ENV LANG=en_US.UTF-8

CMD ["/bin/sh"]
