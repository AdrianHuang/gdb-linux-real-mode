# gdb-linux-real-mode
Debug the real-mode setup code and protected mode of Linux Kernel.

## Note
* Environment: Tested on Ubuntu 20.04.1

* Required packages
```shell
$ sudo apt-get install make curl gcc bison flex gdb qemu-system-x86
```

* [RHEL 8.X]: You need to install package 'glibc-static' when building busybox.

## Steps
* Run the script `scripts/build.sh`. This automatically builds Linux kernel (v5.11) and root filesystem (busybox).
```shell
$ ./scripts/build.sh
```

* Launch a guest OS. This script pauses the OS launch and waits for remote debug via gdb. (Note: If you want to shutdown the guest OS, please press the key combination `ctrl+a x`).
```shell
$ ./scripts/launch-vm.sh
```

* Open another terminal and execute the script `scripts/launch-gdb.sh`.
```
$ ./scripts/launch-gdb.sh
```

### Case 1: Debug real mode

* Open one terminal and execute the following command (This script pauses the OS launch and waits for remote debug via gdb).
```shell
$ ./scripts/launch-vm.sh
```

* Open another terminal and execute the script `scripts/launch-gdb.sh`. This sets a breakpoint at the label `start_of_setup (arch/x86/boot/header.S)` and continues to run the guest OS. The code will be paused at the starting address of start_of_setup. You can use gdb commands to debug the real-mode setup code of Linux kernel. Enjoy debugging.
  * The script sets a breakpoint at 0x10200, which is real mode entry code of Linux kernel.
  * Execute gdb command `si` to step one instruction.
```shell
$ ./scripts/launch-gdb.sh
# debug real-mode code of Linux kernel
add-symbol-file /home/adrian/git-repo/gdb-linux-real-mode/out/obj/linux/arch/x86/boot/setup.elf 0x103ff -s .bstext 0x10000 -s .bsdata 0x1002d -s .header 0x101ef -s .entrytext 0x1026c -s .inittext 0x102d4 -s .initdata 0x103e1 -s .text32 0x130cc -s .bss 0x136e0 -s .data 0x13660
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
add symbol table from file "/home/adrian/git-repo/gdb-linux-real-mode/out/obj/linux/arch/x86/boot/setup.elf" at
	.text_addr = 0x103ff
	.bstext_addr = 0x10000
	.bsdata_addr = 0x1002d
	.header_addr = 0x101ef
	.entrytext_addr = 0x1026c
	.inittext_addr = 0x102d4
	.initdata_addr = 0x103e1
	.text32_addr = 0x130cc
	.bss_addr = 0x136e0
	.data_addr = 0x13660

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

IP: FFF0 RIP:0000FFF0
CS:IP: F000:FFF0 (0xFFFF0)
SS:SP: 0000:0000 (0x00000)
SS:BP: 0000:0000 (0x00000)
OF <0>  DF <0>  IF <0>  TF <0>  SF <0>  ZF <0>  AF <0>  PF <0>  CF <0>
ID <0>  VIP <0> VIF <0> AC <0>  VM <0>  RF <0>  NT <0>  IOPL <0>
---------------------------[ CODE ]----
   0xffff0:	(bad)
   0xffff1:	pop    %rbx
   0xffff2:	loopne 0xffff4
   0xffff4:	lock xor %dh,(%rsi)
   0xffff7:	(bad)
   0xffff8:	xor    (%rbx),%dh
   0xffffa:	(bad)
   0xffffb:	cmp    %edi,(%rcx)
   0xffffd:	add    %bh,%ah
   0xfffff:	add    %al,(%rax)
0x000000000000fff0 in ?? ()
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

IP: 0000 RIP:00000000
CS:IP: 1020:0000 (0x10200)
SS:SP: 1000:FFF0 (0x1FFF0)
SS:BP: 1000:0000 (0x10000)
OF <0>  DF <0>  IF <0>  TF <0>  SF <0>  ZF <1>  AF <0>  PF <1>  CF <0>
ID <0>  VIP <0> VIF <0> AC <0>  VM <0>  RF <0>  NT <0>  IOPL <0>
---------------------------[ CODE ]----
   0x10200:	jmp    0x1026c <start_of_setup>
   0x10202:	rex.W
   0x10203:	fs jb  0x10259
   0x10206:	lar    (%rax),%eax
   0x10209:	add    %al,(%rax)
   0x1020b:	add    %al,(%rax)
   0x1020d:	adc    %ah,0x33(%rax)
   0x10210:	mov    $0x81,%al
   0x10212:	add    %al,0x100000(%rax)
   0x10218:	add    %dl,(%rax)
0x0000000000000000 in ?? ()
(gdb) si
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

IP: 006C RIP:0000006C
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
   0x1027e <start_of_setup+18>:	adc    %eax,(%rdx)
   0x10280 <start_of_setup+20>:	xorb   $0x16,-0x75(%rsp,%rax,1)
0x000000000000006c in ?? ()
(gdb) si
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

IP: 006E RIP:0000006E
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
   0x1027e <start_of_setup+18>:	adc    %eax,(%rdx)
   0x10280 <start_of_setup+20>:	xorb   $0x16,-0x75(%rsp,%rax,1)
   0x10285 <start_of_setup+25>:	and    $0x2,%al
0x000000000000006e in ?? ()
```

