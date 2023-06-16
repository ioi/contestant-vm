# Installing Ubuntu through autoinstall/cloud-init

One has to provide a disk with a user-data and a meta-data file, the former containing the installation information.

```
genisoimage  -output seed.iso -volid cidata -joliet -rock user-data meta-data
```

For installing Ubuntu within VMWare, add a new CD device along the one with the Ubuntu server iso, and load the generated `seed.iso` CD image.

When booting, no TUI should appear, but it will prompt for verifying that installation is intended.

