# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule InteractiveCmd do
  @moduledoc """
  Run interactive shell commands from mostly pure Elixir
  """

  @typedoc """
  Options for `cmd/3`
  """
  @type options() :: [env: %{String.t() => String.t()}, cd: String.t()]

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
  * `:cd` - the directory to run the command in. See `System.cmd/3`.

  Returns `{"", exit_status}` where the first element is always an empty string
  and the second is the exit status of the command. This return value is
  intentionally similar to `System.cmd/3` to allow `InteractiveCmd,cnd/3` to be
  swapped in quickly when needed.
  """
  @spec cmd(binary(), [binary()], options()) :: {binary(), exit_status :: non_neg_integer()}
  def cmd(cmd, args, options \\ []) do
    original_env = System.get_env()
    original_dir = File.cwd!()

    if cd = Keyword.get(options, :cd) do
      File.cd!(cd)
    end

    quoted_cmd = Enum.map_join([cmd | args], " ", &shell_quote/1)
    visual_cmd = launcher_command()

    System.put_env(Keyword.get(options, :env, %{}))
    System.put_env("INTERACTIVE_CMD_COMMAND", quoted_cmd)
    System.put_env("VISUAL", visual_cmd)

    send(:user_drv, {self(), {:open_editor, ""}})

    result =
      receive do
        {_pid, {:editor_data, output}} -> output
      end

    File.cd!(original_dir)
    restore_env(original_env)
    {"", parse_exit_status(result)}
  end

  defp launcher_command() do
    # $1 is the results filename from user_drv
    case :os.type() do
      {:unix, :linux} ->
        # GNU version of script
        ~s(sh -c 'script -e -q /dev/null -c "$INTERACTIVE_CMD_COMMAND"; echo $? > "$1"' sh)

      {:unix, _bsd} ->
        # BSD version of script
        ~s(sh -c 'script -q /dev/null sh -c "$INTERACTIVE_CMD_COMMAND"; echo $? > "$1"' sh)
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
