#include <iostream>
#include <iomanip>
#include <cstdint>

void testMMX(const char* testName, int8_t A[8], int8_t B[8], int8_t C[8], int16_t D[8]) {
    int16_t F[8];
    
    std::cout << "\n" << testName << std::endl;
    std::cout << "=================================================" << std::endl;
    
    std::cout << "Input arrays:" << std::endl;
    std::cout << "A: ";
    for(int i = 0; i < 8; i++) {
        std::cout << std::setw(4) << (int)A[i];
    }
    std::cout << std::endl;
    
    std::cout << "B: ";
    for(int i = 0; i < 8; i++) {
        std::cout << std::setw(4) << (int)B[i];
    }
    std::cout << std::endl;
    
    std::cout << "C: ";
    for(int i = 0; i < 8; i++) {
        std::cout << std::setw(4) << (int)C[i];
    }
    std::cout << std::endl;
    
    std::cout << "D: ";
    for(int i = 0; i < 8; i++) {
        std::cout << std::setw(6) << D[i];
    }
    std::cout << std::endl << std::endl;
    
    __asm__ volatile (
        "pxor %%mm7, %%mm7\n\t"
        
        "movq (%0), %%mm0\n\t"
        "movq (%2), %%mm1\n\t"
        
        "movq %%mm0, %%mm5\n\t"
        "pcmpgtb %%mm7, %%mm5\n\t"
        
        "movq %%mm1, %%mm6\n\t"
        "pcmpgtb %%mm7, %%mm6\n\t"
        
        "movq %%mm0, %%mm2\n\t"
        "punpcklbw %%mm0, %%mm0\n\t"
        "psraw $8, %%mm0\n\t"
        "punpckhbw %%mm2, %%mm2\n\t"
        "psraw $8, %%mm2\n\t"
        
        "movq %%mm1, %%mm3\n\t"
        "punpcklbw %%mm1, %%mm1\n\t"
        "psraw $8, %%mm1\n\t"
        "punpckhbw %%mm3, %%mm3\n\t"
        "psraw $8, %%mm3\n\t"
        
        "pmullw %%mm1, %%mm0\n\t"
        "pmullw %%mm3, %%mm2\n\t"
        
        "movq %%mm0, %%mm6\n\t"
        "movq %%mm2, %%mm4\n\t"
        
        "movq (%1), %%mm0\n\t"
        
        "movq %%mm0, %%mm5\n\t"
        "pcmpgtb %%mm7, %%mm5\n\t"
        
        "movq %%mm0, %%mm1\n\t"
        "punpcklbw %%mm0, %%mm0\n\t"
        "psraw $8, %%mm0\n\t"
        "punpckhbw %%mm1, %%mm1\n\t"
        "psraw $8, %%mm1\n\t"
        
        "movq (%3), %%mm2\n\t"
        "movq 8(%3), %%mm3\n\t"
        
        "pmullw %%mm2, %%mm0\n\t"
        "pmullw %%mm3, %%mm1\n\t"
        
        "paddw %%mm6, %%mm0\n\t"
        "paddw %%mm4, %%mm1\n\t"
        
        "movq %%mm0, (%4)\n\t"
        "movq %%mm1, 8(%4)\n\t"
        
        "emms\n\t"
        
        :
        : "r" (A), "r" (B), "r" (C), "r" (D), "r" (F)
        : "memory"
    );
    
    std::cout << "Results using MMX:" << std::endl;
    std::cout << "F: ";
    for(int i = 0; i < 8; i++) {
        std::cout << std::setw(6) << F[i];
    }
    std::cout << std::endl << std::endl;
    
    std::cout << "Verification with scalar calculation:" << std::endl;
    int16_t F_scalar[8];
    for(int i = 0; i < 8; i++) {
        F_scalar[i] = (A[i] * C[i]) + (B[i] * D[i]);
    }
    
    std::cout << "F: ";
    for(int i = 0; i < 8; i++) {
        std::cout << std::setw(6) << F_scalar[i];
    }
    std::cout << std::endl;
    
    bool match = true;
    for(int i = 0; i < 8; i++) {
        if(F[i] != F_scalar[i]) {
            match = false;
            break;
        }
    }
    
    std::cout << std::endl << "Results " << (match ? "MATCH" : "DO NOT MATCH") << "!" << std::endl;
}

int main() {
    std::cout << "MMX Laboratory Work - Variant 14" << std::endl;
    std::cout << "Formula: F[i] = (A[i] * C[i]) + (B[i] * D[i]), i=1...8" << std::endl;
    std::cout << "A, B, C - 8-bit signed integers (_int8)" << std::endl;
    std::cout << "D - 16-bit signed integers (_int16)" << std::endl;
    
    int8_t A1[8] = {1, 2, 3, 4, 5, 6, 7, 8};
    int8_t B1[8] = {2, 3, 4, 5, 6, 7, 8, 9};
    int8_t C1[8] = {3, 4, 5, 6, 7, 8, 9, 10};
    int16_t D1[8] = {10, 20, 30, 40, 50, 60, 70, 80};
    
    testMMX("Test 1: Positive values", A1, B1, C1, D1);
    
    int8_t A2[8] = {-1, 2, -3, 4, -5, 6, -7, 8};
    int8_t B2[8] = {2, -3, 4, -5, 6, -7, 8, -9};
    int8_t C2[8] = {-3, 4, -5, 6, -7, 8, -9, 10};
    int16_t D2[8] = {10, -20, 30, -40, 50, -60, 70, -80};
    
    testMMX("Test 2: Mixed positive and negative values", A2, B2, C2, D2);
    
    int8_t A3[8] = {0, 1, 0, -1, 0, 2, 0, -2};
    int8_t B3[8] = {1, 0, -1, 0, 2, 0, -2, 0};
    int8_t C3[8] = {5, 5, 5, 5, 5, 5, 5, 5};
    int16_t D3[8] = {100, 100, 100, 100, 100, 100, 100, 100};
    
    testMMX("Test 3: Edge case with zero values", A3, B3, C3, D3);
    
    std::cout << "\n=================================================" << std::endl;
    std::cout << "MMX Implementation Features:" << std::endl;
    std::cout << "1. Sign extension of 8-bit signed integers to 16-bit" << std::endl;
    std::cout << "2. Zero comparison before unpacking (pcmpgtb instruction)" << std::endl;
    std::cout << "3. Parallel multiplication using pmullw instruction" << std::endl;
    std::cout << "4. Parallel addition using paddw instruction" << std::endl;
    std::cout << "5. Proper handling of negative values" << std::endl;
    std::cout << "6. Processing 8 elements simultaneously using MMX registers" << std::endl;
    
    return 0;
}