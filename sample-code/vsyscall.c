#include <stdio.h>
#include <sys/time.h>

/* int gettimeofday(struct timeval *tv, struct timezone *tz); */
typedef int (*time_func)(struct timeval *, struct timezone *);

int main(int argc, char *argv[])
{
	struct timeval tv;
	int retval;

	time_func func = (time_func) 0xffffffffff600000;

	retval = func(&tv, NULL);
	if (retval < 0) {
	    perror("time_func");
	    return -1;
	}

	printf("%ld\n", tv.tv_sec);

	return 0;
}

