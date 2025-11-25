<!--
  SPDX-FileCopyrightText: 2025 Frank Hunleth
  SPDX-License-Identifier: CC-BY-4.0
-->

# InteractiveCmd Docker Demo

This directory contains a demonstration of `InteractiveCmd` using [VHS](https://github.com/charmbracelet/vhs) to create an animated GIF showing the library in action with Docker containers.

## Demo Overview

The demo shows an Elixir script that:

1. **Builds** a Docker image from the Dockerfile
2. **Runs** an interactive shell inside the container using `InteractiveCmd`
3. **Demonstrates** full terminal interaction:
   - Running commands (`ls`, `top`, etc.)
   - Interrupting long-running commands with Ctrl+C
   - Full interactive control from within Elixir
4. **Cleans up** by removing the Docker image

## Files

- `Dockerfile` - Alpine Linux container with useful tools for the demo
- `docker_demo.exs` - Elixir script that manages the Docker lifecycle and runs an interactive session
- `docker_demo.tape` - VHS tape file that records the demo session
- `docker_demo.gif` - Generated demo animation (created by running VHS)

## Running the Demo

### Prerequisites

- Docker installed and running
- Elixir installed

### Manual Test

Run the demo script directly:

```bash
./demo/docker_demo.exs
```

This will:

- Build the Docker image
- Start an interactive shell in the container
- Let you run commands (try `ls`, `top`, `sleep 60` then Ctrl+C)
- Type `exit` to finish
- Clean up the Docker image

### Generate the GIF

First, install VHS:

```bash
# On macOS
brew install vhs

# On Linux
# See <https://github.com/charmbracelet/vhs#installation>
```

Then generate the demo GIF:

```bash
vhs demo/docker_demo.tape
```

This will create `demo/docker_demo.gif` showing the complete interactive demo.

## How It Works

The demo showcases `InteractiveCmd`'s key capabilities:

1. **Full Terminal Control**: `InteractiveCmd.cmd/3` connects the Docker container's shell directly to the terminal
2. **User Interaction**: Users can type commands and see output in real-time
3. **Signal Handling**: Ctrl+C and other terminal signals work correctly
4. **Lifecycle Management**: The Elixir script manages the entire Docker lifecycle programmatically

The key line is:

```elixir
{"", exit_status} = InteractiveCmd.cmd("docker", [
  "run", "--rm", "-it", "--name", @container_name,
  @image_name, "/bin/sh"
])
```

This runs an interactive Docker container shell, and because of `InteractiveCmd`, the user can interact with it as if they ran the `docker run` command directly from their terminal.

## Use Cases

This pattern is useful for:

- **Development tools** that need to run interactive containers
- **Deployment scripts** that require user input during execution
- **Testing tools** that interact with containerized environments
- **Build pipelines** that need interactive debugging sessions
- **Any scenario** where you want to programmatically start an interactive session from Elixir
