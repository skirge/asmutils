# Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
#
# Makefile for asmutils (GNU make is required)
#
# $Id: Makefile,v 1.7 2000/12/10 08:20:36 konst Exp $

#---------------------------------------------------------------------------#

#			CONFIGURATION PARAMETERS

#---------------------------------------------------------------------------#

BUILD_SRC = y

include ../MCONFIG

#---------------------------------------------------------------------------#

#			DO NOT EDIT BELOW

#---------------------------------------------------------------------------#

FILES = basename cat chmod chroot cp cpuinfo dirname echo env extname factor\
	grep head hostname httpd id kill ln lzss mkdir more mv nc pwd rm\
	sh sleep strings sync tee true uname wc yes\
	md5sum rmdsum rc6crypt\
	execve report

LINKS = arch cpuspeed domainname false rmdir regs sln

ifdef LINUX

FILES += chvt dmesg df eject ls lsmod mount ps reboot softdog swapon tty update\
	 window leaves fire256

LINKS += ccd deallocvt halt poweroff swapoff umount rmmod 

endif

all:	$(FILES) links

links:	$(FILES)
	@( mkln() { [ ! -e $$2 ] && [ -x $$1 ] && $(LN) $$1 $$2; };\
	mkln hostname domainname;\
	mkln ln sln;\
	mkln mkdir rmdir;\
	mkln true false;\
	mkln uname arch;\
	mkln cpuinfo cpuspeed;\
	mkln swapon swapoff;\
	mkln chvt deallocvt;\
	mkln eject ccd;\
	mkln mount umount;\
	mkln reboot halt;\
	mkln reboot poweroff;\
	mkln lsmod rmmod;\
	mkln execve regs;\
	)

install:$(FILES)
	$(MKDIR) ../bin/$(OS)-$(KERNEL)
	$(CP) $(FILES) $(LINKS) ../bin/$(OS)-$(KERNEL)

clean:
	$(RM) *.o $(FILES) $(LINKS)
