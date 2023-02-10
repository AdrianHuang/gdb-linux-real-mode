#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include<linux/kthread.h>
#include<linux/sched.h>
#include<linux/delay.h>

#define NUM_THREADS	2

static struct task_struct threads[NUM_THREADS];

static DEFINE_MUTEX(test_mutex);

int lock_thread(void *idx)
{
 	while (!kthread_should_stop()) {
		mutex_lock(&test_mutex);
		printk(KERN_INFO "%s gets a mutex\n", current->comm);
		
    		msleep(3000);

		mutex_unlock(&test_mutex);
		printk(KERN_INFO "%s unlocks a mutex\n", current->comm);

		break;
  	}

	printk(KERN_INFO "%s stopped\n", current->comm);
	return 0;
}

int unlock_thread(void *idx)
{
 	while (!kthread_should_stop()) {
    		msleep(1000);
		mutex_unlock(&test_mutex);
		printk(KERN_INFO "%s unlocks a mutex\n", current->comm);
		break;
  	}

	printk(KERN_INFO "%s stopped\n", current->comm);
	return 0;
}

int init_thread(struct task_struct *kth, int idx, int (*fn)(void *))
{
	char th_name[20];

	sprintf(th_name, "kthread_%d", idx);

	kth = kthread_create(fn, &idx, (const char * ) th_name);

	if (kth != NULL) {
		wake_up_process(kth);
		printk(KERN_INFO "%s is running\n", th_name);
	} else {
		printk(KERN_INFO "kthread %s could not be created\n", th_name);
		return -1;
	}

	return 0;
}

int init_module(void) 
{ 
	printk(KERN_INFO "Initializing thread module\n");

	if (init_thread(&threads[0], 0, lock_thread) == -1)
		return -1;

	if (init_thread(&threads[1], 1, unlock_thread) == -1)
		return -1;

	printk(KERN_INFO "all of the threads are running\n");
 
	return 0; 
} 
 
void cleanup_module(void) 
{ 
	int i = 0;
	int ret = 0;

	printk(KERN_INFO "exiting thread module\n");

	for (i = 0; i < NUM_THREADS; i++) {
		ret = kthread_stop(&threads[i]);
		if (!ret)
			printk("can't stop thread %d", i);
	}

	printk(KERN_INFO "stopped all of the threads\n");
	return ; 
} 
 
MODULE_LICENSE("GPL");
