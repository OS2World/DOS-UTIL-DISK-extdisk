EXTDISK - a utility to display the existence of BIOS INT 13H extension support
==============================================================================

Overview
--------
I think the title says it all, really. But still....

The standard BIOS interface to fixed disks uses an addressing scheme
that uses cylinder, head and sector numbers to indicate the required
sector.  This scheme was developed in the early 1980s, and the sizes of
the fields allocated for specifying C/H/S mean that the sceheme maxes
out at aroung 8GB. 

Since most operating systems require initial access to the disk via the
BIOS, this means that at least part of the operating system must reside
below the 8GB 'line' on the disk.  Specifically, the OS/2 Boot Manager
uses the BIOS at all times; so does the OS/2 Master Boot Record, which
loads the boot sector from the active partition.  This is not always
convenient. 

A few years ago, an alternate addressing scheme was developed, using an
absolute sector number; this is often called the Logical Block Address
(LBA) method.  It is supported by extensions to the BIOS disk access
interface, commonly know as the INT 13H extensions. 

After all that....the purpose of the EXTDISK utility is to tell you
whether your BIOS supports the extensions.  This is better than trying
to work it out by seeing how the system behaves!

Use
---
To use the program, boot to a plain DOS prompt to ensure that you are
using the real BIOS and not some emulation.  Use a boot diskette if
necessary.  Simply run the program:

     A>EXTDISK

and it will tell you the answer!

Contact
-------
EXTDISK was written by me, Bob Eager.  I can be contacted at
rde@tavi.co.uk, and new versions of EXTDISK (if ever necessary) can be
downloaded from:

     http://www.tavi.co.uk.os2pages/

Bob Eager
August 2002