### Case 2: Debug the mode transition from real mode to protected mode

* Open one terminal and execute the following command (This script pauses the OS launch and waits for remote debug via gdb).
```shell
$ ./scripts/launch-vm.sh
```

* Open another terminal and execute the script `scripts/launch-gdb.sh`.
  * The script sets a breakpoint at 0x10200, which is real mode entry code of Linux kernel.
  * Manually execute gdb command `b *0x113c9` to add a new breakpoint at 0x113c9
. The address is the instruction for enabling PE bit of CR0 `0x113c9 <protected_mode_jump+31>: mov %rdx, %cr0`.
  * Execute gdb command `info b`, `si`, and `c`.
  * Execute gdb command `info registers cr0` to check if PE bit is set.
```shell
$ ./scripts/launch-gdb.sh
# debug real-mode code of Linux kernel
add-symbol-file /home/adrian/git-repo/gdb-linux-real-mode/out/obj/linux/arch/x86/boot/setup.elf 0x103ff -s .bstext 0x10000 -s .bsdata 0x1002d -s .header 0x101ef -s .entrytext 0x1026c -s .inittext 0x102d4 -s .initdata 0x103e1 -s .text32 0x130cc -s .bss 0x136e0 -s .data 0x13660
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
add symbol table from file "/home/adrian/git-repo/gdb-linux-real-mode/out/obj/linux/arch/x86/boot/setup.elf" at
	.text_addr = 0x103ff
	.bstext_addr = 0x10000
	.bsdata_addr = 0x1002d
	.header_addr = 0x101ef
	.entrytext_addr = 0x1026c
	.inittext_addr = 0x102d4
	.initdata_addr = 0x103e1
	.text32_addr = 0x130cc
	.bss_addr = 0x136e0
	.data_addr = 0x13660

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

IP: FFF0 RIP:0000FFF0
CS:IP: F000:FFF0 (0xFFFF0)
SS:SP: 0000:0000 (0x00000)
SS:BP: 0000:0000 (0x00000)
----------------------------[ CPU Control Register]----
cr0            0x60000010          [ CD NW ET ]
----------------------------[ eflags]----
OF <0>  DF <0>  IF <0>  TF <0>  SF <0>  ZF <0>  AF <0>  PF <0>  CF <0>
ID <0>  VIP <0> VIF <0> AC <0>  VM <0>  RF <0>  NT <0>  IOPL <0>
---------------------------[ CODE ]----
   0xffff0:	(bad)
   0xffff1:	pop    %rbx
   0xffff2:	loopne 0xffff4
   0xffff4:	lock xor %dh,(%rsi)
   0xffff7:	(bad)
   0xffff8:	xor    (%rbx),%dh
   0xffffa:	(bad)
   0xffffb:	cmp    %edi,(%rcx)
   0xffffd:	add    %bh,%ah
   0xfffff:	add    %al,(%rax)
0x000000000000fff0 in ?? ()
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

IP: 0000 RIP:00000000
CS:IP: 1020:0000 (0x10200)
SS:SP: 1000:FFF0 (0x1FFF0)
SS:BP: 1000:0000 (0x10000)
----------------------------[ CPU Control Register]----
cr0            0x10                [ ET ]
----------------------------[ eflags]----
OF <0>  DF <0>  IF <0>  TF <0>  SF <0>  ZF <1>  AF <0>  PF <1>  CF <0>
ID <0>  VIP <0> VIF <0> AC <0>  VM <0>  RF <0>  NT <0>  IOPL <0>
---------------------------[ CODE ]----
   0x10200:	jmp    0x1026c <start_of_setup>
   0x10202:	rex.W
   0x10203:	fs jb  0x10259
   0x10206:	lar    (%rax),%eax
   0x10209:	add    %al,(%rax)
   0x1020b:	add    %al,(%rax)
   0x1020d:	adc    %ah,0x33(%rax)
   0x10210:	mov    $0x81,%al
   0x10212:	add    %al,0x100000(%rax)
   0x10218:	add    %dl,(%rax)
0x0000000000000000 in ?? ()
(gdb) info b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000000000010200
(gdb) b *0x113c9
Breakpoint 2 at 0x113c9: file /home/adrian/git-repo/gdb-linux-real-mode/src/linux-5.11/arch/x86/boot/pmjump.S, line 39.
(gdb) info b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000000000010200
2       breakpoint     keep y   0x000113c9         /home/adrian/git-repo/gdb-linux-real-mode/src/linux-5.11/arch/x86/boot/pmjump.S:39
(gdb) si
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

IP: 006C RIP:0000006C
CS:IP: 1020:006C (0x1026C)
SS:SP: 1000:FFF0 (0x1FFF0)
SS:BP: 1000:0000 (0x10000)
----------------------------[ CPU Control Register]----
cr0            0x10                [ ET ]
----------------------------[ eflags]----
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
   0x1027e <start_of_setup+18>:	adc    %eax,(%rdx)
   0x10280 <start_of_setup+20>:	xorb   $0x16,-0x75(%rsp,%rax,1)
0x000000000000006c in ?? ()
(gdb) c
Continuing.

Thread 1 received signal SIGTRAP, Trace/breakpoint trap.
---------------------------[ STACK ]---
13AA 0000 0000 0000 11D8 0000 0000 0000
0000 0000 0000 0000 0000 0000 0000 0000
---------------------------[ DS:SI ]---
100039F0: 00 08 00 FC 00 00 03 50 00 00 03 00 00 00 19 01  .......P........
10003A00: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
10003A10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
10003A20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
---------------------------[ ES:DI ]---
10000020: EB F2 31 C0 CD 16 CD 19 EA F0 FF 00 F0 55 73 65  ..1..........Use
10000030: 20 61 20 62 6F 6F 74 20 6C 6F 61 64 65 72 2E 0D  .a.boot.loader..
10000040: 0A 0A 52 65 6D 6F 76 65 20 64 69 73 6B 20 61 6E  ..Remove.disk.an
10000050: 64 20 70 72 65 73 73 20 61 6E 79 20 6B 65 79 20  d.press.any.key.
----------------------------[ CPU ]----
AX: 0000 BX: 0000 CX: 0018 DX: 0011
SI: 39F0 DI: 0020 SP: FF80 BP: 0000
CS: 1000 DS: 1000 ES: 1000 SS: 1000

IP: 13C9 RIP:000013C9
CS:IP: 1000:13C9 (0x113C9)
SS:SP: 1000:FF80 (0x1FF80)
SS:BP: 1000:0000 (0x10000)
----------------------------[ CPU Control Register]----
cr0            0x10                [ ET ]
----------------------------[ eflags]----
OF <0>  DF <0>  IF <0>  TF <0>  SF <0>  ZF <0>  AF <0>  PF <1>  CF <0>
ID <0>  VIP <0> VIF <0> AC <0>  VM <0>  RF <0>  NT <0>  IOPL <0>
---------------------------[ CODE ]----
   0x113c9 <protected_mode_jump+31>:	mov    %rdx,%cr0
   0x113cc <protected_mode_jump+34>:	data16 (bad)
   0x113ce <protected_mode_jump+36>:	int3
   0x113cf <protected_mode_jump+37>:	xor    %al,(%rcx)
   0x113d1 <protected_mode_jump+39>:	add    %dl,(%rax)
   0x113d3 <protected_mode_jump+41>:	add    %ah,0x55(%rsi)
   0x113d6 <number+2>:	push   %di
   0x113d8 <number+4>:	push   %si
   0x113da <number+6>:	push   %bx
   0x113dc <number+8>:	sub    $0x5c,%sp
0x00000000000013c9 in ?? ()
(gdb) info registers cr0
cr0            0x10                [ ET ]
(gdb) si
---------------------------[ STACK ]---
13AA 0000 0000 0000 11D8 0000 0000 0000
0000 0000 0000 0000 0000 0000 0000 0000
----------------------------[ CPU ]----
rax            0x100000            1048576
rbx            0x10000             65536
rcx            0xf0000018          4026531864
rdx            0x11                17
rsi            0x139f0             80368
rdi            0x20                32
rbp            0x0                 0x0
rsp            0xff80              0xff80
rip            0x13cc              0x13cc
eflags         0x6                 [ IOPL=0 PF ]
cs             0x1000              4096
ss             0x1000              4096
ds             0x1000              4096
es             0x1000              4096
fs             0x0                 0
gs             0xffff              65535
----------------------------[ CPU Control Register]----
cr0            0x11                [ ET PE ]
----------------------------[ eflags]----
OF <0>  DF <0>  IF <0>  TF <0>  SF <0>  ZF <0>  AF <0>  PF <1>  CF <0>
ID <0>  VIP <0> VIF <0> AC <0>  VM <0>  RF <0>  NT <0>  IOPL <0>
---------------------------[ CODE ]----
=> 0x13cc:	add    %al,(%rax)
   0x13ce:	add    %al,(%rax)
   0x13d0:	add    %al,(%rax)
   0x13d2:	add    %al,(%rax)
   0x13d4:	add    %al,(%rax)
   0x13d6:	add    %al,(%rax)
   0x13d8:	add    %al,(%rax)
   0x13da:	add    %al,(%rax)
   0x13dc:	add    %al,(%rax)
   0x13de:	add    %al,(%rax)
0x00000000000013cc in ?? ()
(gdb) si
---------------------------[ STACK ]---
13AA 0000 0000 0000 11D8 0000 0000 0000
0000 0000 0000 0000 0000 0000 0000 0000
----------------------------[ CPU ]----
rax            0x100000            1048576
rbx            0x10000             65536
rcx            0xf0000018          4026531864
rdx            0x11                17
rsi            0x139f0             80368
rdi            0x20                32
rbp            0x0                 0x0
rsp            0xff80              0xff80
rip            0x130cc             0x130cc
eflags         0x6                 [ IOPL=0 PF ]
cs             0x10                16
ss             0x1000              4096
ds             0x1000              4096
es             0x1000              4096
fs             0x0                 0
gs             0xffff              65535
----------------------------[ CPU Control Register]----
cr0            0x11                [ ET PE ]
----------------------------[ eflags]----
OF <0>  DF <0>  IF <0>  TF <0>  SF <0>  ZF <0>  AF <0>  PF <1>  CF <0>
ID <0>  VIP <0> VIF <0> AC <0>  VM <0>  RF <0>  NT <0>  IOPL <0>
---------------------------[ CODE ]----
=> 0x130cc:	mov    %ecx,%ds
   0x130ce:	mov    %ecx,%es
   0x130d0:	mov    %ecx,%fs
   0x130d2:	mov    %ecx,%gs
   0x130d4:	mov    %ecx,%ss
   0x130d6:	add    %ebx,%esp
   0x130d8:	ltr    %di
   0x130db:	xor    %ecx,%ecx
   0x130dd:	xor    %edx,%edx
   0x130df:	xor    %ebx,%ebx
51		movl	%ecx, %ds
(gdb) info registers cr0
cr0            0x11                [ ET PE ]
```

## References
* [How to disassemble 16-bit x86 boot sector code in GDB with “x/i $pc”? It gets treated as 32-bit](https://stackoverflow.com/questions/32955887/how-to-disassemble-16-bit-x86-boot-sector-code-in-gdb-with-x-i-pc-it-gets-tr)
* [gdbinit_real_mode.txt](https://github.com/mhugo/gdb_init_real_mode/blob/master/gdbinit_real_mode.txt)
