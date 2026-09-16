```text Observations:

The CPU register state snapshot at which EL1 is normally running are:

(gdb) info registers x0 x1 x2 x3 x4 x5
CurrentEL   x0             0x4                 4
SCTLR_EL1   x1             0x30d00988          818940296
VBAR_EL1    x2             0x40500800          1078986752
SP          x3             0x405050e0          1079005408
SPSel       x4             0x1                 1
DAIF        x5             0x3c0               960

(gdb) info registers HCR_EL2
HCR_EL2        0x80000000          2147483648

(gdb) info registers SP_EL1
SP_EL1         0x405050e0          1079005408

```
