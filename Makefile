obj-m += lirc_rpi.o

all:
	make -Wall -C /home/christ/KeinBackup/raspberrypi/rpf-linux-kernel M=$(PWD) modules

