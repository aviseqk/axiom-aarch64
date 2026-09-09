/* EL3 control registers definitions for AArch64 */

/* NOTE: We are following the TF-A's style of naming, and creating the architectural baseline from ARM doc
 * for relavant system registers and then individual architectural controls are defined as well, as BIT or shifts, etc
 * and then Axiom would use the baseline-reset value and the construct the required register value using the specific controls 
 *
 * e.g.
 * #define <REGISTER_NAME>_RES1 	-> creates the architectural baseline of register with bits where defaults are RES1, meaning 1
 * #define <REGISTER_NAME>_RESET_VAL	-> is the generated RESET_VAL using the _RES1 values
 * #define <REGISTER_NAME>_<BITFILED_NAME>_BIT -> is the bit that needs targeting for specific feature
 * 
 * */



/* SCTLR_EL3 definitions */
#define SCTLR_EL3_RES1		(1U << 29) | (1U << 28) | (1U << 23) | \
				(1U << 22) | (1U << 18) | (1U << 16) | \
				(1U << 11) | (1U << 5) | (1U << 4)

#define SCTLR_EL3_RESET_VAL	SCTLR_EL3_RES1

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



/* SCR_EL3 definitions */
#define SCR_EL3_RES1		(1U << 5) | (1U << 4)

#define SCR_EL3_RESET_VAL	SCR_EL3_RES1

#define SCR_NS_BIT		(1ULL << 0)
#define SCR_IRQ_BIT		(1ULL << 1)
#define SCR_FIQ_BIT		(1ULL << 2)
#define SCR_EA_BIT		(1ULL << 3)
#define SCR_SMD_BIT		(1ULL << 7)
#define SCR_HCE_BIT		(1ULL << 8)
#define SCR_RW_BIT		(1ULL << 10)
#define SCR_EEL2_BIT		(1ULL << 18)
#define SCR_NSE_BIT		(1ULL << 62)

/* CPTR_EL3 definitions */
#define CPTR_EZ_BIT		(1ULL << 8)
#define CPTR_TFP_BIT		(1ULL << 10)
#define CPTR_ESM_BIT		(1ULL << 12)
