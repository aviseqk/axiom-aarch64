/* EL2 control registers definitions for AArch64 */

/* SCTLR_EL2 definitions */
#define SCTLR_EL2_RES1		(1U << 29) | (1U << 28) | (1U << 23) | \
				(1U << 22) | (1U << 18) | (1U << 16) | \
				(1U << 11) | (1U << 5) | (1U << 4)

#define SCTLR_EL2_RESET_VAL	SCTLR_EL2_RES1

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

/* SPSR_EL2 definitions */
#define SPSR_EL2_M_EL1h		(0x5)
#define SPSR_EL2_D_BIT		(1ULL << 9)
#define SPSR_EL2_A_BIT		(1ULL << 8)
#define SPSR_EL2_I_BIT		(1ULL << 7)
#define SPSR_EL2_F_BIT		(1ULL << 6)

/* HCR_EL2 definitions */
#define HCR_EL2_RW_BIT		(1ULL << 31)
