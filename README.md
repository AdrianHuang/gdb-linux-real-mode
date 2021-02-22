# gdb-linux-real-mode
Debug the real-mode setup code of Linux Kernel.

## Note
* Environment: Tested on Ubuntu 20.04.1

* Required package
```shell
$ sudo apt-get install qemu-system-x86
```

## Steps
* Run the script `scripts/build.sh`. This automatically builds Linux kernel (v5.11) and root filesystem (busybox).
```shell
$ ./scripts/build.sh
```

* Launch a guest OS. This script pauses the OS launch and waits for remote debug via gdb. (Note: If you want to shutdown the guest OS, please press the key combination `ctrl+a x`).
```shell
$ ./scripts/launch-vm.sh
```

* Open another terminal and execute the script `scripts/launch-gdb.sh`. This sets a breakpoint at the label `start_of_setup (arch/x86/boot/header.S)` and continues to run the guest OS. The code will be paused at the starting address of start_of_setup. You can use gdb commands to debug the real-mode setup code of Linux kernel. Enjoy debugging.
```
$ ./scripts/launch-gdb.sh
# debug real-mode code of Linux kernel
add-symbol-file /home/adrian/git-repo/gdb-linux-real-mode/out/obj/linux/arch/x86/boot/setup.elf 0x103ff \
        -s .bstext 0x10000 \
        -s .bsdata 0x1002d \
        -s .header 0x101ef \
        -s .entrytext 0x1026c
target remote :1234
#b start_of_setup
b *0x10200
c
GNU gdb (Ubuntu 9.2-0ubuntu1~20.04) 9.2
Copyright (C) 2020 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word".

warning: A handler for the OS ABI "GNU/Linux" is not built into this configuration
of GDB.  Attempting to continue with the default i8086 settings.

The target architecture is assumed to be i8086
add symbol table from file "/home/adrian/git-repo/gdb-linux-real-mode/out/obj/linux/arch/x86/boot/setup.elf" at
        .text_addr = 0x103ff
        .bstext_addr = 0x10000
        .bsdata_addr = 0x1002d
        .header_addr = 0x101ef
        .entrytext_addr = 0x1026c

warning: No executable has been specified and target does not support
determining executable automatically.  Try using the "file" command.
---------------------------[ STACK ]---
0000 0000 0000 0000 0000 0000 0000 0000
0000 0000 0000 0000 0000 0000 0000 0000
---------------------------[ DS:SI ]---
00000000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000020: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000030: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
---------------------------[ ES:DI ]---
00000000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000020: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000030: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
----------------------------[ CPU ]----
AX: 0000 BX: 0000 CX: 0000 DX: 0663
SI: 0000 DI: 0000 SP: 0000 BP: 0000
CS: F000 DS: 0000 ES: 0000 SS: 0000

IP: FFF0 EIP:0000FFF0
CS:IP: F000:FFF0 (0xFFFF0)
SS:SP: 0000:0000 (0x00000)
SS:BP: 0000:0000 (0x00000)
OF <0>  DF <0>  IF <0>  TF <0>  SF <0>  ZF <0>  AF <0>  PF <0>  CF <0>
ID <0>  VIP <0> VIF <0> AC <0>  VM <0>  RF <0>  NT <0>  IOPL <0>
---------------------------[ CODE ]----
   0xffff0:     jmp    0x3630:0xf000e05b
   0xffff7:     das
   0xffff8:     xor    dh,BYTE PTR [ebx]
   0xffffa:     das
   0xffffb:     cmp    DWORD PTR [ecx],edi
   0xffffd:     add    ah,bh
   0xfffff:     add    BYTE PTR [eax],al
   0x100001:    add    BYTE PTR [eax],al
   0x100003:    add    BYTE PTR [eax],al
   0x100005:    add    BYTE PTR [eax],al
0x0000fff0 in ?? ()
Breakpoint 1 at 0x10200

Thread 1 received signal SIGTRAP, Trace/breakpoint trap.
---------------------------[ STACK ]---
0000 0000 0000 0000 0000 0000 0000 0000
6165 6C72 7079 6972 746E 3D6B 6573 6972
---------------------------[ DS:SI ]---
10000000: EA 05 00 C0 07 8C C8 8E D8 8E C0 8E D0 31 E4 FB  .............1..
10000010: FC BE 2D 00 AC 20 C0 74 09 B4 0E BB 07 00 CD 10  ..-....t........
10000020: EB F2 31 C0 CD 16 CD 19 EA F0 FF 00 F0 55 73 65  ..1..........Use
10000030: 20 61 20 62 6F 6F 74 20 6C 6F 61 64 65 72 2E 0D  .a.boot.loader..
---------------------------[ ES:DI ]---
10000000: EA 05 00 C0 07 8C C8 8E D8 8E C0 8E D0 31 E4 FB  .............1..
10000010: FC BE 2D 00 AC 20 C0 74 09 B4 0E BB 07 00 CD 10  ..-....t........
10000020: EB F2 31 C0 CD 16 CD 19 EA F0 FF 00 F0 55 73 65  ..1..........Use
10000030: 20 61 20 62 6F 6F 74 20 6C 6F 61 64 65 72 2E 0D  .a.boot.loader..
----------------------------[ CPU ]----
AX: 1020 BX: 0000 CX: 0000 DX: 0000
SI: 0000 DI: 0000 SP: FFF0 BP: 0000
CS: 1020 DS: 1000 ES: 1000 SS: 1000

IP: 0000 EIP:00000000
CS:IP: 1020:0000 (0x10200)
SS:SP: 1000:FFF0 (0x1FFF0)
SS:BP: 1000:0000 (0x10000)
OF <0>  DF <0>  IF <0>  TF <0>  SF <0>  ZF <1>  AF <0>  PF <1>  CF <0>
ID <0>  VIP <0> VIF <0> AC <0>  VM <0>  RF <0>  NT <0>  IOPL <0>
---------------------------[ CODE ]----
   0x10200:	jmp    0x1026c <start_of_setup>
   0x10202:	dec    %eax
   0x10203:	fs jb  0x10259
   0x10206:	lar    (%eax),%eax
   0x10209:	add    %al,(%eax)
   0x1020b:	add    %al,(%eax)
   0x1020d:	adc    %ah,0x33(%eax)
   0x10210:	mov    $0x81,%al
   0x10212:	add    %al,0x100000(%eax)
   0x10218:	add    %dl,(%eax)
0x00000000 in ?? ()
real-mode-gdb$ si
---------------------------[ STACK ]---
0000 0000 0000 0000 0000 0000 0000 0000
6165 6C72 7079 6972 746E 3D6B 6573 6972
---------------------------[ DS:SI ]---
10000000: EA 05 00 C0 07 8C C8 8E D8 8E C0 8E D0 31 E4 FB  .............1..
10000010: FC BE 2D 00 AC 20 C0 74 09 B4 0E BB 07 00 CD 10  ..-....t........
10000020: EB F2 31 C0 CD 16 CD 19 EA F0 FF 00 F0 55 73 65  ..1..........Use
10000030: 20 61 20 62 6F 6F 74 20 6C 6F 61 64 65 72 2E 0D  .a.boot.loader..
---------------------------[ ES:DI ]---
10000000: EA 05 00 C0 07 8C C8 8E D8 8E C0 8E D0 31 E4 FB  .............1..
10000010: FC BE 2D 00 AC 20 C0 74 09 B4 0E BB 07 00 CD 10  ..-....t........
10000020: EB F2 31 C0 CD 16 CD 19 EA F0 FF 00 F0 55 73 65  ..1..........Use
10000030: 20 61 20 62 6F 6F 74 20 6C 6F 61 64 65 72 2E 0D  .a.boot.loader..
----------------------------[ CPU ]----
AX: 1020 BX: 0000 CX: 0000 DX: 0000
SI: 0000 DI: 0000 SP: FFF0 BP: 0000
CS: 1020 DS: 1000 ES: 1000 SS: 1000

IP: 006C EIP:0000006C
CS:IP: 1020:006C (0x1026C)
SS:SP: 1000:FFF0 (0x1FFF0)
SS:BP: 1000:0000 (0x10000)
OF <0>  DF <0>  IF <0>  TF <0>  SF <0>  ZF <1>  AF <0>  PF <1>  CF <0>
ID <0>  VIP <0> VIF <0> AC <0>  VM <0>  RF <0>  NT <0>  IOPL <0>
---------------------------[ CODE ]----
   0x1026c <start_of_setup>:	mov    %ds,%eax
   0x1026e <start_of_setup+2>:	mov    %eax,%es
   0x10270 <start_of_setup+4>:	cld
   0x10271 <start_of_setup+5>:	mov    %ss,%edx
   0x10273 <start_of_setup+7>:	cmp    %eax,%edx
   0x10275 <start_of_setup+9>:	mov    %esp,%edx
   0x10277 <start_of_setup+11>:	je     0x1028f <start_of_setup+35>
   0x10279 <start_of_setup+13>:	mov    $0x6f64a10,%edx
   0x1027e <start_of_setup+18>:	adc    %eax,(%edx)
   0x10280 <start_of_setup+20>:	xorb   $0x16,-0x75(%esp,%eax,1)
0x0000006c in ?? ()
real-mode-gdb$ si
---------------------------[ STACK ]---
0000 0000 0000 0000 0000 0000 0000 0000
6165 6C72 7079 6972 746E 3D6B 6573 6972
---------------------------[ DS:SI ]---
10000000: EA 05 00 C0 07 8C C8 8E D8 8E C0 8E D0 31 E4 FB  .............1..
10000010: FC BE 2D 00 AC 20 C0 74 09 B4 0E BB 07 00 CD 10  ..-....t........
10000020: EB F2 31 C0 CD 16 CD 19 EA F0 FF 00 F0 55 73 65  ..1..........Use
10000030: 20 61 20 62 6F 6F 74 20 6C 6F 61 64 65 72 2E 0D  .a.boot.loader..
---------------------------[ ES:DI ]---
10000000: EA 05 00 C0 07 8C C8 8E D8 8E C0 8E D0 31 E4 FB  .............1..
10000010: FC BE 2D 00 AC 20 C0 74 09 B4 0E BB 07 00 CD 10  ..-....t........
10000020: EB F2 31 C0 CD 16 CD 19 EA F0 FF 00 F0 55 73 65  ..1..........Use
10000030: 20 61 20 62 6F 6F 74 20 6C 6F 61 64 65 72 2E 0D  .a.boot.loader..
----------------------------[ CPU ]----
AX: 1000 BX: 0000 CX: 0000 DX: 0000
SI: 0000 DI: 0000 SP: FFF0 BP: 0000
CS: 1020 DS: 1000 ES: 1000 SS: 1000

IP: 006E EIP:0000006E
CS:IP: 1020:006E (0x1026E)
SS:SP: 1000:FFF0 (0x1FFF0)
SS:BP: 1000:0000 (0x10000)
OF <0>  DF <0>  IF <0>  TF <0>  SF <0>  ZF <1>  AF <0>  PF <1>  CF <0>
ID <0>  VIP <0> VIF <0> AC <0>  VM <0>  RF <0>  NT <0>  IOPL <0>
---------------------------[ CODE ]----
   0x1026e <start_of_setup+2>:	mov    %eax,%es
   0x10270 <start_of_setup+4>:	cld
   0x10271 <start_of_setup+5>:	mov    %ss,%edx
   0x10273 <start_of_setup+7>:	cmp    %eax,%edx
   0x10275 <start_of_setup+9>:	mov    %esp,%edx
   0x10277 <start_of_setup+11>:	je     0x1028f <start_of_setup+35>
   0x10279 <start_of_setup+13>:	mov    $0x6f64a10,%edx
   0x1027e <start_of_setup+18>:	adc    %eax,(%edx)
   0x10280 <start_of_setup+20>:	xorb   $0x16,-0x75(%esp,%eax,1)
   0x10285 <start_of_setup+25>:	and    $0x2,%al
0x0000006e in ?? ()
real-mode-gdb$
```
## References
* [How to disassemble 16-bit x86 boot sector code in GDB with “x/i $pc”? It gets treated as 32-bit](https://stackoverflow.com/questions/32955887/how-to-disassemble-16-bit-x86-boot-sector-code-in-gdb-with-x-i-pc-it-gets-tr)
* [gdbinit_real_mode.txt](https://github.com/mhugo/gdb_init_real_mode/blob/master/gdbinit_real_mode.txt)
