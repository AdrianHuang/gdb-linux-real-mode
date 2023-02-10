obj-m += mutex.o 
 
MODULES=../../out/obj/linux/

PWD := $(CURDIR) 
 
all: 
	make -C $(MODULES) M=$(PWD) modules 
 
clean: 
	make -C $(MODULES) M=$(PWD) clean
