In this folder, the first step is to proceed with Training.m, this will generate your training matrices.

Secondly, you could try One_Pass_Test.m. In this file, you could change the M value to test BPSK, QPSK, and 8PSK by valuing it 2, 4, and 8.

Thirdly, proceed with One_Pass_test_16QAM.m, this file will give you the 16QAM result.

For the two-pass test, please use the same logic to use Two_Pass_Test.m and Two_Pass_Test_16QAM.m respectively.

Finally, to test real-world data, please use RealWorldDataTest_0711.m to test. If line 178 is commented, it means the one-pass test, otherwise it will be a two-pass test.

P.S. QPSK_8PSK_0dB_Test.m is to generate the evidence of why this algorithm is not satisfied under 0dB between 8PSK and QPSK


# ChessboardAMC_20230907
