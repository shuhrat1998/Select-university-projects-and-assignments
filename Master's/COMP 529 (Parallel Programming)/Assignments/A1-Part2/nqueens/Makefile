include ./arch

OBJ = nqueens_ser.o
OBJ0 = nqueens_serC.o
OBJ1	= nqueens_parA.o
OBJ2	= nqueens_parB.o
OBJ3	= nqueens_parC.o

LDLIBS =

CFLAGS = -g 

   
nqueens_parB:	        $(OBJ2)
		$(CC) $(LDFLAGS) -o $@ $(OBJ2)  $(LDLIBS)

nqueens_parA:	        $(OBJ1)
		$(CC) $(LDFLAGS) -o $@ $(OBJ1)  $(LDLIBS)

nqueens_parC:	        $(OBJ3)
		$(CC) $(LDFLAGS) -o $@ $(OBJ3)  $(LDLIBS)

nqueens_ser:	        $(OBJ)
		$(CC) $(LDFLAGS) -o $@ $(OBJ)  $(LDLIBS)

nqueens_serC:	        $(OBJ0)
		$(CC) $(LDFLAGS) -o $@ $(OBJ0)  $(LDLIBS)

clean:
	$(RM) *.o nqueens_parB *~;
	$(RM) *.o nqueens_parA *~;
	$(RM) *.o nqueens_parC *~;
	$(RM) *.o nqueens_ser *~;
	$(RM) *.o nqueens_serC *~;
	$(RM) core;
	$(RM) PI*;
