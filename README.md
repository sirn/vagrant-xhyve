# Vagrant-Xhyve

This is a [Vagrant](http://www.vagrantup.com/) plugin that adds [Xhyve](https://github.com/mist64/xhyve) provider to Vagrant, allowing Vagrant to manage VM under Mac OS X's native Hypervisor.framework.

## Status

The plugin is in a very early state and should not be used for anything except to develop the plugin itself.

| Entry               | Status
| :----------         | :-----
| Box format          | Working (not finalized)
| Cloning and booting | Working
| Network             | Working (vmnet only)
| SSH                 | Working
| SSH run             | Working
| Port forwarding     | Not implemented
| NFS file sharing    | Partially working
| Suspend             | Not supported by Xhyve
| Resume              | Not supported by Xhyve
| Force shutdown      | Working
| Graceful shutdown   | Working
| Destroying          | Working

### Installation

```shell
$ brew install xhyve
$ git clone https://github.com/sirn/vagrant-xhyve.git
$ cd vagrant-xhyve/
$ bundle install
$ rake compile
```

### Creating a box

Box format is a plain directory consist of `Vagrantfile`, `metadata.json`, Xhyve firmware and Xhyve disk file. Standard structure for the box is as follows:

```
../
|- Vagrantfile      This is where Xhyve is configured.
|- hdd.img          The disk image (e.g. dd if=/dev/null of=hdd.img bs=1M count=5000).
|- metadata.json    Box metadata, usually containing just `{"provider":"xhyve"}`.
`- userboot.so      The firmware file from Xhyve repo (in the `test` directory.)
```

Available configurations for the provider are:

* `firmware`: will be passed to Xhyve as `xhyve -f $firmware`
* `memory`: amount of memory, e.g. `1G`
* `cpus`: number of CPUs, e.g. `2`
* `lpc`: LPC device configuration, e.g. `com1,stdio`
* `acpi`: create ACPI table, e.g. `true`
* `pcis`: an array containing PCI slot configuration:

For example, follow the below instruction to create a mfsBSD box. Note that you should be using `vagrant` executable installed by `vagrant-xhyve` in the "Installation" section. The executable will be located in `bin/` directory.

1. Create a `Vagrantfile` with the following contents:

    ```ruby
    Vagrant.configure("2") do |config|
      config.vm.guest = :freebsd
      config.vm.box = "test"

      config.vm.provider :xhyve do |v|
        v.firmware = %q(fbsd,userboot.so,mfsbsd-10.2-RELEASE-amd64.iso,"")
        v.memory = "1G"
        v.cpus = "2"
        v.lpc = "com1,stdio"
        v.acpi = true
        v.pcis = [
          "2:0,virtio-net",
          "3,ahci-cd,mfsbsd-10.2-RELEASE-amd64.iso",
          "0:0,hostbridge",
          "31,lpc",
        ]
      end
    end
    ```

2. Create `metadata.json` with the following contents in the same directory as Vagrantfile:

    ```ruby
    {"provider":"xhyve"}
    ```

3. Place [mfsbsd-10.2-RELEASE-amd64.iso](http://mfsbsd.vx.sk/) in the same directory as Vagrantfile.
4. Place [userboot.so](https://github.com/mist64/xhyve/tree/master/test) in the same directory as Vagrantfile.
5. Run `tar cvzf test.box *` to create a box.
6. `bin/vagrant box add test.box`

### Running

After a box is created, you can now start Xhyve VM with a standard Vagrantfile and `vagrant up`.

```ruby
Vagrant.configure("2") do |config|
  config.vm.guest = :freebsd
  config.vm.box = "test"
end
```

Due to limitation of `vmnet.framework`, `sudo` is required to run Xhyve. This limitation will be lifted once Xhyve is code-signed.

## License

BSD
