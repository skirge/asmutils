/*
	Copyright (C) 1999-2001 Konstantin Boldyshev
    
	$Id: test2.c,v 1.3 2001/01/21 15:18:46 konst Exp $

	test program for assembly libc
*/

#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "libc.h"

int main(void)
{
    char inp[10], tmp[10];
    char *ptmp;
    int len;

    FASTCALL(3);

    printf("\n\tprintf() test\nhex: %x, octal: %o, decimal: %d\n", 0x10, 010, 10);

    printf("\n\tstrtol() test\nInput some decimal number: ");
    len = read(STDIN_FILENO, inp, 10);
    memcpy(tmp, inp, len);
    ptmp = &tmp[0] + len - 1;
    printf("You have entered %d\n", (int)strtol(&tmp[0], &ptmp, 10));

    printf("\n\tmemset() test\n");
    memset(tmp, 0, 10);
    ptmp = &tmp[0] + 5;
    for (len = 9; len > 0; len --) {
	memset(tmp, '0'+len, 5);
	printf("%d ", (int)strtol(&tmp[0], &ptmp, 10));
    }

    printf("\n\n\tall tests done\n");

    exit(0); /* MUST be called to exit */
}
