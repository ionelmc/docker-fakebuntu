/*
 *  Prevent systemd from closing /dev/console in docker
 *  Ignore dup2 call to stdout with "/dev/null", which will
 *  leave the file handle of /dev/console open and
 *  therefore "protect" /dev/console from being closed by systemd
 *
 *  Costs one file descriptor, saves the lives of millions of containers ;)
 *
 *  https://github.com/systemd/systemd/pull/4262#issuecomment-252147745
 */

#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

static int (*orig_dup2)(int oldfd, int newfd) = NULL;

int is_dev_null(int oldfd) {
    char buffer[32]; // long enough for /dev/null
    char *bufp = &buffer[0];

    sprintf(bufp, "/proc/self/fd/%i", oldfd);
    int bytes_read =  readlink(bufp, bufp, 32);
    if (bytes_read > -1 && bytes_read < 32) {
        *(bufp+bytes_read) = 0;
        return (strcmp("/dev/null", bufp) == 0);
    }
    return 0;
}

int dup2(int oldfd, int newfd) {
    if (newfd == STDOUT_FILENO && is_dev_null(oldfd)) {
        return oldfd;
    }
    orig_dup2 = dlsym(RTLD_NEXT, "dup2");
    return orig_dup2(oldfd, newfd);
}
