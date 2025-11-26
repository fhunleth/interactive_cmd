# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: CC0-1.0
#
# VHS documentation: https://github.com/charmbracelet/vhs
#
# To run this demo:
#   cd demo
#   vhs /docker_demo.tape
#
# Output:
#   docker_demo.gif

Output docker_demo.gif

Set FontSize 15
Set Width 1024
Set Height 600
Set TypingSpeed 50ms

Type "elixir docker_demo.exs"
Sleep 1s
Enter

# Wait for container to start and give some time to read.
Sleep 6s

# ls
Type "# We're in the container now. Take a quick look..."
Sleep 1s
Enter
Type "ls -l"
Sleep 1s
Enter
Sleep 2s

# btop
Type "# Interactive apps work like you'd expect. Here's btop..."
Sleep 1s
Enter
Sleep 1s
Type "btop"
Sleep 1s
Enter
Sleep 10s
Type "q"
Sleep 1s

# Interrupted sleep
Enter
Type "# CTRL+C doesn't get intercepted! Use it to stop sleeping..."
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
Type "# All done. Going to exit the container and return to Elixir..."
Sleep 1s
Enter
Sleep 1s
Type "exit"
Sleep 1s
Enter

# Let the user watch the final text for a bit before looping
Sleep 15s
