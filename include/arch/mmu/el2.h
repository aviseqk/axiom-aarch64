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


void el2_build_translation_tables(void);

#endif
