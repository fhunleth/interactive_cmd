# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule InteractiveCmdTest do
  use ExUnit.Case
  doctest InteractiveCmd

  describe "interactive_cmd/3" do
    test "runs a command" do
      path = "tmp_file.txt"

      _ = File.rm(path)
      {"", 0} = InteractiveCmd.cmd("touch", [path])

      assert File.exists?(path)
      File.rm!(path)
    end

    test "returnes exit status" do
      Enum.each(0..255, fn i ->
        {"", status} = InteractiveCmd.cmd("./test/fixture/retcode.sh", [to_string(i)])
        assert status == i
      end)
    end

    test "paths with spaces" do
      path = "tmp_file with spaces.txt"

      _ = File.rm(path)
      {"", 0} = InteractiveCmd.cmd("touch", [path])

      assert File.exists?(path)
      File.rm!(path)
    end

    test "paths with quotes" do
      path = "tmp_file with ' and \".txt"

      _ = File.rm(path)
      {"", 0} = InteractiveCmd.cmd("touch", [path])

      assert File.exists?(path)
      File.rm!(path)
    end

    test "setting environment" do
      path = "tmp_file.txt"
      env_name = "INTERACTIVE_SHELL_TEST"

      # If the variable is set before the test is run, then the check
      # afterwards will fail even though all is good
      assert System.get_env(env_name) == nil
      _ = File.rm(path)

      {"", 0} = InteractiveCmd.cmd("sh", ["-c", "touch $#{env_name}"], env: %{env_name => path})

      assert File.exists?(path)
      File.rm!(path)

      assert System.get_env(env_name) == nil
    end

    test "interactive tty" do
      path = "tmp_file.txt"
      _ = File.rm(path)

      {"", 0} =
        InteractiveCmd.cmd("sh", [
          "-c",
          "[ -t 0 ] && echo interactive > #{path} || echo non-interactive > #{path}"
        ])

      assert File.read(path) == {:ok, "interactive\n"}
      File.rm!(path)
    end
  end
end
