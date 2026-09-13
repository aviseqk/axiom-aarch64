```text
Decisions for EL2 firmware:
1. I decided to load EL2 at not the start of DRAM region, but rather just after the DTB reserved region of QEMU
by making AXIOM_EL2_BASE 0x40100000 to avoid conflict with the virt machine and QEMU's loading region conflict.


```



```text
Observations while Development and Testing

1. ISSUE with QEMU's loading mechanism

    
since, our QEMU's DRAM region starts at physical addr 0x40000000, and our decision to place EL2 image at start of DRAM, QEMU complains it.
    As per QEMU's virt machine, for baremetal payloads and boot mode like our case, QEMU deliberately places the DTB at the very start of DRAM region
    for its availability during bootloader phase. Now ofcourse we do not need dtb right now, but that memory seems to be occupied,
    as us using AXIOM_EL2_BASE as 0x40000000 gives us the following warning:

    axiom-aarch64 on  feature/el3-to-el2-transition ❯ qemu-system-aarch64 -M virt,secure=on,virtualization=on 
    -cpu cortex-a72 -nographic -bios build/axiom.bin -device loader,file=build/el2.bin,addr=0x40000000 
    -serial stdio -S -s -monitor tcp:127.0.0.1:4444,server=on,wait=off 

    qemu-system-aarch64: Some ROM regions are overlapping 
    These ROM regions might have been loaded by direct user request or by default. 
    They could be BIOS/firmware images, a guest kernel, initrd or some other file loaded into guest memory. 
    Check whether you intended to load all this guest code, and whether it has been built to load to the correct addresses. 
    The following two regions overlap (in the cpu-memory-0 address space): 
    build/el2.bin (addresses 0x0000000040000000 - 0x0000000040001000) 
    dtb (addresses 0x0000000040000000 - 0x0000000040100000)

    ISSUE: As we can see in the error, the addr range 0x40000000 - 0x40100000 is occupied by virt machine's dtb 

    RESOLVE:

    basically, I tried to figure out a way to maybe let QEMU and its virt machine loading mechanism to not load the generated DTB
    at that address for our boot case, but there was no cmdline support or option for that.
    I could patch the QEMU source code for virt machine config to make sure that the DTB was not physically loaded at those addresses and 
    hence that memory remains untouched, but that is way beyond and away from the scope of this project.
    I tried several variations of commands to see if somehow i could make QEMU not load the DTB at that region, but could not find it.

    Then, the other resolution was to shift our EL2's image layout requirement to a higher address, basically at the address just following
    the QEMU's DTB region so that they do not overlap. 
    This meant, just making a small change of letting our axiom memory layout know that we want AXIOM_EL2_BASE to be 0x40100000,
    and thus the image starts loading from there, and when QEMU loads that there is no conflicts.

    Yes, this resolution meant that I am adjusting my firmware's memory layout based on the platform runtime loading conflict accomodation, 
    and that does not seem fine, as that should not matter much, but that is the case with QEMU machine and its currently loading the images. 
    Later anyway when we have our own loader mechanism and control of loading into memory, this should no longer be an issue, as the firmware
    would know of the memory region reservations and constraints and smartly avoid that by placing images at appropriate addresses.
    So, later our firmware owns the loading, and not the platform, QEMU in our case.

    Hence, I DECIDED TO TAKE THIS 2nd DECISION AS MY WAY FORWARD, and upshifted my EL2_BASE memory to avoid the DTB region.



```

