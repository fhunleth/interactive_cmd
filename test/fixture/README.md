<!--
  SPDX-FileCopyrightText: 2025 Frank Hunleth
  SPDX-License-Identifier: CC-BY-4.0
-->

# run_pty

CI doesn't run the tests in a pseudo-terminal like users will do. Since the
whole point of `interactive_cmd` is to be interactive, this environment isn't
helpful for verifying that the library works. `run_pty` fixes this.

## Notes

1. OTP 28 has a fix in it that makes it actually work on CI
2. `script` can't be used. I tried making it work and it has some really wild
   errors on OTP 27 and earlier.

