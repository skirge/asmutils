# Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
#
# Makefile for libc
#
# $Id: Makefile,v 1.4 2000/03/02 08:52:01 konst Exp $

# Operating system (LINUX/FREEBSD/BEOS)

OS = LINUX

# Optimization method (SIZE/SPEED)

OPTIMIZE = SIZE

#

AS = nasm
LD = ld
CC = gcc
ASFLAGS = -D__$(OS)__ -D__OPTIMIZE__=__O_$(OPTIMIZE)__  -i ../src/ -f elf
CFLAGS = -Wall -O2 -fomit-frame-pointer -nostartfiles -nostdlib -Wl,-e,main 

FILES = libc #clib
TESTS = test1 test2
SO = ./libc.so #./clib.so

all:	libc tests

%:	%.asm
	$(AS) $(ASFLAGS) $<
	$(LD) -shared -o $*.so $*.o

clean:
	rm -f *.o *.so *.fc $(TESTS)

tests: $(TESTS)

%:	%.c
	$(CC) $(CFLAGS) -o $@ $< $(SO)
	$(CC) $(CFLAGS) -mregparm=3 -D__FASTCALL__ -o $@.fc $< $(SO)
