# Copyright (C) 1999-2002 Konstantin Boldyshev <konst@linuxassembly.org>
#
# Makefile for asmutils (GNU make is required)
#
# $Id: Makefile,v 1.36 2002/01/17 08:16:24 konst Exp $

#DEBUG = y

BUILD_SRC = y

include ../MCONFIG

FILES = basename cat chmod chroot chown cpuinfo cut date dc dd dirname\
	echo env extname factor fromdos grep head hexdump hostname\
	id init kill ln lzss mkdir mknod nice nohup od rot13 paste\
	readelf readlink reboot renice sh sleep strings sync\
	tail tar tee tr true uname wc whoami yes\
	md5sum rmdsum rc6crypt\

FILES += clear cp httpd m_inetd less ls more mount mv nc ping pop3 pwd\
	 readkey rm scan test touch watch which write

LINKS = arch cpuspeed domainname false mkfifo rmdir sln todos umount\
	halt poweroff\
	regs

BONUS =	execve report asmutils

ifdef LINUX
FILES += chvt dmesg df eject fdisk finger ifconfig killall lsmod mesg ps\
	 softdog swapon tty update
LINKS += ccd deallocvt killall5 pidof rmmod route swapoff 
BONUS += window leaves fire256 snake game
endif

ifdef FREEBSD
FILES += kldload
LINKS += kldunload kldstat
endif

all:	check $(FILES) $(BONUS) links

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
	mkln kldload kldunload;\
	mkln kldload kldstat;\
	mkln killall killall5;\
	mkln killall pidof;\
	)

install:$(FILES)
	$(MKDIR) $(INSTALLDIR)
	$(CP) $(FILES) $(LINKS) $(INSTALLDIR)

clean:
	$(RM) *.o $(FILES) $(BONUS) $(LINKS)

check:
ifneq ("$(ASVER)", "$(CORRECT_ASVER)")
	@echo
	@echo "$(AS) $(ASVER) may miscompile asmutils, please use only clean $(AS) $(CORRECT_ASVER)!"
	@echo
	@false
endif
