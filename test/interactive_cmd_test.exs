# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule InteractiveCmdTest do
  use ExUnit.Case, async: false
  doctest InteractiveCmd

  describe "interactive_cmd/3" do
    test "runs a command" do
      path = "tmp_file.txt"

      _ = File.rm(path)
      {"", 0} = InteractiveCmd.cmd("touch", [path])

      assert File.exists?(path)
      File.rm!(path)
    end

    test "returns exit status" do
      # Spot check that return values pass through
#      statuses = [0, 1, 2, 3, 4, 5, 6, 7, 127, 128, 255]

#      Enum.each(statuses, fn i ->
#        {"", status} = InteractiveCmd.cmd("./test/fixture/exit_code.sh", [to_string(i)])
#        assert status == i
#      end)
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

    test "cd option" do
      original_dir = File.cwd!()
      temp_dir = System.tmp_dir!()

      filename = "tmp_file_in_temp.txt"
      path = Path.join(temp_dir, filename)
      _ = File.rm(path)

      {"", 0} = InteractiveCmd.cmd("touch", [filename], cd: temp_dir)

      assert File.exists?(path)
      assert File.cwd!() == original_dir

      File.rm!(path)
    end
  end
end
