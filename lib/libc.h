/*

    Copyright (C) 1999-2001 Konstantin Boldyshev

    $Id: libc.h,v 1.2 2001/01/21 15:18:46 konst Exp $

    Header file for assembly libc, defines functions that:
	1) are not present in usual libc
	2) conflict with our libc
    We will use standard libc headers for the rest of functions for now.
*/

/*
    _fastcall() must be always fastcall
*/

extern void __attribute__ (( __regparm__(1) ))
	_fastcall(int);

/*
// reserved for future PIC version

extern unsigned char __cc;

inline void _fastcall(unsigned regnum)
{
    __cc = (unsigned char)regnum;
}
*/

/*
    _cdecl() is _fastcall(0)
*/

#define _cdecl() _fastcall(0)

#ifdef __FASTCALL__
#define FASTCALL(x) _fastcall(x)
#else
#define FASTCALL(x) _cdecl()
#endif

extern void __attribute__ (( __noreturn__ ))
	exit(int);

extern long strtol(const char *, char **, int);

/*
extern unsigned strlen(const char *);
extern void *memcpy(void *, const void *, int);
extern void *memset(void *, int, int);
*/
