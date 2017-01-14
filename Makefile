obj-m += lirc_rpi.o

all:
	make -Wall -C /home/path/to/your/raspi-kernel-files/rpf-linux-kernel M=$(PWD) modules

