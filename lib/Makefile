# Copyright (C) 1999 Konstantin Boldyshev <konst@voshod.com>
#
# Makefile for libc
#
# $Id: Makefile,v 1.1 2000/01/26 21:19:02 konst Exp $

FILES = libc #clib
AS = nasm
ASFLAGS = -f elf -i ../src/
LD = ld
LDFLAGS = -shared

SO = ./libc.so #./clib.so

%.o:	%.asm
	$(AS) $(ASFLAGS) $<

%:	%.o
	$(LD) $(LDFLAGS) -o $*.so $<

all:	$(FILES) example

clean:
	rm -f *.o *.so example

CFLAGS = -O1 -fomit-frame-pointer -nostartfiles #-nostdlib #-mregparm=3

example: example.c
	 gcc $(CFLAGS) -Wl,-e,main -o example example.c $(SO)
