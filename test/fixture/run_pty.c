// SPDX-FileCopyrightText: None
// SPDX-License-Identifier: CC0-1.0

// This was 100% LLM generated to just call forkpty.

#define _XOPEN_SOURCE 600
#include <pty.h>        // forkpty
#include <utmp.h>       // for some systems' forkpty prototype
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/select.h>
#include <errno.h>
#include <string.h>

int main(int argc, char *argv[])
{
    if (argc < 2) {
        fprintf(stderr, "Usage: %s command [args...]\n", argv[0]);
        return 1;
    }

    int master_fd;
    pid_t pid = forkpty(&master_fd, NULL, NULL, NULL);
    if (pid < 0) {
        perror("forkpty");
        return 1;
    }

    if (pid == 0) {
        // Child: exec the command; stdin/stdout/stderr are on the pty slave.
        execvp(argv[1], &argv[1]);
        // If execvp returns, it's an error.
        perror("execvp");
        _exit(127);
    }

    // Parent: pump data between our stdin/stdout and the pty master.
    // For CI use you mostly care about pty -> stdout, but we handle both.
    fd_set rfds;
    int done = 0;
    char buf[4096];

    while (!done) {
        FD_ZERO(&rfds);
        FD_SET(master_fd, &rfds);
        FD_SET(STDIN_FILENO, &rfds);

        int maxfd = master_fd > STDIN_FILENO ? master_fd : STDIN_FILENO;

        int r = select(maxfd + 1, &rfds, NULL, NULL, NULL);
        if (r < 0) {
            if (errno == EINTR)
                continue;
            perror("select");
            break;
        }

        // Data from child -> stdout
        if (FD_ISSET(master_fd, &rfds)) {
            ssize_t n = read(master_fd, buf, sizeof(buf));
            if (n <= 0) {
                // EOF or error; child likely exited.
                done = 1;
            } else {
                ssize_t off = 0;
                while (off < n) {
                    ssize_t w = write(STDOUT_FILENO, buf + off, n - off);
                    if (w < 0) {
                        if (errno == EINTR) continue;
                        perror("write stdout");
                        done = 1;
                        break;
                    }
                    off += w;
                }
            }
        }

        // Data from stdin -> child (not usually needed in CI, but included)
        if (FD_ISSET(STDIN_FILENO, &rfds)) {
            ssize_t n = read(STDIN_FILENO, buf, sizeof(buf));
            if (n <= 0) {
                // stdin closed: stop forwarding input, but keep reading output
                FD_CLR(STDIN_FILENO, &rfds);
            } else {
                ssize_t off = 0;
                while (off < n) {
                    ssize_t w = write(master_fd, buf + off, n - off);
                    if (w < 0) {
                        if (errno == EINTR) continue;
                        perror("write pty");
                        done = 1;
                        break;
                    }
                    off += w;
                }
            }
        }
    }

    close(master_fd);

    // Reap child and return its exit status.
    int status;
    pid_t w = waitpid(pid, &status, 0);
    if (w < 0) {
        perror("waitpid");
        return 1;
    }

    if (WIFEXITED(status)) {
        return WEXITSTATUS(status);
    } else if (WIFSIGNALED(status)) {
        return 128 + WTERMSIG(status);
    } else {
        return 1;
    }
}

