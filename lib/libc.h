/*

    Copyright (C) 1999-2000 Konstantin Boldyshev

    $Id: libc.h,v 1.1 2000/03/02 08:52:01 konst Exp $

    Header file for assembly libc, defines functions NOT present in usual libc
    
*/

/*
    _cdecl() is _fastcall(0)
*/

extern void _fastcall(int);

#define _cdecl() _fastcall(0)

#ifdef __FASTCALL__
#define FASTCALL(x) _fastcall(x)
#else
#define FASTCALL(x) _cdecl()
#endif
