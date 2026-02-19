# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule InteractiveCmdTest do
  use ExUnit.Case, async: false
  doctest InteractiveCmd

  setup do
    # There's a race with getting assertion failure messages printed to the
    # console when running multiple tests. This doesn't seem that surprising
    # that buffered output is lost when starting an interactive session even
    # though I don't know whether that's happening. Adding a short wait before
    # starting the next test works 100% of the time on my laptop. Everything
    # else I tried had been flaky or just didn't work.
    Process.sleep(50)

    :ok
  end

  test "platform meets requirements" do
    assert :ok == InteractiveCmd.check_requirements()
  end

  test "non-startup console fails" do
    # Create a bogus group_leader that doesn't have :user_drv as its parent
    {:ok, bogus_gl} = Agent.start_link(fn -> :ok end)
    Process.group_leader(self(), bogus_gl)

    assert {:error, message} = InteractiveCmd.check_requirements()
    assert message == "Must be running on the startup console"

    assert_raise RuntimeError, fn -> InteractiveCmd.cmd("ls", []) end
  end

  describe "cmd/3" do
    test "runs a command" do
      path = "tmp_file.txt"

      _ = File.rm(path)
      {"", 0} = InteractiveCmd.cmd("touch", [path])

      assert File.exists?(path)
      File.rm!(path)
    end

    test "returns exit status" do
      # Spot check that return values pass through
      statuses = [0, 1, 2, 3, 4, 5, 6, 7, 127, 128, 255]

      Enum.each(statuses, fn i ->
        {"", status} = InteractiveCmd.cmd("./test/fixture/exit_code.sh", [to_string(i)])
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

    test "log_path option" do
      temp_dir = System.tmp_dir!()

      filename = "tmp_file with spaces.log"
      path = Path.join(temp_dir, filename)
      _ = File.rm(path)

      # Print dots to be less obtrusive to mix test output
      {"", 0} = InteractiveCmd.cmd("printf", ["..."], log_path: path)

      assert File.read!(path) == "..."
      File.rm!(path)
    end

    test "log_path option with quotes in path" do
      temp_dir = System.tmp_dir!()

      filename = ~s(tmp_file "with quotes".log)
      path = Path.join(temp_dir, filename)
      _ = File.rm(path)

      {"", 0} = InteractiveCmd.cmd("printf", ["...."], log_path: path)

      assert File.read!(path) == "...."
      File.rm!(path)
    end

    test "log_path option with special characters in path" do
      temp_dir = System.tmp_dir!()

      filename = "tmp_file_$with_!special&.log"
      path = Path.join(temp_dir, filename)
      _ = File.rm(path)

      {"", 0} = InteractiveCmd.cmd("printf", ["....."], log_path: path)

      assert File.read!(path) == "....."
      File.rm!(path)
    end
  end

  describe "shell/2" do
    test "runs a command" do
      path = "tmp_file.txt"

      _ = File.rm(path)
      {"", 0} = InteractiveCmd.shell("echo hello > #{path}")

      assert File.exists?(path)
      assert File.read!(path) == "hello\n"
      File.rm!(path)
    end

    test "setting environment" do
      path = "tmp_file.txt"
      env_name = "INTERACTIVE_SHELL_TEST"

      # If the variable is set before the test is run, then the check
      # afterwards will fail even though all is good
      assert System.get_env(env_name) == nil
      _ = File.rm(path)

      {"", 0} = InteractiveCmd.shell("touch $#{env_name}", env: %{env_name => path})

      assert File.exists?(path)
      File.rm!(path)

      assert System.get_env(env_name) == nil
    end
  end

  describe "trim_first_and_last_lines/1" do
    defp trim_first_and_last_lines(input) do
      {:ok, result} =
        StringIO.open(input, [], fn pid ->
          IO.stream(pid, :line) |> InteractiveCmd.trim_first_and_last_lines() |> Enum.to_list()
        end)

      result
    end

    test "strips header and footer from single-line output" do
      input = """
      Script started on 2026-02-19 17:57:56-05:00 [COMMAND="printf hello" TERM="xterm-256color" TTY="/dev/pts/0" COLUMNS="112" LINES="22"]
      hello
      Script done on 2026-02-19 17:57:56-05:00 [COMMAND_EXIT_CODE="0"]
      """

      assert trim_first_and_last_lines(input) == ["hello"]
    end

    test "strips header and footer from single-line output with trailing newline" do
      input = """
      Script started on 2026-02-19 17:58:51-05:00 [COMMAND="printf 'hello\\n'" TERM="xterm-256color" TTY="/dev/pts/0" COLUMNS="112" LINES="22"]
      hello

      Script done on 2026-02-19 17:58:51-05:00 [COMMAND_EXIT_CODE="0"]
      """

      assert trim_first_and_last_lines(input) == ["hello\n"]
    end

    test "strips header and footer from multi-line output" do
      input =
        """
        Script started on 2026-02-19 17:59:43-05:00 [COMMAND="printf 'line1\\nline2\\nline3\\n'" TERM="xterm-256color" TTY="/dev/pts/0" COLUMNS="112" LINES="22"]
        line1
        line2
        line3

        Script done on 2026-02-19 17:59:43-05:00 [COMMAND_EXIT_CODE="0"]
        """

      assert trim_first_and_last_lines(input) == ["line1\n", "line2\n", "line3\n"]
    end

    test "strips header and footer with empty output" do
      input =
        """
        Script started on 2026-02-19 18:03:20-05:00 [COMMAND="true" TERM="xterm-256color" TTY="/dev/pts/0" COLUMNS="112" LINES="22"]

        Script done on 2026-02-19 18:03:20-05:00 [COMMAND_EXIT_CODE="0"]
        """

      assert trim_first_and_last_lines(input) == []
    end
  end
end
