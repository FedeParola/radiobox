# RadioBox

## Building and running

All code blocks suppose to be executed from a common working directory.

### Building RadioBox apps

Clone RadioBox repo:
```bash
git clone https://github.com/FedeParola/radiobox.git
cd radiobox
git submodule update --init --recursive
```

Patch and build QEMU:
```bash
git clone https://github.com/qemu/qemu.git
cd qemu
git checkout v8.2.0
git apply ../radiobox/ivshmem_patch.diff
mkdir build
cd build
../configure --target-list=x86_64-softmmu
make -j
```

Build and install Z-stack:
```bash
git clone https://github.com/FedeParola/f-stack.git

cd f-stack/dpdk
meson -Denable_kmods=true build
ninja -C build
sudo ninja -C build install

cd ../lib
make -j
sudo make install
```

Bind a network interface to DPDK driver:
```bash
sudo modprobe uio
sudo insmod f-stack/dpdk/build/kernel/linux/igb_uio/igb_uio.ko
sudo ip link set <ifname> down
sudo dpdk-devbind.py -b igb_uio <ifname>
```

Build Unimsg manager and gateway:
```bash
git clone https://github.com/FedeParola/unimsg.git
cd unimsg/manager/
make
cd ../gateway
make
```

Build the RadioBox application (e.g., rr-latency):
```bash
cd radiobox/apps/rr-latency/radiobox
make menuconfig
# Configure the application
make -j
```

### Running RadioBox apps

Allocate 1G hugepages:
```bash
echo 16 > sudo tee /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
```

Allocate shared memory buffers file:
```bash
sudo truncate -s 1G /dev/hugepages/unimsg_buffers
```

Run the manager:
```bash
cd unimsg/manager
sudo unimsg_manager
```

Run the gateway:
```bash
cd unimsg/gateway
sudo unimsg_gateway
```

Run the RadioBox VM (e.g., rr-latency app).
`<id>` is an incremental id of the VM starting from 1.
The address of the VM will be computed as `10.0.0.<id>`.
```bash
cd radiobox/apps/rr-latency/radiobox
sudo ./run_vm.sh <id> <args>
```