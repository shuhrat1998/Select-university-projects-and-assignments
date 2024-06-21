// SpMV Code - Part 1 (parallel with MPI)
// Created: 03-12-2019
// Author: Najeeb Ahmad
// Updated: 13-05-2020
// Author: Muhammad Aditya Sasongko
// Updated: 08-08-2020
// Author: Shukhrat Khuseynov

#include <bits/stdc++.h>
#include "common.h"
#include "matrix.h"
#include "mmio.h"
#include "mpi.h"

using namespace std;

int main(int argc, char **argv)
{
    csr_matrix matrix;
    int P, myrank, N, M, *rowptr;

    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD, &P);
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);

    if(argc < 3 && myrank == 0)
    {
    	std::cout << "Error: Missing arguments\n";
    	std::cout << "Usage: " << argv[0] << " matrix.mtx\n" << " time_step_count";
    	return EXIT_FAILURE;
    }

    int time_steps = atoi(argv[2]);
    int *rows, *sendcounts, *rowstart, *displs;

    rows = (int *)malloc(sizeof(int)*P);
    sendcounts = (int *)malloc(sizeof(int)*P);
    rowstart = (int *)malloc(sizeof(int)*P);
    displs = (int *)malloc(sizeof(int)*P);

    if (myrank == 0)
    {
        string matrix_name;

        printf("Reading .mtx file\n");
        int retCode = 0;
        matrix_name = argv[1];
        cout << matrix_name << endl;

        retCode = mm_read_unsymmetric_sparse(argv[1], &matrix.m, &matrix.n, &matrix.nnz,
                         &matrix.csrVal, &matrix.csrRowPtr, &matrix.csrColIdx);

        if(retCode == -1)
        {
            cout << "Error reading input .mtx file\n";
            return EXIT_FAILURE;
        }

        printf("Matrix Rows: %d\n", matrix.m);
        printf("Matrix Cols: %d\n", matrix.n);
        printf("Matrix nnz: %d\n", matrix.nnz);
        coo2csr_in(matrix.m, matrix.nnz, matrix.csrVal, matrix.csrRowPtr, matrix.csrColIdx);
        printf("Done reading file\n");
        N = matrix.n; M = matrix.m;
    }

    MPI_Bcast(&N, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Bcast(&M, 1, MPI_INT, 0, MPI_COMM_WORLD);

    rowptr = (int *)malloc(sizeof(int)*(M + 1));
    if (myrank == 0)
        for (int i=0; i<(M + 1); i++)
            rowptr[i] = matrix.csrRowPtr[i];

    MPI_Bcast(rowptr, (M + 1), MPI_INT, 0, MPI_COMM_WORLD);

    double *rhs, *result, *my_val;
    int *my_colidx;

    // allocating vector rhs
    rhs = (double *)malloc(sizeof(double) * N);

    // initializing right-hand-side
    for(int i = 0; i < N; i++)
      rhs[i] = (double) 1.0/N;

    // distributing rows between processes
    int div = M/P, rem = M%P, ind = 0;
    for (int i = 0; i < P; i++)
    {
        rows[i] = div;
        if (rem > 0)
        {
            rows[i]++;
            rem--;
        }
        rowstart[i] = ind;
        ind += rows[i];
    }

    // distributing CSR matrix
    for (int i = 0; i < P; i++)
    {
        sendcounts[i] = rowptr[rowstart[i] + rows[i]] - rowptr[rowstart[i]];
        displs[i] = rowptr[rowstart[i]];
    }
    // allocating my_val and my_colidx vectors
    my_val = (double *)malloc(sizeof(double) * sendcounts[myrank]);
    my_colidx = (int *)malloc(sizeof(int) * sendcounts[myrank]);

    // scattering
    MPI_Scatterv(matrix.csrVal, sendcounts, displs, MPI_DOUBLE, my_val, sendcounts[myrank], MPI_DOUBLE, 0, MPI_COMM_WORLD);
    MPI_Scatterv(matrix.csrColIdx, sendcounts, displs, MPI_INT, my_colidx, sendcounts[myrank], MPI_INT, 0, MPI_COMM_WORLD);

    // allocating vector result
    result = (double *)malloc(sizeof(double) * rows[myrank]);

    // starting computation part
    double t1, t2;

    MPI_Barrier(MPI_COMM_WORLD);
    if (myrank == 0)
    {
        t1 = MPI_Wtime();
    }

    int i0 = rowstart[myrank], j0 = rowptr[i0];
    for(int k = 0; k < time_steps; k++)
    {
        for(int i = i0; i < i0 + rows[myrank]; i++)
        {
            result[i - i0]=0.0;
            for(int j = rowptr[i]; j < rowptr[i+1]; j++)
            {
                    result[i - i0] += my_val[j - j0] * rhs[my_colidx[j - j0]];
            }
        }
        MPI_Allgatherv(result, rows[myrank], MPI_DOUBLE, rhs, rows, rowstart, MPI_DOUBLE, MPI_COMM_WORLD);
    }

    MPI_Barrier(MPI_COMM_WORLD);
    if (myrank == 0)
    {
        t2 = MPI_Wtime();

        double time_taken = t2 - t1;
        cout << "Time taken by program is : " << fixed << time_taken << setprecision(5);
        cout << " sec " << endl;

        // checking some values to compare with serial
        //cout<<endl<<rhs[0]<<endl<<rhs[1000]<<endl<<rhs[N-1]<<endl;
    }

    MPI_Finalize();

    return EXIT_SUCCESS;
}
