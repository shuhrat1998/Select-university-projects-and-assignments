/*
 * noise_remover_v2.cu
 *
 * This program removes noise from an image based on Speckle Reducing Anisotropic Diffusion
 * Y. Yu, S. Acton, Speckle reducing anisotropic diffusion,
 * IEEE Transactions on Image Processing 11(11)(2002) 1260-1270 <http://people.virginia.edu/~sc5nf/01097762.pdf>
 * Original implementation is Modified by Burak BASTEM
 *
 * COMP 529 - Shukhrat Khuseynov - 0070495
 * Using temporary variables (in registers), taking advantage of data reuse.
 */

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <sys/time.h>
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#define MATCH(s) (!strcmp(argv[ac], (s)))
#define TILE_DIM 32 // The block size

// returns the current time
static const double kMicro = 1.0e-6;
double get_time() {
	struct timeval TV;
	struct timezone TZ;
	const int RC = gettimeofday(&TV, &TZ);
	if(RC == -1) {
		printf("ERROR: Bad call to gettimeofday\n");
		return(-1);
	}
	return( ((double)TV.tv_sec) + kMicro * ((double)TV.tv_usec) );
}

__global__ void stat (unsigned char *image, float *sum, float *sum2, int width, int height)
{
    // calculating the row & column index of the element
    int i = blockIdx.y*blockDim.y + threadIdx.y;
    int j = blockIdx.x*blockDim.x + threadIdx.x;

    // doing the naive sum using global memory
    if (i < height && j < width)
    {
        float tmp = image[i * width + j]; // current pixel value
        atomicAdd(sum, tmp); // --- 1 floating point arithmetic operations
        atomicAdd(sum2, tmp*tmp); // --- 2 floating point arithmetic operations
    }
}

__global__ void compute1 (unsigned char *image, float *north_deriv, float *south_deriv, float *west_deriv, float *east_deriv, float *diff_coef, int width, int height, float std_dev)
{
    // calculating the row & column index of the element
    int i = blockIdx.y*blockDim.y + threadIdx.y;
    int j = blockIdx.x*blockDim.x + threadIdx.x;

    // other variables
    long k;
    float gradient_square, laplacian, num, den, std_dev2;
    float imagek, north_derivk, south_derivk, west_derivk, east_derivk;
    // doing the compute 1 using global memory
    if ( (i>0 && i<(height-1)) && (j>0 && j<(width-1)) )
    {
        k = i * width + j; // position of current elements

        imagek = image[k];
        north_derivk = image[k - width] - imagek; north_deriv[k] = north_derivk; // --- 1 floating point arithmetic operations
        south_derivk = image[k + width] - imagek; south_deriv[k] = south_derivk; // --- 1 floating point arithmetic operations
        west_derivk = image[k - 1] - imagek; west_deriv[k] = west_derivk; // --- 1 floating point arithmetic operations
        east_derivk = image[k + 1] - imagek; east_deriv[k] = east_derivk; // --- 1 floating point arithmetic operations

        gradient_square = (north_derivk * north_derivk + south_derivk * south_derivk + west_derivk * west_derivk + east_derivk * east_derivk) / (imagek * imagek); // 9 floating point arithmetic operations
        laplacian = (north_derivk + south_derivk + west_derivk + east_derivk) / imagek; // 4 floating point arithmetic operations

        num = (0.5 * gradient_square) - ((1.0 / 16.0) * (laplacian * laplacian)); // 5 floating point arithmetic operations
        den = 1 + (.25 * laplacian); // 2 floating point arithmetic operations
        std_dev2 = num / (den * den); // 2 floating point arithmetic operations
        den = (std_dev2 - std_dev) / (std_dev * (1 + std_dev)); // 4 floating point arithmetic operations

        diff_coef[k] = 1.0 / (1.0 + den); // 2 floating point arithmetic operations

        if (diff_coef[k] < 0)   diff_coef[k] = 0;
        else if (diff_coef[k] > 1)  diff_coef[k] = 1;
    }
}

