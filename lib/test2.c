/*
	Copyright (C) 1999-2000 Konstantin Boldyshev
    
	$Id: test2.c,v 1.1 2000/03/02 08:52:01 konst Exp $

	test program for assembly libc
*/

#include <fcntl.h>
#include <unistd.h>

#include "libc.h"

static char buf[100];
static int l;

/*
    fails with fastcall?
*/

int main(void)
{
    FASTCALL(3);

    l = read(STDIN_FILENO, buf, 10);
    write(STDOUT_FILENO, buf, l);
    exit(l); /* MUST be called to exit */
}
