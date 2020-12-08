#include <cuda.h>
#include <cuda_runtime.h>
#include <iostream>
#include <vector>

extern "C" __global__ void switch_test(long *src_ptr, long *dst_ptr, int num_rows, int* output_rows)
{
    int idx;
    long val;
    int pos_start = blockIdx.x * blockDim.x + threadIdx.x;
    if(pos_start >= num_rows) return;
    val = src_ptr[pos_start];
    switch(val){
        case 7016889694419943424L:
        case 3688448094816436224L:
        case 3761631588761206784L:
        case 7089228763434582016L:
        case 7161567832449220608L:{
			idx = atomicAdd(output_rows,1);
			dst_ptr[idx] = val;
			break;
		}
        default: break;
	}
	return;
}

int main()
{
    int64_t *src_ptr,*dst_ptr;
	int32_t num_rows = 10;
	auto cuda_err = cudaMallocManaged(&src_ptr,sizeof(int64_t)*num_rows);
	if(cuda_err) return -6;
	std::cout << "alloc src_ptr success" << std::endl;

	cuda_err = cudaMallocManaged(&dst_ptr,sizeof(int64_t)*num_rows);
	if(cuda_err) return -7;
	std::cout << "alloc dst_ptr success" << std::endl;

	int32_t* output_rows;
	cuda_err = cudaMallocManaged(&output_rows,sizeof(int32_t));

	// for(int i=0;i<num_rows;++i) src_ptr[i] = i;
	src_ptr[0] = 3688729569793146880L;
	src_ptr[1] = 3617516400685350912L;
	src_ptr[2] = 3688729569793146880L;
	src_ptr[3] = 3761631588761206784L;
	src_ptr[4] = 3688448094816436224L;
	src_ptr[5] = 3689292519746568192L;
	src_ptr[6] = 3618642300592193536L;
	src_ptr[7] = 3618360825615482880L;
	src_ptr[8] = 3688729569793146880L;
	src_ptr[9] = 3617516400685350912L;
	*output_rows = 0;

    switch_test<<<2,16>>>(src_ptr,dst_ptr,num_rows,output_rows);
    cudaDeviceSynchronize();
    cuda_err = cudaGetLastError();
    if(cuda_err){
        std::cout << "cudaDeviceSynchronize failed, error code = " << cuda_err << std::endl;
	}
	std::cout << "cudaDeviceSynchronize success" << std::endl;

    for(int i=0; i<*output_rows; ++i){
		std::cout << i << ":" << dst_ptr[i] << std::endl;
	}
    return 0;
}
