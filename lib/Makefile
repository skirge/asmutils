# Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
#
# Makefile for libc (GNU make is required)
#
# $Id: Makefile,v 1.6 2000/12/10 08:20:36 konst Exp $

BUILD_LIB = y

include ../MCONFIG

#---------------------------------------------------------------------------#

#			DO NOT EDIT BELOW

#---------------------------------------------------------------------------#

BUILD_SHARED = y

CRYPTO = md5.o rc6.o rmd.o
LIBC = libc.o
TESTS = test1 test2

LIBSO = ./libc.so

all:	libc tests crypto

libc:	$(LIBC)
	$(AR) rcv $@.a $(LIBC)
ifdef BUILD_SHARED
	$(LD) $(LDFLAGS) -shared -soname $(LIBSO) -o $(LIBSO) $(LIBC)
endif

crypto:	$(CRYPTO)
	$(AR) rcv lib$@.a $(CRYPTO)
ifdef BUILD_SHARED
	$(LD) $(LDFLAGS) -shared -soname lib$@.so -o lib$@.so $(CRYPTO)
endif

#CRYPTOFILES = ../src/md5sum.o
#cryptofiles: $(CRYPTOFILES)
#	ld -s -o aaa $(CRYPTOFILES) libcrypto.a

ifdef AOUT
tests:
else
tests: $(TESTS)
endif

install:

clean:
	rm -f $(TESTS) *.o *.a *.so *.fc
