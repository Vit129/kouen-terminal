// Kept apart from shim.c: its _XOPEN_SOURCE hides the Darwin types <libproc.h> needs.
#include "CHarnessSys.h"

#ifdef __APPLE__
#include <libproc.h>
#include <sys/proc_info.h>
#include <unistd.h>

// POST-FORK SAFETY: proc_pidinfo is a direct wrapper over the proc_info system call (no
// allocation, no locks), and `buffer` was allocated by the parent before fork.
int harness_close_listed_fds(int lowfd, int keep, void *buffer, int buffer_bytes) {
    if (buffer == NULL || buffer_bytes < (int)sizeof(struct proc_fdinfo)) return -1;
    int bytes = proc_pidinfo(getpid(), PROC_PIDLISTFDS, 0, buffer, buffer_bytes);
    // A full buffer may be truncated. The caller then falls back to closing every number.
    if (bytes <= 0 || bytes > buffer_bytes - (int)sizeof(struct proc_fdinfo)) return -1;
    const struct proc_fdinfo *list = (const struct proc_fdinfo *)buffer;
    int count = bytes / (int)sizeof(struct proc_fdinfo);
    for (int index = 0; index < count; index++) {
        int fd = list[index].proc_fd;
        if (fd >= lowfd && fd != keep) close(fd);
    }
    return 0;
}
#else
int harness_close_listed_fds(int lowfd, int keep, void *buffer, int buffer_bytes) {
    (void)lowfd; (void)keep; (void)buffer; (void)buffer_bytes;
    return -1;
}
#endif
