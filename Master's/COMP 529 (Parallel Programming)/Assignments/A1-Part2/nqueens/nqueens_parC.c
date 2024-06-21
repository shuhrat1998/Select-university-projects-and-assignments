/*
Code:   N queens (parallel version)
Course: COMP 529 (A1-Part2C)
Name:   Shukhrat Khuseynov
ID:     0070495
*/

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <omp.h>

#define MATCH(s) (!strcmp(argv[ac], (s)))
bool SOLUTION_EXISTS = false;
int N = 8; // N is 8 by default, unless input is given.

bool can_be_placed(int board[N][N], int row, int col)
{
    int i, j;

    /* Check this row on left side */
    for (i = 0; i < col; i++)
        if (board[row][i])
            return false;

    /* Check upper diagonal on left side */
    for (i=row, j=col; i>=0 && j>=0; i--, j--)
        if (board[i][j])
            return false;

    /* Check lower diagonal on left side */
    for (i=row, j=col; j>=0 && i<N; i++, j--)
        if (board[i][j])
            return false;

    return true;
}

void print_solution(int board[N][N])
{
    int i, j;
    static int k = 1;

    printf("Solution #%d-\n",k++);

    for (i = 0; i < N; i++)
    {
        for (j = 0; j < N; j++)
            printf(" %d ", board[i][j]);
        printf("\n");
    }
    printf("\n");
}

void solve_NQueens(int board[N][N], int col)
{
    if (col == N)
        #pragma omp critical
        {
            //print_solution(board);
            SOLUTION_EXISTS = true;
        }

    int i;
    for (i = 0; (i < N && col<N) && (!SOLUTION_EXISTS); i++)
    {
        #pragma omp task firstprivate(i, col)
        {
            if ( can_be_placed(board, i, col) )
            {
                // creating own private copy of board matrix
                // since firstprivate(board) does not help
                int buffer[N][N], k, j;
                memset(buffer, 0, sizeof(buffer));
                for (k = 0; k < N; k++)
                    for (j = 0; j < N; j++)
                        if (board[k][j]) buffer[k][j] = board[k][j];

                buffer[i][col] = 1;
                solve_NQueens(buffer, col + 1);
            }
        }
    }
    #pragma omp taskwait
    return;
}

int main(int argc,char **argv)
{
    int ac;
    /* Over-ride N with command-line input parameter (if any) */
    for(ac=1;ac<argc;ac++)
    {
        if(MATCH("-n")) {N = atoi(argv[++ac]);}
        else {
            printf("Usage: %s [-n <N>]\n",argv[0]);
            return(-1);
        }
    }

    int board[N][N];
    memset(board, 0, sizeof(board));
    double time1 = omp_get_wtime();

    // starting parallel region for the coming tasks
    #pragma omp parallel shared(SOLUTION_EXISTS)
        #pragma omp single
            solve_NQueens(board, 0);

    if (SOLUTION_EXISTS == false)
    {
        printf("No Solution Exists! \n");
    }
    printf("Elapsed time: %0.2lf\n", omp_get_wtime() - time1);
    return 0;
}
