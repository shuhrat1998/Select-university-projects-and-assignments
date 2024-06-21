include ./arch

OBJ1	= life.o real_rand.o plot.o timer.o
OBJ	= life_parallel.o real_rand.o plot.o timer.o

LDLIBS =

CFLAGS = -g 

   
life_parallel:	        $(OBJ)
		$(CC) $(LDFLAGS) -o $@ $(OBJ)  $(LDLIBS)

life:	        $(OBJ1)
		$(CC) $(LDFLAGS) -o $@ $(OBJ1)  $(LDLIBS)


clean:
	$(RM) *.o life_parallel *~;
	$(RM) core;
	$(RM) PI*;
