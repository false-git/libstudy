PREFIX=/usr/local
DESTBINDIR=$(PREFIX)/bin
DESTLIBDIR=$(PREFIX)/lib
CFLAGS=

all: test0 test1 test2 test3

install: test3
	install -c test3 $(DESTBINDIR)/
	install -c libfunc2.so $(DESTLIBDIR)/
	install -c libfunc3.so $(DESTLIBDIR)/

clean:
	rm -f *.o *.so *.a test0 test1 test2 test3

test0: test0.o
	$(CC) -o $@ $>

test1: test1.c libfunc1.a
	$(CC) -o $@ test1.c -L. -lfunc1

test2: test2.c libfunc2.so
	$(CC) -o $@ test2.c -L. -lfunc2 -Wl,-rpath,.

test3: test3.c libfunc3.so
	$(CC) -o $@ test3.c -L. -lfunc3 -Wl,-rpath,$(DESTLIBDIR) -Wl,-rpath-link,.

libfunc1.a: func1.o
	$(AR) -rc $@ $>

libfunc2.so: func2.o
	$(CC) -shared -o $@ $>

libfunc3.so: func3.o libfunc2.so
	$(CC) -shared -o $@ func3.o -L. -lfunc2 -Wl,-rpath,$(DESTLIBDIR)

func2.o: func2.c
	$(CC) -c -fPIC $>

func3.o: func3.c
	$(CC) -c -fPIC $>
