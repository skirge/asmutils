# Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
#
# Makefile for asmutils
#
# $Id: Makefile,v 1.3 2000/02/10 15:07:04 konst Exp $

#---------------------------------------------------------------------------#

#			CONFIGURATION PARAMETERS

#---------------------------------------------------------------------------#

# Operating system (LINUX/FREEBSD)

OS = LINUX

# Optimization method (SIZE / SPEED)

OPTIMIZE = SIZE

# Kernel version (LINUX only: 20/22)

KERNEL = 22

# ELF hack for smaller binaries (LINUX only)

ELF_MACROS = y

# Include version stamp into binaries

#STAMP = y

#---------------------------------------------------------------------------#

#			DO NOT EDIT BELOW

#---------------------------------------------------------------------------#

AS = nasm
LN = ln -s
LDFLAGS = -s
ASFLAGS = -D__$(OS)__ -D__OPTIMIZE__=__O_$(OPTIMIZE)__

FILES = basename cat echo mkdir pwd\
	sleep sync true uname yes\
	factor ln more md5sum lzss rmdsum strings id wc\
	chmod chroot grep rc6crypt\
#	dumpcore regs execve

LINKS = false rmdir

${OS} = y

ifdef LINUX

FILES += dmesg df ls lsmod eject hostname mount\
	 rmmod chvt reboot softdog swapon ps update\
	 window leaves \
	 kill nc httpd tee

LINKS += arch deallocvt domainname halt poweroff swapoff umount

else

ELF_MACROS =
KERNEL = 22

endif

ifdef KERNEL
ASFLAGS += -D__KERNEL__=$(KERNEL) 
endif
ifdef STAMP
ASFLAGS += -DSTAMP_VERSION="'asmutils 0.07'" -DSTAMP_DATE="'$(shell date "+%d-%b-%Y %H:%M")'"
endif


ifdef ELF_MACROS

ASFLAGS += -D__ELF_MACROS__ -f bin

%:	%.asm
	$(AS) $(ASFLAGS) $<
	chmod +x $*

else

ASFLAGS += -f elf

%.o:	%.asm
	$(AS) $(ASFLAGS) $<

%:	%.o
	$(LD) $(LDFLAGS) -o $* $<
	strip --remove-section .note --remove-section .comment $*
#	sstrip $*

endif

all:	$(FILES) links

links:
	@( \
	mkln() {\
	[ ! -e $$2 ] && [ -x $$1 ] && $(LN) $$1 $$2;\
	};\
	\
	mkln chvt deallocvt;\
	mkln hostname domainname;\
	mkln mount umount;\
	mkln reboot halt;\
	mkln reboot poweroff;\
	mkln mkdir rmdir;\
	mkln swapon swapoff;\
	mkln true false;\
	mkln uname arch;\
	)

clean:
	rm -f *.o $(FILES) $(LINKS)
