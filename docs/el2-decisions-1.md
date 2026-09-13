
```text
Decisions for EL2 firmware:

1. We are keeping EL2's execution environment and image in DRAM, as opposite to EL3 bootcode in BOOTROM and runtime env in SECURE_RAM for EL3

2. in default QEMU config, we get 128MiB of DRAM, out of which, we reserve 4MiB of DRAM area for initial EL2 environment

3. For loading the EL2 image while we are in EL3, right now we are going the manual way, we have the payload, we manually assign
its entrypoint to the EL2's related area and then copy the EL2 code and all other runtime areas into the designated memory carved up for 
EL2. So, when EL3 wants to handoff, the EL2 is pre-positioned in its DRAM region, EL3 directly transfers execution to that point.

TODO: Later down the line, we can introduce a minimal image-loader subsystem that loads the image, and takes this manual step out.

4. for the EL3 EL2 handoff ABI, and dependency of EL3 on EL2 for its addresses and lack of a sophisticated loader mechanism in EL3,
currently I decided to use a build-time generated handoff ABI in form of a header file to let EL3 know of EL2 addresses (el2-build-layout.h)

5. To make sure, the EL2 payload and its raw bytes are physically present at the said address, and since they are independently linked,
I exploit QEMU's baremetal setup raw loader mechanism to make sure those EL2 payload's bytes are physically pre-positioned way before EL3 erets into EL2
using the QEMU `-device loader,file=build/el2.bin,addr=0x40000000`
```

```text
Observations while Development:
1. Because, from the get-go, we are using the DRAM allocation for the .data section, the scope of relocation of .data section
from LMA to VMA has vanished, as both load and runtime are present in DRAM, due to our non-MMU manual load of EL2 payload decision

2. Since, our EL2 linker script only has one memory section like 
        MEMORY
        {
	        EL2_DRAM (rwx):
		        ORIGIN = AXIOM_EL2_BASE,
		        LENGTH = AXIOM_EL2_SIZE
        }
The linker complains while linking as "aarch64-none-elf-ld: warning: el2-entry.elf has a LOAD segment with RWX permissions"

This warning is normal as because in ELF sections, only one section is being created, that holds both the execute code, as well as the 
runtime mutable data. Now ofcourse, this problem will vanish when we introduce MMU, and page tables as then the memory will be neatly
separated. This did not occur in EL3's case because we had BOOTROM as a region for the execute code and SECURE_RAM for mutable runtime data.
But, this warning can be ignored for now, and will later get automatically addressed when we introduce MMU at EL2

3. EL2 EL3 handoff Image related Issues: [BIG ISSUE]

        CONTEXT:

        Okay, so as of now, for the transition between EL3 and later stages, and need of different payloads, and because of the lack of
        a mature image-loading mechanism in the current stage of project, I have decided to go the manual pre-positioned loading of EL2 route.

        In this current design, since, Axiom currently consists of two independently linked images, only EL2 linker internally knows the addresses like
        `_el2_start`, `__el2_vector_base` and `__el2_stack_top` right,
        this creates two big issues :
        a.) these aforementioned symbols do not exist in the EL3's elf whilst it absolutely needs them while linking and actually configuring
        the EL3->EL2 eret path, but cannot be referenced while EL3 build time, because they remain known only to EL2

        b.) This design requires the EL2 image which is independently linked, its bytes to be manually present at the declared DRAM address,
        but since we are not packaging the firmware together with EL3, there is no way this image stays present at the EL2 linker's assigned DRAM address

        
        RESOLVE [TEMPORARY]:
        a) for the symbol unavailability issue, I have decided to build a static build-time handoff ABI type contract between EL2 and EL3
        basically, when EL2 compiles and builds itself, the linker generated symbols are then exported to a generated header file using an
        extractor script, preferably nm, and that way EL2 advertises the addresses created by it and needed by EL3.
        
        EL3 then consumes those symbols and its linker resolves them while linking, making sure that EL3 while its eret step points to correct address.
        This way, EL2 and its linker still owns its layout and addresses, but EL3 simply consumes them and stays consistent.

        b) for the image-loading in memory: I have decided to take a shortcut, where since we are using the QEMU's bare-metal loading
        setup for our development stage, QEMU provides us with an interface to manually load packages and bytes at said pre-declared addresses,
        so we do that to make sure that when EL3 eventually does ERET into EL2 at _el2_start, there are bytes of EL2 physically present at that
        address in our QEMU's memory and that boot moves on.

        PROPER RESOLVE [FUTURE TODO PLAN]:
        Later down the development, I will anyway introduce a minimal image loading and packaging mechanism, where like the EL2, EL3 all targets
        would still be built independently but also firmware-packaged in some way, advertising own's metadata and details.
        So, then say EL3 wants to go to EL2, it locates, verifies and loads the EL2 firmware-packaged image and this image now has its own
        idea of layout, so things like metadata, load addr, entry addr, size, etc and based on that the loader code will load the image into 
        memory, and also know about the entrypoints and where to go while executing.
        
        In a way, the packaged image itself becomes its own runtime interface and advertiser, rather than current build-time interface type solution,
        and this way we remove the unnecessary dependency on the platform(in our case, QEMU) to load raw EL2 payload at build-time known address.


4. Created a small tool for developing the EL2->EL3 symbol exchange Header ABI
        - where basically build steps have a dependency in the following fashion:
        EL2 Linker
            ↓
        el2.elf
            ↓
        generate-el2-symbols.sh
            ↓
        export required symbols into a header
            ↓
        EL3 consumes this interface
            ↓
        el3.elf

```
