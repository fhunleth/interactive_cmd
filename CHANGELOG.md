<!--
  SPDX-FileCopyrightText: None
  SPDX-License-Identifier: CC0-1.0
-->

# Changelog

This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.1.2

* Changes
  * Add `shell/2` to avoid needing to manually call `sh -c` when updating calls
    to `System.shell/2`.

## v0.1.1

* Changes
  * Improve `:user_drv` detection to prevent running on group leaders that
    don't use `:user_drv` and therefore won't work

## v0.1.0

Initial release

