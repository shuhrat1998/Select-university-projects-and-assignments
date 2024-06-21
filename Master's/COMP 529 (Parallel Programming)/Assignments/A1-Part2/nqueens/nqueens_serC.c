#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <omp.h>

#define MATCH(s) (!strcmp(argv[ac], (s)))
bool SOLUTION_EXISTS = false;
int N = 8; // N is 8 by default

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

bool solve_NQueens(int board[N][N], int col)
{

    if (col == N)
    {
        //print_solution(board);
        SOLUTION_EXISTS = true;
        return true;
    }

    int i;
    for (i = 0; i < N && (!SOLUTION_EXISTS); i++)
    {
        if ( can_be_placed(board, i, col) )
        {
            board[i][col] = 1;
            SOLUTION_EXISTS = solve_NQueens(board, col + 1) || SOLUTION_EXISTS;
            board[i][col] = 0;
        }
    }
    return SOLUTION_EXISTS;
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

    solve_NQueens(board, 0);

    if (SOLUTION_EXISTS == false)
    {
        printf("No Solution Exists! \n");
    }
    printf("Elapsed time: %0.2lf\n", omp_get_wtime() - time1);
    return 0;
}
