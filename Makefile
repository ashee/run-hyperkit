.phony: all

disk_img:=bionic.raw
kernel:=bionic-server-cloudimg-amd64-vmlinuz-generic
initrd:=bionic-server-cloudimg-amd64-initrd-generic
boot_img:=bionic-server-cloudimg-amd64.img
img_files:=$(kernel) $(initrd) $(boot_img)
cloud_init:=cloud-init.iso
cloud_init_files:=$(wildcard cloud-init/*)

run: disk iso
	./run.sh

iso: $(cloud_init)

disk: $(disk_img)

$(disk_img): $(img_files)
	qemu-img convert -f qcow2 -O raw $(boot_img) $@

$(initrd):
	wget https://cloud-images.ubuntu.com/bionic/current/unpacked/$@

$(kernel):
	wget https://cloud-images.ubuntu.com/bionic/current/unpacked/$@

$(boot_img):
	wget https://cloud-images.ubuntu.com/bionic/current/$@

$(cloud_init): $(cloud_init_files)
	hdiutil makehybrid -o $@ -hfs -joliet -iso -default-volume-name cidata cloud-init

clean_iso: $(cloud_init)
	rm $?

clean_downloads: $(img_files)
	rm $?

clean_all:
	rm $(disk_img) $(cloud_init) $(kernel) $(initrd) $(boot_img)
