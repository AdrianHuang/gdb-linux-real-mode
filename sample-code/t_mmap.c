/*
 * Code reference from Listing 49-2 of The Linux Programming
 * Interface (TLPI) book with some minor changes.
 */
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	char *addr;
	int fd;

	if (argc < 2 || strcmp(argv[1], "--help") == 0) {
		printf("%s file\n", argv[0]);
		return -1;
	}

	fd = open(argv[1], O_RDWR);
	addr = mmap(NULL, 16, PROT_READ | PROT_WRITE,
			MAP_PRIVATE, fd, 0);

	printf("Current string=%.*s (%p)\n", 16, addr, addr);
	strncpy(addr, "Lenovo", 6);

	printf("Press any key to continue...\n");
	getchar();

	munmap(addr, 16);
	close(fd);

	return 0;
}
