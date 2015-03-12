PREFIX=/tmp
DESTBINDIR=$(PREFIX)/bin
DESTLIBDIR=$(PREFIX)/lib
CFLAGS=

BINARIES=test0 test1 test2 test3 test4
BINARIES_AFTERINSTALL=test4-2 test4-3

all: $(BINARIES)

install: test3 test4
	install -c test3 $(DESTBINDIR)/
	install -c libfunc2.dylib $(DESTLIBDIR)/
	install -c libfunc3.dylib $(DESTLIBDIR)/
	install -c libfunc4.dylib $(DESTLIBDIR)/
	install -c libfunc4.a $(DESTLIBDIR)/
	ranlib $(DESTLIBDIR)/libfunc4.a
	install -c test4 $(DESTBINDIR)/

clean:
	rm -rf *.o *.dylib *.a $(BINARIES) $(BINARIES_AFTERINSTALL)

test0: test0.o
	$(CC) -o $@ $^

test1: test1.c libfunc1.a
	$(CC) -o $@ test1.c -L. -lfunc1

test2: test2.c libfunc2.dylib
	$(CC) -o $@ test2.c -L. -lfunc2 -Wl,-rpath,.

test3: test3.c libfunc3.dylib
	$(CC) -o $@ test3.c -L. -lfunc3 -Wl,-rpath,$(DESTLIBDIR)

test4: test4.c libfunc4.dylib
	$(CC) -o $@ test4.c -L. -lfunc4

test4-2: test4.c $(DESTLIBDIR)/libfunc4.dylib
	$(CC) -o $@ test4.c -L$(DESTLIBDIR) -lfunc4

# OS Xだと、以下のコマンドでtest4-3を生成しようとすると、-lcrt0が見つからなくて
# エラーになる
test4-3: test4.c $(DESTLIBDIR)/libfunc4.a
	$(CC) -o $@ -static test4.c -L$(DESTLIBDIR) -lfunc4

libfunc1.a: func1.o
	$(AR) -rc $@ $^

libfunc2.dylib: func2.o
	$(CC) -shared -install_name @rpath/$@ -o $@ $^

libfunc3.dylib: func3.o libfunc2.dylib
	$(CC) -shared -install_name @rpath/$@ -o $@ func3.o -L. -lfunc2 -Wl,-rpath,$(DESTLIBDIR)

libfunc4.dylib: func4.o
	libtool -dynamic -o $@ -install_name $(DESTLIBDIR)/$@ $^
	libtool -static -o libfunc4.a $^

func2.o: func2.c
	$(CC) -c -fPIC $^

func3.o: func3.c
	$(CC) -c -fPIC $^

func4.o: func4.c
	$(CC) -c -fPIC $^
