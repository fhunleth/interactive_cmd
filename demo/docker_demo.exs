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
    IO.puts("\n╔" <> String.duplicate("═", 58) <> "╗")
    IO.puts("║       InteractiveCmd - Docker Interactive Demo           ║")
    IO.puts("╚" <> String.duplicate("═", 58) <> "╝\n")

    try do
      build_image()
      run_container()
    after
      cleanup()
    end

    IO.puts("\n✓ Demo complete!\n")
  end

  defp build_image() do
    IO.puts("📦 Building Docker image...")

    case System.cmd("docker", ["build", "-t", @image_name, "./"], stderr_to_stdout: true) do
      {_output, 0} ->
        IO.puts("✓ Image built successfully\n")

      {output, _} ->
        IO.puts("✗ Failed to build image:")
        IO.puts(output)
        System.halt(1)
    end
  end

  defp run_container() do
    IO.puts("🚀 Starting interactive container session...")
    IO.puts("   You can run commands inside the Alpine Linux container.")
    IO.puts("   Type 'exit' when done.\n")

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

    if exit_status == 0 do
      IO.puts("\n✓ Container session completed successfully")
    else
      IO.puts("\n✗ Container session exited with status: #{exit_status}")
    end
  end

  defp cleanup() do
    IO.puts("\n🧹 Cleaning up...")

    case System.cmd("docker", ["rmi", @image_name], stderr_to_stdout: true) do
      {_output, 0} ->
        IO.puts("✓ Image removed")

      {_output, _} ->
        IO.puts("⚠ Image may have already been removed")
    end
  end
end

DockerDemo.run()
