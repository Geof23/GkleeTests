#include <stdio.h>
#include <time.h>
#include <stdlib.h>

__global__ void device_global(unsigned int *input_array, int num_elements) {
  // This may race depending on the call to rand() when filling the array
  int my_index = blockIdx.x * blockDim.x + threadIdx.x;
  int index = input_array[my_index];
  input_array[index] = my_index;
}

int main(void) {
  // how big our array for interfacing with the GPU will be
  int num_elements = 32;
  int num_bytes = sizeof(unsigned int) * num_elements;
    
  // pointers for the interfacing arrays
  unsigned int *host_array = 0;
  unsigned int *device_array = 0;
 
  // malloc for host and device
  host_array = (unsigned int*) malloc(num_bytes);
  cudaMalloc((void **) &device_array, num_bytes);

  // check the mallocs
  if (host_array == 0) {
    printf("Unable to allocate memory on host");
    return 1;
  }

  if (device_array == 0) {
    printf("Unable to allocate memory on device");
    return 1;
  }

  srand(time(NULL));
  
  // set host array values
  for (int i = 0; i<num_elements; i++) {
    host_array[i] = i;
    // At a very low rate cause the contents to be wrong: causing a race later
    if (rand() % 1000 == 3) {
      host_array[i] = (i-1)%32;
    }
  }

  // copy them to the GPU
  cudaMemcpy(device_array, host_array, num_bytes, cudaMemcpyHostToDevice);

  // define block and grid sizes
  int block_size = 32;
  int grid_size = (num_elements + block_size - 1) / block_size;

  // run GPU code
  device_global<<<grid_size, block_size>>>(device_array, num_elements);

  // copy output to host
  cudaMemcpy(host_array, device_array, num_bytes, cudaMemcpyDeviceToHost);

  // print any information
  for (int i=0; i<num_elements; i++) {
    printf("%d, ", host_array[i]);
    if (i%16 == 15) {
      printf("\n");
    }
  }   
  

  // free memory
  free(host_array);
  cudaFree(device_array);
}
