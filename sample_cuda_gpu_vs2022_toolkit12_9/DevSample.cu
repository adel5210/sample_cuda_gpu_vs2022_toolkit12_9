#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <array>
#include <vector>
#include <random>
#include <cstdlib>
#include <ctime>

#define N 1000000

__global__ void add(int* a, int* b) {
	int index = threadIdx.x;
	int stride = blockDim.x;

	for (int i = index; i < N; i+=stride) {
		a[i] += b[i];
	}
}

int main()
{
	printf("Run CUDA samples\n");

	std::srand(static_cast<unsigned>(std::time(nullptr)));

	int* a;
	int* b;

	//allocate unified memory
	cudaMallocManaged(&a, N * sizeof(int));
	cudaMallocManaged(&b, N * sizeof(int));

	for (size_t i = 0; i < N; i++)
	{
		a[i] = std::rand() % 100;
		b[i] = std::rand() % 100;
	}

	add << <1, 256 >> > (a, b);

	//Block until the kernel is done
	cudaDeviceSynchronize();

	// Free the unified memory
	cudaFree(a);
	cudaFree(b);

	return 0;
}