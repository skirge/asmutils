# Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
#
# Makefile for libc
#
# $Id: Makefile,v 1.3 2000/02/10 15:07:04 konst Exp $

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

CFLAGS = -O1 -fomit-frame-pointer -nostartfiles #-nostdlib  #-mregparm=3

example: example.c
	 gcc $(CFLAGS) -Wl,-e,main -o example example.c $(SO)
