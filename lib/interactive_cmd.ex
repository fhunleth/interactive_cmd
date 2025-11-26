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

  Returns `{"", exit_status}` where the first element is always an empty string and
  the second is the exit status of the command. This return value is intentionally similar to
  `System.cmd/3` to allow `InteractiveCmd,cnd/3` to be swapped in quickly when needed.
  """
  @spec cmd(binary(), [binary()], keyword()) :: {binary(), exit_status :: non_neg_integer()}
  def cmd(cmd, args, options \\ []) do
    original_env = System.get_env()

    quoted_cmd = Enum.map_join([cmd | args], " ", &shell_quote/1)

    # user_drv will append a filename to the command. `shim.sh` writes the
    # exit status to this file.
    shim = Application.app_dir(:interactive_cmd, ["priv", "shim.sh"])
    script_cmd = "#{shim} #{script_flavor()} #{shell_quote(quoted_cmd)}"

    System.put_env(Keyword.get(options, :env, %{}))
    System.put_env("VISUAL", script_cmd)

    send(:user_drv, {self(), {:open_editor, ""}})

    result =
      receive do
        {_pid, {:editor_data, output}} -> output
      end

    restore_env(original_env)
    {"", parse_exit_status(result)}
  end

  defp script_flavor() do
    case :os.type() do
      {:unix, :linux} -> "gnu"
      {:unix, _bsd} -> "bsd"
    end
  end

  defp restore_env(original) do
    env = System.get_env()
    System.put_env(original)

    to_delete = Map.keys(env) -- Map.keys(original)
    Enum.each(to_delete, &System.delete_env/1)
  end

  defp shell_quote(str), do: "'#{escape_quote(str)}'"
  defp escape_quote(str), do: String.replace(str, "'", "'\\''")

  defp parse_exit_status(output) when is_list(output) do
    trimmed = output |> to_string() |> String.trim()

    case Integer.parse(trimmed) do
      {status, ""} when status >= 0 -> status
      _ -> 255
    end
  end
end
