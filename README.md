# Bitcetera Overlay for Gentoo Linux

This is a development overlay which contains a few ebuilds for Gentoo Linux.

To emerge [any of these](https://github.com/svoop/bitcetera-overlay), add the overlay with [eselect/repository](https://wiki.gentoo.org/wiki/Eselect/Repository):

```
emerge --ask app-eselect/eselect-repository
eselect repository add bitcetera git https://github.com/svoop/bitcetera-overlay
emerge --sync
```

All ebuilds are in a flux and you use them at your own risk!
