# Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
#
# Makefile for asmutils
#
# $Id: Makefile,v 1.5 2000/04/07 18:36:01 konst Exp $

#---------------------------------------------------------------------------#

#			CONFIGURATION PARAMETERS

#---------------------------------------------------------------------------#

# Operating system (LINUX/FREEBSD/BEOS/LIBC)

OS = LINUX

# Optimization method (SIZE/SPEED)

OPTIMIZE = SIZE

# Include version stamp into binaries

#STAMP = y

# LINUX only
#
# Kernel version (20/22)
KERNEL = 22
# ELF hack for smaller binaries
ELF_MACROS = y

# LIBC only
#
# Use custom startup code (currently works only with C style main() stack)
# Use only with LIBC and only if utils fail without it (f.e. on BeOS)
#STARTUP = y

#---------------------------------------------------------------------------#

#			DO NOT EDIT BELOW

#---------------------------------------------------------------------------#

AS = nasm
LD = ld
LN = ln -s
LDFLAGS = -s
ASFLAGS = -D__$(OS)__ -D__OPTIMIZE__=__O_$(OPTIMIZE)__

FILES = basename cat echo mkdir kill pwd sleep sync tee true uname yes\
	factor ln more md5sum lzss rmdsum strings id wc httpd\
	chmod chroot grep rc6crypt sln env dirname extname cpuinfo cpuspeed\
#	dumpcore regs execve

LINKS = false rmdir

${OS} = y

ifdef LINUX

FILES += dmesg df ls lsmod eject hostname mount\
	 rmmod chvt reboot softdog swapon ps update\
	 nc tty\
	 window leaves

LINKS += arch ccd deallocvt domainname halt poweroff swapoff umount

else

ELF_MACROS =
KERNEL = 22

endif

ifdef LIBC
ELF_MACROS =
LD = gcc
ASFLAGS += -D__LIBC__
ifndef STARTUP
LDFLAGS = -nostartfiles
endif
endif

ifdef STARTUP
ASFLAGS += -D__STARTUP__
endif

ifdef KERNEL
ASFLAGS += -D__KERNEL__=$(KERNEL) 
endif
ifdef STAMP
ASFLAGS += -DSTAMP_VERSION="'asmutils 0.09'" -DSTAMP_DATE="'$(shell date "+%d-%b-%Y %H:%M")'"
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
	mkln eject ccd;\
	)

install:
	mkdir -p ../bin/$(OS)-$(KERNEL)
	cp -rd $(FILES) $(LINKS) ../bin/$(OS)-$(KERNEL)

clean:
	rm -f *.o $(FILES) $(LINKS)
