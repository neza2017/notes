#include <cuda.h>
#include <cuda_runtime.h>
#include <iostream>
#include <vector>

int main()
{
	auto err = cuInit(0);
	if(err) return -1;

	CUdevice device;
	CUcontext context;

	err = cuDeviceGet(&device,0);
	if(err) return -2;

	err = cuCtxCreate(&context,CU_CTX_SCHED_BLOCKING_SYNC,device);
	if(err) return -3;
	std::cout << "cuda initial success" << std::endl;

	CUmodule module;
	err = cuModuleLoad(&module,"switch_test.ptx");
	if(err) return -4;
	std::cout << "cuda load module success" << std::endl;

	CUfunction function;
	err = cuModuleGetFunction(&function,module,"switch_test");
	if(err)return -5;
	std::cout << "cuda get function success" << std::endl;

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

	void *kernel_para[]={
		&src_ptr,
		&dst_ptr,
		&num_rows,
		&output_rows
	};

	err=cuLaunchKernel(function,
			   2,1,1,
			   16,1,1,
			   0,nullptr,
			   (void**)&kernel_para,
			   nullptr);
	if(err) return -8;
	std::cout << "cuda launch kernel success" << std::endl;
	err = cuCtxSynchronize();
	if(err){
		std::cout << "context synchronize failed, error code = " << err << std::endl;
	}
	std::cout << "cuda context synchronize sucess" << std::endl;

	for(int i=0; i<*output_rows; ++i){
		std::cout << i << ":" << dst_ptr[i] << std::endl;
	}

	return 0;	
}
