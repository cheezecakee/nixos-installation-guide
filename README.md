# NixOS Installation Guide
![ISO](https://img.shields.io/badge/NixOS-Minimal_ISO-blue)

### Description
Some of the steps here were taken from [titanknis](https://github.com/titanknis) who has an amazing guide on how to install Nixos using the minimal installation ISO. The guide below assumes you've already created the live boot and is to be used as a quick setup, all configuration files are included in this setup, you'll only need to handle disk partitioning and possibly WiFi setup if you're not on Ethernet.
If you wish to check out a full installation guide from scratch I highly recommend titanknis's [guide](https://github.com/titanknis/Nixos-Installation-Guide).
The configuration is my nix flake, for more details on what it includes -> [here](https://github.com/cheezecakee/dotfiles/tree/main/nix)

---

### Requirements
- NixOS Minimal Installation ISO (latest)
- A machine with UEFI firmware
- Working internet connection (WiFi steps included)

---

### What This Guide Includes
- Disk partitioning instructions (GPT, UEFI)
- Minimal configuration clone into `/mnt/etc/nixos`
- Post-install init script that:
  - Clones your dotfiles repo
  - Creates symlinks for `.config` and `nix`
  - Copies the hardware-configuration file
  - Rebuilds NixOS using your flake
  - Reboots automatically

---

### What This Guide Does NOT Do
- It does not configure the root password (because of `--no-root-passwd`)
- It does not create additional users beyond the default one from the config
- It does not perform encrypted installs (LUKS)

---

### Installation
If connect via Ethernet skip [ahead](#clone-initial-config)

#### Connect to WiFi
1. Start `wpa_supplicant` and configure WiFi with `wpa_cli`:
``` shell
sudo systemctl start wpa_supplicant
wpa_cli
```
Inside `wpa_cli`, enter: 
``` shell
scan
scan_results
add_network
0
set_network 0 ssid "myhomenetwork"
OK
set_network 0 psk "mypassword"
OK
set_network 0 key_mgmt WPA-PSK
OK
enable_network 0
OK
quit
```

---

#### Partition

**Partition the Disk Using `parted`**
> **Warning:** This will erase the entire disk. Double-check the device name (e.g., `/dev/nvme0n1`, `/dev/sda`) before continuing.

Before partitioning check available disks:
``` shell
lsblk -f
```

Pick the correct one, then enter `parted`:
``` shell
parted /dev/nvme0n1
```
(Replace the disk path as needed)

1. Create a new GPT partition table:
``` shell
(parted) mklabel gpt
```
This command sets up the disk to use the GPT partitioning scheme, which is necessary for UEFI systems. 

2. Create the partitions:
- **EFI System Partition (ESP) (1 MiB to 1 GiB):** 
``` shell
(parted) mkpart ESP fat32 1MiB 1GiB
(parted) set 1 esp on
```
This sets up a 1 GiB partition formatted as FAT32 for the EFI system. It’s required for UEFI booting.
> **Note:** For dual booting I recommend  <= 400MiB (Lanzaboote takes space)

- **Root partition (rest of the disk):**
``` shell
(parted) mkpart primary 1GiB -1MiB
```
That's it - two partitions: 
- **Partition 1 -> EFI**
- **Partition 2 -> Root filesystem**
> *For more partitions repeat the root partition with the storage path eg:* `(parted) mkpart primary 1GiB 50GiB`

4. Print the partition table to verify:
``` shell
(parted) print
```

5. Quit `parted`:
``` shell
(parted) quit
```

#### Format Disk 
- **Format EFI:**
``` shell
mkfs.fat -F32 -n ESP /dev/nvme0n1p1
```
- **Format Root:**
``` shell
mkfs.ext4 -L nixos-root /dev/nvme0n1p2
```
#### Mount Disk
1. Mount the root partition:
``` shell
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot 
```
2. Mount the EFI partition:
``` shell
mount /dev/nvme0n1p1 /mnt/boot
```

---

#### Clone Initial Config
Install git
``` shell
nix-shell -p git 
```
Clone repo to config location
``` shell
git clone https://github.com/cheezecakee/nixos-setup /mnt/etc/nixos
```

Open new directory
``` shell
cd /mnt/etc/nixos
```

--- 

### Install NixOS: 

``` shell
nixos-install --no-root-passwd
```

**Reboot system**
``` shell
reboot
```

---

### Post Installation

When the system reboots, remove the live USB boot.
Run this command:
``` shell
cd $HOME
ls
```

If a script called `init.sh` shows up, the installation has been a success (so far lol). All you need to do is run the script:
```
~/init.sh
```

Your system will reboot one last time and you should see the login GUI page when everything is done. I recommend updating the user module in your dotfiles after the reboot!

---

> **DISCLAIMER:** This has not been fully tested yet and will be updated.

