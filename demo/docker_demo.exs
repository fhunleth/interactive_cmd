#!/usr/bin/env elixir
# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
# Demo script showing InteractiveCmd with Docker

Mix.install([{:interactive_cmd, path: ".."}])

defmodule DockerDemo do
  @image_name "interactive-cmd-demo"
  @container_name "interactive-cmd-demo-container"

  def run() do
    try do
      build_image()
      run_container()
    after
      cleanup()
    end

    IO.puts("\nDone.\n")
  end

  defp build_image() do
    IO.puts("Running 'docker build' to create an Alpine image for the demo...")

    case System.cmd("docker", ["build", "-t", @image_name, "./"], stderr_to_stdout: true) do
      {_output, 0} ->
        IO.puts("Image built successfully\n")

      {output, _} ->
        IO.puts("Failed to build image:")
        IO.puts(output)
        System.halt(1)
    end
  end

  defp run_container() do
    IO.puts("Starting an interactive container session from within an Elixir script...")
    IO.puts("\nType 'exit' when done.\n")

    {_, exit_status} =
      InteractiveCmd.cmd("docker", [
        "run",
        "--rm",
        "-it",
        "--name",
        @container_name,
        @image_name,
        "/bin/sh"
      ])

    IO.puts("\nContainer session exited with status: #{exit_status}")
  end

  defp cleanup() do
    IO.puts("\nCleaning up demo container...")

    case System.cmd("docker", ["rmi", @image_name], stderr_to_stdout: true) do
      {_output, 0} ->
        IO.puts("Image removed")

      {_output, _} ->
        IO.puts("Image may have already been removed")
    end
  end
end

DockerDemo.run()
