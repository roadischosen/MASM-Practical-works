#pragma once
extern "C" {
	void LongOp_Sub(long *op1, long *op2, long *diff, long size_in_dwords);
	void LongOp_Add(long *op1, long *op2, long *sum, long size_in_dwords);
	void LongOp_Mul(long *op1, long *op2, long *prod, long size_in_dwords);
}