# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule InteractiveCmd do
  @moduledoc """
  Documentation for `InteractiveCmd`.
  """

    @doc """
  Starts an interactive command

  This shell will take over the terminal so that it's possible for the user to
  interact with whatever program is run. All input is sent to the command
  including CTRL+C. This allows you to invoke interactive commands like those
  that request passwords, prompt for input, or show an interactive text-based
  UI.

  This uses `:user_drv` internally so it only works at the startup console or
  other consoles that use it.

  Options:
  * `:env` - a map of string key/value pairs to be put into the environment.
    See `System.put_env/1`.
  """
  @spec cmd(binary(), [binary()], keyword()) :: :ok
  def cmd(cmd, args, options \\ []) do
    original_env = System.get_env()

    quoted_args = Enum.map(args, &shell_quote/1)
    command = Enum.join([shell_quote(cmd) | quoted_args], " ")

    # Everything after the trailing ; gets trimmed, so
    # the filename that's appended to the end by Erlang's
    # prompt editor support will get ignored.
    script_cmd =
      case :os.type() do
        {:unix, :linux} -> "script -q /dev/null -c #{shell_quote(command)};"
        {:unix, _bsd} -> "script -q /dev/null #{command};"
      end

    System.put_env(Keyword.get(options, :env, %{}))
    System.put_env("VISUAL", script_cmd)
    send(:user_drv, {self(), {:open_editor, ""}})

    receive do
      {_pid, {:editor_data, _result}} -> :ok
    end

    restore_env(original_env)
  end

  defp restore_env(original) do
    env = System.get_env()
    System.put_env(original)

    to_delete = Map.keys(env) -- Map.keys(original)
    Enum.each(to_delete, &System.delete_env/1)
  end

  defp shell_quote(str) do
    escaped = String.replace(str, "'", "'\\''")
    "'#{escaped}'"
  end

end
