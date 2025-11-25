# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: CC0-1.0
#
# VHS documentation: https://github.com/charmbracelet/vhs
#
# To run this demo:
#   vhs demo/docker_demo.tape
#
# Output:
#   demo/docker_demo.gif

Output demo/docker_demo.gif

Set FontSize 16
Set Width 1400
Set Height 800
Set TypingSpeed 50ms
Set PlaybackSpeed 0.5

Type "# This demo shows InteractiveCmd running an interactive shell"
Sleep 1.5s
Enter
Type "# inside a Docker container, with full terminal control"
Sleep 2s
Enter
Sleep 500ms

Type "elixir demo/docker_demo.exs"
Sleep 1s
Enter

# Wait for Docker image to build and container to start
Sleep 8s

# Run ls command
Type "ls -la"
Sleep 1s
Enter
Sleep 2s

# Run top briefly
Type "# Going to run top for a bit and they type q to quit...'"
Sleep 1s
Type "top"
Sleep 1s
Enter
Sleep 3s
Type "q"
Sleep 3s

# Run a long command and interrupt it
Enter
Type "# Going to type CTRL+C to break out of a long sleep...'"
Sleep 1s
Enter
Sleep 1s

Type "sleep 60"
Sleep 1s
Enter
Sleep 2s
Ctrl+C
Sleep 2s

# Show we're still in the shell
Type "# All done. Going to exit the container."
Sleep 1s
Enter
Sleep 2s
Type "exit"
Sleep 1s
Enter

# Wait for cleanup
Sleep 4s

# Final commentary
Enter
Type "# InteractiveCmd gives you full terminal control from Elixir"
Sleep 1.5s
Enter
Type "# Perfect for interactive CLIs, containers, and more!"
Sleep 3s
Enter

Sleep 2s
