# Copyright (C) 1999-2000 Konstantin Boldyshev <konst@voshod.com>
#
# Makefile for asmutils
#
# $Id: Makefile,v 1.2 2000/02/01 19:56:20 konst Exp $


#
# Enable this line if you want smaller binaries
#

__ELF_MACROS = y

#
# Do not edit anything further
#

FILES = basename cat dmesg echo hostname httpd kill lsmod mkdir mount pwd \
	reboot rmmod sleep softdog swapon sync tee true uname update yes \
	factor eject chvt df ln more md5sum lzss rmdsum ls strings id wc ps \
	chmod chroot grep rc6crypt nc window leaves \
#	dumpcore regs execve

LINKS = arch deallocvt domainname false halt poweroff rmdir swapoff umount

AS = nasm
ASFLAGS = -f elf
LDFLAGS = -s
LN = ln -s

ifdef __ELF_MACROS
ASFLAGS = -f bin -D__ELF_MACROS
endif

ifdef __ELF_MACROS

%:	%.asm

	$(AS) $(ASFLAGS) $<
	chmod +x $*

else

%.o:	%.asm
	$(AS) $(ASFLAGS) $<

%:	%.o
	$(LD) $(LDFLAGS) -o $* $<
	strip --remove-section .note --remove-section .comment $*
#	sstrip $*

endif

all:	$(FILES) links

links:
	$(LN) chvt deallocvt
	$(LN) hostname domainname
	$(LN) mount umount
	$(LN) reboot halt
	$(LN) reboot poweroff
	$(LN) mkdir rmdir
	$(LN) swapon swapoff
	$(LN) true false
	$(LN) uname arch

clean:
	rm -f *.o $(FILES) $(LINKS)
