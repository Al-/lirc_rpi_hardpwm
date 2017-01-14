# lirc_rpi_hardpwm
lirc_rpi kernel module with added hardware pulse-wave modulation support

 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

I amended lirc_rpi.c (i.e., the source code of the kernel module) to support
hardware pulse wave modulation. The new kernel module has an additional
parameter that can be provided when loading the module: hardpwm. If hardpwm=1
(which is mutually exclusive with softcarrier=1) then hardware pulse-wave
modulation is used. If softcarrier=0 and hardpwm=0, then no modulation is used.
Also no modulation is used if hardpwm=1 but lircd.conf specifies a duty_cycle
of 100%.

The module makes a compromise, with the accuracy permitted by the frequency of
the PWM master clock (19.2MHz), between accuracy of carrier frequency, accuracy
of duty cycle and high divisor. Notably extreme (unreasonable?) duty cycles
such as 1% or 99% incur a substantial error (depending on the frequency, up to
approximately 5% and down to approximately 95%, respectively; tested with the
included lircd.conf file).

Which RPi model?
The required memory address values are copied mainly from wiringPi.com; for all
models from RPi 0 - 3. While I tested the kernel module only on a RPi 3, you
might be lucky and it actually runs also on other models if the precompiler
define RPI is correctly set (see section on Compilation). Please let me know if
you used this module on an RPi other than model 3; and whether it worked or not.

Which GPIO pin to use?
As per wiringPi.c (see static uint8_t gpioToPwmALT[];
https://github.com/WiringPi/WiringPi/blob/master/wiringPi/wiringPi.c) the
following GPIO support pulse wave modulation: 12, 13, 18, 19, 40, 41 and 45.
Not all of these GPIO are available on the header P1. On a RPi3, the following
four are available:
  Pin 12 (GPIO18, PWWM0)
  Pin 32 (GPIO12, PWWM0)
  Pin 33 (GPIO13, PWWM1)
  Pin 35 (GPIO19, PWWM1).

***********
Compilation
***********
I cross-compile the module out-of-tree on a computer running Ubuntu. For this,
I had to install a cross-compiler and the raspbian kernel sources. The
instructions on see http://lostindetails.com/blog/post/
Compiling-a-kernel-module-for-the-raspberry-pi-2 worked for me, although I have
a RPi3.

If you compile for another model than RPi 3, then modify the line
"#define RPI 3" in lirc_rpi.c accordingly; but read above note on RPi models.

The path to your raspberry kernel directory needs to be adjusted in Makefile.

Then, in the directory where this file, lirc_rpi.c and Makefile are sitting:
$ make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

There should be no compile errors, and the new kernel module lirc_rpi.ko should
have been created.

************
Installation
************
I copied the newly compiled lirc_rpi.ko to the RPi (using scp) and replaced the
original module lirc_rpi.ko (after making a backup copy) by the newly compiled
module (the path depends on your kernel version):

# backup and unload currently loaded module
$ sudo cp /lib/modules/4.4.13-v7+/kernel/drivers/staging/media/lirc/lirc_rpi.ko
/lib/modules/4.4.13-v7+/kernel/drivers/staging/media/lirc/lirc_rpi.ko_original
$ sudo service lirc stop
$ sudo modprobe -r lirc_rpi
# copy new module from home directory 
$ sudo lirc_rpi.ko \
/lib/modules/4.4.13-v7+/kernel/drivers/staging/media/lirc/lirc_rpi.ko
# load with modprobe (not insmod) to also load required dependencies
$ sudo modprobe --verbose lirc_rpi gpio_out_pin=12 gpio_in_pin=17 \
softcarrier=0 hardpwm=1

The in and out pins are required parameters of lirc_rpi, thus, they need to be
available to the device tree overlay, thus, they need to be specified in
/boot/config.txt (read at boot time), e.g.,
"dtoverlay=lirc-rpi,gpio_in_pin=17,gpio_out_pin=12". These parameters are still
required to be given on the commandline, but there actual values seem to be
ignored. On the other hand, the new parameter hardpwm is unknown to the device
tree overlay (and will be ignored if present in /boot/config.txt).

Andreas <software@quantentunnel.de>
(please include 'lirc' in the subject line to bypass my spam filter)
