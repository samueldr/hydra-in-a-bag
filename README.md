`hydra-in-a-bag`
================

This project aims to provide a one-click command solution to running a hydra
instance **for development purposes**. Thus the name, this is not a
ready-to-use production environment, but a only a convenience thing.

This also aims to isolate the development environment maximally, and to ensure
the end-user does not need to change any system setting.

This is mainly geared towards development on the web-facing parts of hydra.

Security
--------

Assume close to none. First, you're running your own development code! Then,
this runs an UNPROTECTED database for convenience. Then, this defaults to the
development runners, when possible.

Requirements
------------

  * `nix`, only tested under the 2.x `nix` series.

Usage
-----

```
~ $ mkdir -p $HOME/Projects/hydra
~ $ cd $HOME/Projects/hydra
~/Projects/hydra $ git clone https://github.com/NixOS/hydra.git
~/Projects/hydra $ git clone https://github.com/samueldr/hydra-in-a-bag.git
~/Projects/hydra $ cd hydra-in-a-bag
~/Projects/hydra/hydra-in-a-bag $ nix-shell --run init-database
~/Projects/hydra/hydra-in-a-bag $ nix-shell --run start
```

Then visit http://localhost:3000/
