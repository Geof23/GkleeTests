#define N 16

__global__ void k(int* in)
{
  if(threadIdx.x < N)
    in[0] = 0;
}

int main()
{
  int* din;
  cudaMalloc((void**) &din, N*sizeof(int));
  k<<<1,N>>>(din);
}