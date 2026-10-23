#ifndef AXIOM_EL2_MMU_H
#define AXIOM_EL2_MMU_H

/* VMSAv8-64, AArch64 EL2 Stage-1 Translation 
 * 4KiB granule, 48-bit VA/OA
 *
 * Bits and BitMasks for attributes, permissions, OA fields etc setup in the needed descriptor values
 * */

/* Descriptor Type Bits */
#define	DESC_VALID		(1ULL << 0)
#define DESC_TYPE_PAGE		(1ULL << 1)
#define DESC_TYPE_TABLE		(1ULL << 1)

/* Page Attributes for Stage-1 */
#define DESC_ATTRINDX_SHIFT	2
#define DESC_AP_SHIFT		6
#define DESC_SH_SHIFT		8
#define DESC_AF			(1ULL << 10)
#define DESC_XN			(1ULL << 54)

#define DESC_SH_INNER_SHAREABLE	(3ULL << DESC_SH_SHIFT)
#define DESC_SH_OUTER_SHAREABLE	(2ULL << DESC_SH_SHIFT)
#define DESC_SH_NON_SHAREABLE	(0ULL << DESC_SH_SHIFT)

/* Access Permissions
 * AP[2:1]:
 *	01 - RW
 *	11 - RO
 *	as, AP[1] i.e. bit 6 is treated as RES1 in EL2 regime, as it is not trying to buiild a priveleged/un-priveleged combination
 */
#define DESC_AP_RW		(1ULL << DESC_AP_SHIFT)
#define DESC_AP_RO		(3ULL << DESC_AP_SHIFT)

/* Memory Attributes */
#define AXIOM_MAIR_ATTR_NORMAL	0
#define AXIOM_MAIR_ATTR_DEVICE	1

/* for 4KiB translation granule, bits[47:12] is used in the descriptor for 48-bit output address */
#define DESC_OA_MASK		(0x0000FFFFFFFFF000ULL)


/* MAIR byte encodings */
/* our descriptor MAIR attributes set up
 *    Attr0 - Normal Memory, Inner/Outer Write-back, Read/Write 
 *    Attr1 - Device-nGnRE 
 *
 *    hence, Normal WB-> OxFF, and Device-nGnRE -> 0x04 
 *    so, MAIR_EL2 value becomes 0x04FF (describing both attributes of the descriptor as index to MAIR)
 *    */
#define AXIOM_MAIR_EL2_VALUE	0x00000000000004FFULL


/* TCR_EL2 register setup
 * 4KiB granule, 48-bit OA, 48-bit VA/PA
 *
 *    TOSZ : [5:0] = 16
 *    IRGN0 : [9:8] = 01  → Inner WB/WA
 *    ORGN0 : [11:10] = 01  → Outer WB/WA
 *    SH0 : [13:12] = 11 → Inner Shareable
 *    TG0 : [15:14] = 0 (4KiB Granule)
 *    PS : [18:16] = 101 (48-bit PA)
 *    TBI : [20] = 0 (no decision about address tagging - top byte ignoring or otherwise)
 *
 *    RESULTANT TCR_EL2 for this setup: 0x053510
 *
 * */
#define AXIOM_TCR_EL2_VALUE	0x0000000000053510ULL

#ifndef __ASSEMBLER__

void el2_build_translation_tables(void);

void el2_enable_mmu(void);

#endif

#endif