__global__ void compute2 (unsigned char *image, float *north_deriv, float *south_deriv, float *west_deriv, float *east_deriv, float *diff_coef, int width, int height, float lambda)
{
    // calculating the row & column index of the element
    int i = blockIdx.y*blockDim.y + threadIdx.y;
    int j = blockIdx.x*blockDim.x + threadIdx.x;

    // other variables
    long k;
    float diff_coef_north, diff_coef_south, diff_coef_west, diff_coef_east;
    float divergence;

    // doing the compute 2 using global memory
    if ( (i>0 && i<(height-1)) && (j>0 && j<(width-1)) )
    {
        k = i * width + j; // position of current element

        float diff_coefk = diff_coef[k];

        diff_coef_north = diff_coefk;
        diff_coef_south = diff_coef[k + width];
        diff_coef_west = diff_coefk;
        diff_coef_east = diff_coef[k + 1];

        divergence = diff_coef_north * north_deriv[k] + diff_coef_south * south_deriv[k] + diff_coef_west * west_deriv[k] + diff_coef_east * east_deriv[k]; // --- 7 floating point arithmetic operations
        image[k] = image[k] + 0.25 * lambda * divergence; // --- 3 floating point arithmetic operations
    }

}
int main(int argc, char *argv[]) {
	// Part I: allocate and initialize variables
	double time_0, time_1, time_2, time_3, time_4, time_5, time_6, time_7, time_8;	// time variables
	time_0 = get_time();
	const char *filename = "input.pgm";
	const char *outputname = "output.png";
	int width, height, pixelWidth, n_pixels;
	int n_iter = 50;
	float lambda = 0.5;
	float mean, variance, std_dev;	//local region statistics
	float *north_deriv, *south_deriv, *west_deriv, *east_deriv;	// directional derivatives
	float sum, sum2;	// calculation variables
	float *diff_coef;	// diffusion coefficient

    // device variables
    unsigned char *d_image = NULL;
    float *d_sum = NULL, *d_sum2 = NULL;
    float *d_north_deriv = NULL, *d_south_deriv = NULL, *d_west_deriv = NULL, *d_east_deriv = NULL, *d_diff_coef = NULL;
    //int TILE_DIM2 = TILE_DIM * TILE_DIM;

	time_1 = get_time();

	// Part II: parse command line arguments
	if(argc<2) {
	  printf("Usage: %s [-i < filename>] [-iter <n_iter>] [-l <lambda>] [-o <outputfilename>]\n",argv[0]);
	  return(-1);
	}
	for(int ac=1;ac<argc;ac++) {
		if(MATCH("-i")) {
			filename = argv[++ac];
		} else if(MATCH("-iter")) {
			n_iter = atoi(argv[++ac]);
		} else if(MATCH("-l")) {
			lambda = atof(argv[++ac]);
		} else if(MATCH("-o")) {
			outputname = argv[++ac];
		} else {
		printf("Usage: %s [-i < filename>] [-iter <n_iter>] [-l <lambda>] [-o <outputfilename>]\n",argv[0]);
		return(-1);
		}
	}
	time_2 = get_time();

	// Part III: read image
	printf("Reading image...\n");
	unsigned char *image = stbi_load(filename, &width, &height, &pixelWidth, 0);
	if (!image) {
		fprintf(stderr, "Couldn't load image.\n");
		return (-1);
	}
	printf("Image Read. Width : %d, Height : %d, nComp: %d\n",width,height,pixelWidth);
	n_pixels = height * width;
	time_3 = get_time();

	// Part IV: allocate variables
	north_deriv = (float*) malloc(sizeof(float) * n_pixels);	// north derivative
	south_deriv = (float*) malloc(sizeof(float) * n_pixels);	// south derivative
	west_deriv = (float*) malloc(sizeof(float) * n_pixels);	// west derivative
	east_deriv = (float*) malloc(sizeof(float) * n_pixels);	// east derivative
	diff_coef  = (float*) malloc(sizeof(float) * n_pixels);	// diffusion coefficient

	// allocate storage for the device
    cudaMalloc((void**)&d_image, sizeof(unsigned char) * n_pixels);
    cudaMalloc((void**)&d_sum, sizeof(float));
    cudaMalloc((void**)&d_sum2, sizeof(float));

    cudaMalloc((void**)&d_north_deriv, sizeof(float) * n_pixels);
    cudaMalloc((void**)&d_south_deriv, sizeof(float) * n_pixels);
    cudaMalloc((void**)&d_west_deriv, sizeof(float) * n_pixels);
    cudaMalloc((void**)&d_east_deriv, sizeof(float) * n_pixels);
    cudaMalloc((void**)&d_diff_coef, sizeof(float) * n_pixels);

    const dim3 block(TILE_DIM,TILE_DIM);
    const dim3 grid( (width + TILE_DIM - 1) / block.x, (height + TILE_DIM - 1) / block.y);

	time_4 = get_time();

	// Part V: compute --- n_iter * (3 * height * width + 42 * (height-1) * (width-1) + 6) floating point arithmetic operations in totaL
	for (int iter = 0; iter < n_iter; iter++)
    {
        // REDUCTION AND STATISTICS

        sum = 0; sum2 = 0;

        // copying input to the device
        cudaMemcpy(d_image, &image[0], sizeof(unsigned char) * n_pixels, cudaMemcpyHostToDevice);
        cudaMemcpy(d_sum, &sum, sizeof(float), cudaMemcpyHostToDevice);
        cudaMemcpy(d_sum2, &sum2, sizeof(float), cudaMemcpyHostToDevice);

        // running the stat kernel
        stat<<<grid, block>>>(d_image, d_sum, d_sum2, width, height);

        // copying output back to the host
        cudaMemcpy(&sum, d_sum, sizeof(float), cudaMemcpyDeviceToHost);
        cudaMemcpy(&sum2, d_sum2, sizeof(float), cudaMemcpyDeviceToHost);

		mean = sum / n_pixels; // --- 1 floating point arithmetic operations
		variance = (sum2 / n_pixels) - mean * mean; // --- 3 floating point arithmetic operations
		std_dev = variance / (mean * mean); // --- 2 floating point arithmetic operations


		//COMPUTE 1

        // copying input to the device
        cudaMemcpy(d_image, &image[0], sizeof(unsigned char) * n_pixels, cudaMemcpyHostToDevice);

        // running the compute1 kernel
        compute1<<<grid, block>>>(d_image, d_north_deriv, d_south_deriv, d_west_deriv, d_east_deriv, d_diff_coef, width, height, std_dev);

        // copying output back to the host
        cudaMemcpy(&north_deriv[0], d_north_deriv, sizeof(float) * n_pixels, cudaMemcpyDeviceToHost);
        cudaMemcpy(&south_deriv[0], d_south_deriv, sizeof(float) * n_pixels, cudaMemcpyDeviceToHost);
        cudaMemcpy(&west_deriv[0], d_west_deriv, sizeof(float) * n_pixels, cudaMemcpyDeviceToHost);
        cudaMemcpy(&east_deriv[0], d_east_deriv, sizeof(float) * n_pixels, cudaMemcpyDeviceToHost);
        cudaMemcpy(&diff_coef[0], d_diff_coef, sizeof(float) * n_pixels, cudaMemcpyDeviceToHost);


		// COMPUTE 2

        // copying input to the device
        cudaMemcpy(d_image, &image[0], sizeof(unsigned char) * n_pixels, cudaMemcpyHostToDevice);
        cudaMemcpy(d_north_deriv, &north_deriv[0], sizeof(float) * n_pixels, cudaMemcpyHostToDevice);
        cudaMemcpy(d_south_deriv, &south_deriv[0], sizeof(float) * n_pixels, cudaMemcpyHostToDevice);
        cudaMemcpy(d_west_deriv, &west_deriv[0], sizeof(float) * n_pixels, cudaMemcpyHostToDevice);
        cudaMemcpy(d_east_deriv, &east_deriv[0], sizeof(float) * n_pixels, cudaMemcpyHostToDevice);
        cudaMemcpy(d_diff_coef, &diff_coef[0], sizeof(float) * n_pixels, cudaMemcpyHostToDevice);

        // running the compute2 kernel
        compute2<<<grid, block>>>(d_image, d_north_deriv, d_south_deriv, d_west_deriv, d_east_deriv, d_diff_coef, width, height, lambda);

        // copying output back to the host
        cudaMemcpy(&image[0], d_image, sizeof(unsigned char) * n_pixels, cudaMemcpyDeviceToHost);
	}
	time_5 = get_time();

	// Part VI: write image to file
	stbi_write_png(outputname, width, height, pixelWidth, image, 0);
	time_6 = get_time();

	// Part VII: get average of sum of pixels for testing and calculate GFLOPS
	// FOR VALIDATION - DO NOT PARALLELIZE
	float test = 0;
	for (int i = 0; i < height; i++) {
			for (int j = 0; j < width; j++) {
				test += image[i * width + j];
		}
	}
	test /= n_pixels;

	float gflops = (float) (n_iter * 1E-9 * (3 * height * width + 42 * (height-1) * (width-1) + 6)) / (time_5 - time_4);
	time_7 = get_time();

	// Part VII: deallocate variables
	stbi_image_free(image);
	free(north_deriv);
	free(south_deriv);
	free(west_deriv);
	free(east_deriv);
	free(diff_coef);

	cudaFree(d_image);
	cudaFree(d_sum);
	cudaFree(d_sum2);

	cudaFree(d_north_deriv);
	cudaFree(d_south_deriv);
	cudaFree(d_west_deriv);
	cudaFree(d_east_deriv);
	cudaFree(d_diff_coef);

	time_8 = get_time();

	// print
	printf("Time spent in different stages of the application:\n");
	printf("%9.6f s => Part I: allocate and initialize variables\n", (time_1 - time_0));
	printf("%9.6f s => Part II: parse command line arguments\n", (time_2 - time_1));
	printf("%9.6f s => Part III: read image\n", (time_3 - time_2));
	printf("%9.6f s => Part IV: allocate variables\n", (time_4 - time_3));
	printf("%9.6f s => Part V: compute\n", (time_5 - time_4));
	printf("%9.6f s => Part VI: write image to file\n", (time_6 - time_5));
	printf("%9.6f s => Part VII: get average of sum of pixels for testing and calculate GFLOPS\n", (time_7 - time_6));
	printf("%9.6f s => Part VIII: deallocate variables\n", (time_7 - time_6));
	printf("Total time: %9.6f s\n", (time_8 - time_0));
	printf("Average of sum of pixels: %9.6f\n", test);
	printf("GFLOPS: %f\n", gflops);
	return 0;
}

