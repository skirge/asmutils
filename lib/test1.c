/*
	Copyright (C) 1999-2000 Konstantin Boldyshev

	$Id: test1.c,v 1.1 2000/03/02 08:52:01 konst Exp $

	test program for assembly libc
*/

#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>

#include "libc.h"

static char *fname = "_tst_",
	    *s = "Hello,world!\n",
	    buf[100];

static int fd, len;

int main(void)
{
    FASTCALL(3);

    len = strlen(s);

    fd = open(fname, O_CREAT | O_RDWR, 0600);
    write(fd, s, len);
    close(fd);

    fd = open(fname, O_RDONLY);
    lseek(fd, 0, SEEK_SET);
    len = read(fd, buf, len);
    close(fd);

    unlink(fname);

    write(STDOUT_FILENO, buf, len);

    exit(0); /* MUST be called to exit */
}
