# hkvm
This project is to run ubuntu cloud server images in hyperkit in macosx

# ubuntu images
Visit https://cloud-images.ubuntu.com/ for ubuntu distributions of cloud images
In this project, we will use bionic

You would need to download the following files
- [initrd](https://cloud-images.ubuntu.com/bionic/current/unpacked/bionic-server-cloudimg-amd64-initrd-generic)
- [kernel](https://cloud-images.ubuntu.com/bionic/current/unpacked/bionic-server-cloudimg-amd64-vmlinuz-generic)
- [boot disk image](https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img)

Download files
```
$ wget https://cloud-images.ubuntu.com/bionic/current/unpacked/bionic-server-cloudimg-amd64-initrd-generic

$ wget https://cloud-images.ubuntu.com/bionic/current/unpacked/bionic-server-cloudimg-amd64-vmlinuz-generic

$ wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
```
# Prepare boot image
hyperkit in macosx by default does not include the qcow2 driver.
So we need to convert qcow2 image to a raw image. 
```
$ qemu-img convert -f qcow2 -O raw bionic-server-cloudimg-amd64.img bionic.raw
```
This also has the advantage of not modifying the original disk image since
the image is modified at boot time by [cloud-init](https://cloudinit.readthedocs.io/en/latest/).

# prepare cloud-init.iso
cloud-init.iso contains initialization data such as user password and ssh keys. 
Edit contents of cloud-init/ folder to your linking. Afterwards run
```
hdiutil makehybrid -o cloud-init.iso -hfs -joliet -iso -default-volume-name cidata cloud-init
```

# launch ubuntu
```
$ ./run.sh
```

# login
Based on cloud-init/user-data, you can now login to vm
with the following credentials

ubuntu:ashee007

# kill vm
Sometimes during tinkering, the vm gets stuck in which case you can kill it
```
$ pgrep hyperkit | xargs kill -SIGHUP
```
*Please note that the command above can kill your docker daemon. A safer way
is to do the following*
```
$ ps aux | grep hyperkit
$ kill -SIGHUP <pid_of_your_hyperkit_instance>
```

kill will leave the launching terminal window in a messed up state. 
Reset your terminal like so
```
$ stty sane
```
*Please note that when you type the command above, the terminal does not echo back. 
Just do it. Afterwards, the terminal is back to normal.*
