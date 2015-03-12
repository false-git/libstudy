PREFIX=/usr/local
DESTBINDIR=$(PREFIX)/bin
DESTLIBDIR=$(PREFIX)/lib
CFLAGS=

BINARIES=test0 test1 test2 test3 test4
BINARIES_AFTER_INSTALL=test4-2 test4-3

all: $(BINARIES)

install: test3 test4
	install -c test3 $(DESTBINDIR)/
	install -c libfunc2.so $(DESTLIBDIR)/
	install -c libfunc3.so $(DESTLIBDIR)/
	libtool --mode=install install -c libfunc4.la $(DESTLIBDIR)/
	libtool --mode=install install -c test4 $(DESTBINDIR)/

clean:
	rm -rf .libs *.o *.so *.a *.lo *.la $(BINARIES) $(BINARIES_AFTER_INSTALL)

test0: test0.o
	$(CC) -o $@ $>

test1: test1.c libfunc1.a
	$(CC) -o $@ test1.c -L. -lfunc1

test2: test2.c libfunc2.so
	$(CC) -o $@ test2.c -L. -lfunc2 -Wl,-rpath,.

test3: test3.c libfunc3.so
	$(CC) -o $@ test3.c -L. -lfunc3 -Wl,-rpath,$(DESTLIBDIR) -Wl,-rpath-link,.

test4: test4.c libfunc4.la
	libtool --mode=link $(CC) -o $@ $>

test4-2: test4.c $(DESTLIBDIR)/libfunc4.la
	$(CC) -o $@ test4.c -L$(DESTLIBDIR) -lfunc4

test4-3: test4.c $(DESTLIBDIR)/libfunc4.la
	$(CC) -o $@ -static test4.c -L$(DESTLIBDIR) -lfunc4

libfunc1.a: func1.o
	$(AR) -rc $@ $>

libfunc2.so: func2.o
	$(CC) -shared -o $@ $>

libfunc3.so: func3.o libfunc2.so
	$(CC) -shared -o $@ func3.o -L. -lfunc2 -Wl,-rpath,$(DESTLIBDIR)

libfunc4.la: func4.lo
	libtool --mode=link $(CC) -o $@ $> -rpath $(DESTLIBDIR)

func2.o: func2.c
	$(CC) -c -fPIC $>

func3.o: func3.c
	$(CC) -c -fPIC $>

func4.lo: func4.c
	libtool --mode=compile $(CC) -c $>
