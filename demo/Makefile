# SPDX-FileCopyrightText: None
# SPDX-License-Identifier: CC0-1.0
all: docker_demo.gif

%.gif: %.tape
	vhs $<

# Additional dependencies
docker_demo.gif: docker_demo.exs

.PHONY: all
