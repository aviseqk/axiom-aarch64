/* EL1 control registers definitions for AArch64 */

/* SCTLR_EL1 definitions */
#define SCTLR_EL1_RES1		(1U << 29) | (1U << 28) | (1U << 23) | \
				(1U << 22) | (1U << 20) | (1U << 11) | \
				(1U << 8) | (1U << 7)

#define SCTLR_EL1_RESET_VAL	SCTLR_EL1_RES1

#define SCTLR_M_BIT		(1ULL << 0)
#define SCTLR_A_BIT		(1ULL << 1)
#define SCTLR_C_BIT		(1ULL << 2)
#define SCTLR_SA_BIT		(1ULL << 3)
#define SCTLR_NAA_BIT		(1ULL << 6)
#define SCTLR_EOS_BIT		(1ULL << 11)
#define SCTLR_I_BIT		(1ULL << 12)
#define SCTLR_WXN_BIT		(1ULL << 19)
#define SCTLR_EIS_BIT		(1ULL << 22)
#define SCTLR_EE_BIT		(1ULL << 25)
#define SCTLR_NMI_BIT		(1ULL << 61)
