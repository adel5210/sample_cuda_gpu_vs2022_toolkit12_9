#ifndef CUDACC
#define CUDACC
#endif

#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <array>
#include <vector>
#include <random>
#include <cstdlib>
#include <ctime>
#include <cuda.h>
#include <cuda_runtime_api.h>


#define N 1000000

//grid-stride loop
__global__ void add(int* a, int* b) {
	__shared__ int shared_a[1024];

	int index = threadIdx.x + blockDim.x * blockIdx.x;
	int stride = blockDim.x * gridDim.x;

	for (int i = index; i < N; i+=stride) {
		a[i] += b[i];
		shared_a[i] = a[i];
	}
}

int main()
{
	printf("Run CUDA samples\n");

	std::srand(std::time(0));

	int* a;
	int* b;

	//allocate unified memory
	cudaMallocManaged(&a, N * sizeof(int));
	cudaMallocManaged(&b, N * sizeof(int));

	cudaMemPrefetchAsync(a, N * sizeof(int), 0, 0); //0 signifies the gpu id
	cudaMemPrefetchAsync(b, N * sizeof(int), 0, 0); //0 signifies the gpu id

	for (size_t i = 0; i < N; i++)
	{
		a[i] = std::rand() % 100;
		b[i] = std::rand() % 100;
	}

	add << <1, 1024 >> > (a, b);

	//Block until the kernel is done
	cudaDeviceSynchronize();

	// Free the unified memory
	cudaFree(a);
	cudaFree(b);

	return 0;
}