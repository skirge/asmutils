/*
	Copyright (C) 1999-2000 Konstantin Boldyshev
    
	sample C program for assembly libc

	$Id: example.c,v 1.3 2000/02/10 15:07:04 konst Exp $
*/

#undef __OPTIMIZE__
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>

char *fname = "_tst_";
char *s = "Hello,world!\n";
char buf[100];

int main(void)
{
    int fd, l = strlen(s);

    fd = open(fname, O_CREAT | O_RDWR, 0600);
//    _fastcall();
    write(fd, s, l);
    lseek(fd, 0, SEEK_SET);
    read(fd, buf, l);
    close(fd);
    unlink(fname);
    write(STDOUT_FILENO, buf, l);

//    fprintf(1, "\n[%s]: %d %d\n", "printf test", 1, -1);

    exit(0); /* MUST be called to exit */
}
