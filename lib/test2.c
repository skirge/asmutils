/*
	Copyright (C) 1999-2000 Konstantin Boldyshev
    
	$Id: test2.c,v 1.2 2000/09/03 16:13:54 konst Exp $

	test program for assembly libc
*/

#include <stdio.h>
#include "libc.h"

int main(void)
{
    FASTCALL(3);

    printf("\tprintf() test\nhex: %x, octal: %o, decimal: %d\n", 0x10, 010, 10);

    exit(0); /* MUST be called to exit */
}
