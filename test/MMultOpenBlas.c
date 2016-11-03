#include <openblas_config.h>
#include <f77blas.h> 
#include <cblas.h>
 

void MY_MMult( int m, int n, int k, double *a, int lda, 
                                    double *b, int ldb,
                                    double *c, int ldc )
{
 
  cblas_dgemm(CblasColMajor,CblasNoTrans, CblasNoTrans,  m,  n ,  k,
            1.0, a ,  lda , b ,  ldb , 1.0, c ,  ldc);
}


  
