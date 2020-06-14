# run-hyperkit
This project is to run ubuntu cloud server images in macosx on hyperkit.
Hyperkit is the underlying virutalization technology used in Docker.
You have it already if you installed docker.
```
$ ls -l `which hyperkit`
lrwxr-xr-x  1 root  admin  67 May 19 13:39 /usr/local/bin/hyperkit -> /Applications/Docker.app/Contents/Resources/bin/com.docker.hyperkit

$ file `which hyperkit`
/usr/local/bin/hyperkit: Mach-O 64-bit executable x86_64
```


## automated run
A Makefile is provided to automate the steps outlined in the section **Manual process**.
```
$ make
```
After the VM boots, use the following credentials
```
login: ubuntu
password: ashee007
```
*Please note that login into the VM may fail the 1st few times. This is because **cloud-init** has not had a chance to initialize. Make a few attempt, it will work eventually.*

The username, password or ssh-keys can be customized by editing *cloud-init/user-data*. See docs at https://cloudinit.readthedocs.io/en/latest/

## network
The VM above does configure any network. hyperkit can create a bridge on host
and route traffic from guest to the network. However, to do so, it needs
sudo privileges. Uncomment the following in *run.sh*
```
# NET="-s 2:0,virtio-net"
```
and invoke run as root
```
$ sudo ./run.sh
```
Run the following command in host
```
$ ifconfig -a
...
...
en7: flags=8963<UP,BROADCAST,SMART,RUNNING,PROMISC,SIMPLEX,MULTICAST> mtu 1500
	ether 7a:1f:d7:93:a9:b5
	media: autoselect
	status: active
bridge100: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	options=3<RXCSUM,TXCSUM>
	ether 4e:32:75:29:75:64
	inet 192.168.66.1 netmask 0xffffff00 broadcast 192.168.66.255
	Configuration:
		id 0:0:0:0:0:0 priority 0 hellotime 0 fwddelay 0
		maxage 0 holdcnt 0 proto stp maxaddr 100 timeout 1200
		root id 0:0:0:0:0:0 priority 0 ifcost 0 port 0
		ipfilter disabled flags 0x2
	member: en7 flags=3<LEARNING,DISCOVER>
	        ifmaxaddr 0 port 15 priority 0 path cost 0
	nd6 options=201<PERFORMNUD,DAD>
	media: autoselect
	status: active
```
*Note that hyperkit created en7 and bridge100 to route network traffic between
host and guest*

In case you created VM without network first and reusing the previous image (*bionic.raw*),
you may have to initialize your network in the guest. Run the following in guest
```
$ sudo dhclient
```

# Manual process
This section is a detailed explanation of steps automated in the Makefile.
It is meant to provide context for human understanding of how hyperkit
vms are created and run.

## ubuntu images
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
## prepare boot image
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

## prepare cloud-init.iso
cloud-init.iso contains initialization data such as user password and ssh keys. 
Edit contents of cloud-init/ folder to your liking. Afterwards run
```
hdiutil makehybrid -o cloud-init.iso -hfs -joliet -iso -default-volume-name cidata cloud-init
```

## launch ubuntu
```
$ ./run.sh
```

## login
Based on cloud-init/user-data, you can now login to vm
with the following credentials

ubuntu:ashee007

# Useful tips
## kill vm
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

# References
- See [bhyve](https://www.freebsd.org/cgi/man.cgi?query=bhyve&sektion=8&n=1) for hyperkit command line argments. [hyperkit](https://github.com/moby/hyperkit) is based on [xhyve](https://github.com/machyve/xhyve) which is itself based on bhyve
- [qemu-img man page](https://www.qemu.org/docs/master/interop/qemu-img.html)
- [cloud-init docs](https://cloudinit.readthedocs.io/en/latest/)
- [cloud-init - NoCloud](https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html) - allows the user to provide user-data and meta-data to the instance without running a network service
- [ubuntu cloud images](https://cloud-images.ubuntu.com/)
- [hdiutil man page](https://ss64.com/osx/hdiutil.html) - osx builtin tool to make an iso image