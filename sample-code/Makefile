PROG = vsyscall t_mmap rdwrmem

CFLAGS = -static

all : ${PROG}

rdwrmem.c:
	test -f $@ || wget https://cmp.felk.cvut.cz/~pisa/linux/rdwrmem.c

clean :
	${RM} ${PROG} *.o
