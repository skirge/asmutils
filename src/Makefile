# Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
#
# Makefile for asmutils (GNU make is required)
#
# $Id: Makefile,v 1.6 2000/09/03 16:13:54 konst Exp $

#---------------------------------------------------------------------------#

#			CONFIGURATION PARAMETERS

#---------------------------------------------------------------------------#

BUILD_SRC = y

include ../MCONFIG

#---------------------------------------------------------------------------#

#			DO NOT EDIT BELOW

#---------------------------------------------------------------------------#

FILES = basename cat echo mkdir kill pwd sleep sync tee true uname yes\
	factor ln more md5sum lzss rmdsum strings id wc httpd hostname\
	chmod chroot grep rc6crypt sln env dirname extname cpuinfo\
#	dumpcore regs execve report

LINKS = arch domainname false rmdir cpuspeed

ifdef LINUX

FILES += chvt cp dmesg df eject ls lsmod mount mv nc\
	 ps rm rmmod reboot softdog swapon tty update\
	 window leaves fire256

LINKS += ccd deallocvt halt poweroff swapoff umount

endif

all:	$(FILES) links

links:	$(FILES)
	@( mkln() { [ ! -e $$2 ] && [ -x $$1 ] && $(LN) $$1 $$2; };\
	mkln chvt deallocvt;\
	mkln hostname domainname;\
	mkln mount umount;\
	mkln reboot halt;\
	mkln reboot poweroff;\
	mkln mkdir rmdir;\
	mkln swapon swapoff;\
	mkln true false;\
	mkln uname arch;\
	mkln cpuinfo cpuspeed;\
	mkln eject ccd;\
	)

install:$(FILES)
	$(MKDIR) ../bin/$(OS)-$(KERNEL)
	$(CP) $(FILES) $(LINKS) ../bin/$(OS)-$(KERNEL)

clean:
	$(RM) *.o $(FILES) $(LINKS)
