## System Hash Generator

It's a simple bash script to generate a unique hash from system resources and then check later if something has been changed or not!

#### Usage:

```
root@narbeh-xps:/root# ./system-hash.sh --gen
root@narbeh-xps:/root# ./system-hash.sh --check

Current Hash: 	 df0fa6a6c51a0b7d86118a0b04465f5d
Original Hash: 	 df0fa6a6c51a0b7d86118a0b04465f5d

----------------------
System integrity is ok
----------------------
```