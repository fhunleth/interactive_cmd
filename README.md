<!--
  SPDX-FileCopyrightText: 2025 Frank Hunleth
  SPDX-License-Identifier: CC-BY-4.0
-->

# InteractiveCmd

[![Hex version](https://img.shields.io/hexpm/v/interactive_cmd.svg "Hex version")](https://hex.pm/packages/interactive_cmd)
[![API docs](https://img.shields.io/hexpm/v/interactive_cmd.svg?label=hexdocs "API docs")](https://hexdocs.pm/interactive_cmd/InteractiveCmd.html)
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/fhunleth/interactive_cmd/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/fhunleth/interactive_cmd/tree/main)
[![REUSE status](https://api.reuse.software/badge/github.com/fhunleth/interactive_cmd)](https://api.reuse.software/info/github.com/fhunleth/interactive_cmd)

Run interactive shell commands from mostly pure Elixir

This addresses an issue when writing commandline scripts that need to invoke
commands that require user input. Examples include commands that ask for
passwords like `ssh` and `sudo`, menu-driven commands, and launching text
editors.

This library works by using Erlang's command line editor feature launches an
editor to provide input to the shell prompt. You can try this by typing Ctrl-o
or Meta-o at the IEx prompt assuming your OS doesn't already have a mapping for
that key combination. Since this functionality isn't provided by a public API,
standard caveats apply. Luckily, this works in quite a few OTP releases. This
library also verifies that it works in CI. The main limitation is that it only
works when the process group leader is backed by `:user_drv`. For scripting,
this is not much of a limitation, but it wouldn't work when using Erlang's `ssh`
server, for example. Huge thanks to [ieQu1 on the Erlang
Forum](https://erlangforums.com/t/entering-raw-mode-temporarily-while-in-the-shell-for-a-tui/5120/5)
for the original idea.

Using this is simply replacing your call to `System.cmd/3` with
`InteractiveCmd.cmd/3`. Note that output capture operations aren't supported,
but you can still pass environment variables and capture exit status.

## Example

Here's an example of using `InteractiveCmd.cmd/3` to let a user run commands in
a Docker container created by an Elixir script.

![InteractiveCmd Demo](demo/docker_demo.gif)

## Installation

The package can be installed by adding `interactive_cmd` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:interactive_cmd, "~> 0.1.0"}
  ]
end
```


