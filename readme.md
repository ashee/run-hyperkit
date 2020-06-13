# run-hyperkit
This project is to run ubuntu cloud server images in hyperkit in macosx.
Hyperkit get installed when you install docker. Docker uses hyperkit
underneath the covers.
```
$ ls -l `which hyperkit`
lrwxr-xr-x  1 root  admin  67 May 19 13:39 /usr/local/bin/hyperkit -> /Applications/Docker.app/Contents/Resources/bin/com.docker.hyperkit

$ file `which hyperkit`
/usr/local/bin/hyperkit: Mach-O 64-bit executable x86_64
```

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

In case you do not have qemu-img installed in your system, run
```
$ brew install qemu-img
```

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

# references
- See [bhyve](https://www.freebsd.org/cgi/man.cgi?query=bhyve&sektion=8&n=1) for hyperkit command line argments. [hyperkit](https://github.com/moby/hyperkit) is based on [xhyve](https://github.com/machyve/xhyve) which is itself based on bhyve
- [qemu-img man page](https://www.qemu.org/docs/master/interop/qemu-img.html)
- [cloud-init docs](https://cloudinit.readthedocs.io/en/latest/)
- [cloud-init - NoCloud](https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html) - allows the user to provide user-data and meta-data to the instance without running a network service
- [ubuntu cloud images](https://cloud-images.ubuntu.com/)
- [hdiutil man page](https://ss64.com/osx/hdiutil.html) - osx builtin tool to make an iso image