# Copyright (C) 1999-2001 Konstantin Boldyshev <konst@linuxassembly.org>
#
# Makefile for asmutils (GNU make is required)
#
# $Id: Makefile,v 1.27 2001/11/20 15:31:52 konst Exp $

#DEBUG = y

BUILD_SRC = y

include ../MCONFIG

FILES = basename cat chmod chroot chown cpuinfo cut date dc dd dirname\
	echo env extname factor fromdos grep head hexdump hostname\
	id init kill ln lzss mkdir mknod od rot13 paste\
	readelf readlink renice	sh sleep strings sync tail tar tee tr true\
	uname wc whoami yes\
	md5sum rmdsum rc6crypt\

FILES += clear cp httpd m_inetd less ls more mv nc readkey rm ping pwd touch\
	 watch which write

BONUS =	execve report asmutils

LINKS = arch cpuspeed domainname false mkfifo rmdir regs sln todos

ifdef LINUX
FILES += chvt dmesg df eject ifconfig lsmod mesg mount ps\
	 reboot softdog swapon tty update
BONUS += window leaves fire256 snake game
LINKS += ccd deallocvt halt poweroff swapoff umount rmmod route
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
	mkln ifconfig route;\
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
