# Copyright (C) 1999-2001 Konstantin Boldyshev <konst@linuxassembly.org>
#
# Makefile for asmutils (GNU make is required)
#
# $Id: Makefile,v 1.16 2001/08/20 15:22:03 konst Exp $

#DEBUG = y

BUILD_SRC = y

include ../MCONFIG

FILES = basename cat chmod chroot chown cp cpuinfo date dc dd dirname echo env\
	extname	factor fromdos grep head hexdump hostname httpd id init kill\
	ln ls lzss mkdir mknod more mv nc od paste ping pwd\
	readelf readkey	readlink renice rm\
	sh sleep strings sync tail tee touch true uname wc which whoami yes\
	md5sum rmdsum rc6crypt\

BONUS =	execve report asmutils

LINKS = arch cpuspeed domainname false mkfifo rmdir regs sln todos

ifdef LINUX

FILES += chvt dmesg df eject lsmod mount ps reboot softdog swapon tty update

BONUS += window leaves fire256 snake

LINKS += ccd deallocvt halt poweroff swapoff umount rmmod 

endif

all:	$(FILES) $(BONUS) links

links:	$(FILES)
	-@( mkln() { [ ! -e $$2 ] && [ -x $$1 ] && $(LN) $$1 $$2; };\
	mkln hostname domainname;\
	mkln ln sln;\
	mkln mkdir rmdir;\
	mkln mknod mkfifo;\
	mkln true false;\
	mkln uname arch;\
	mkln cpuinfo cpuspeed;\
	mkln fromdos todos;\
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
	$(RM) *.o $(FILES) $(BONUS) $(LINKS)
