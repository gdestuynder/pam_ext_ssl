CC = gcc
LDFLAGS =  
CPPFLAGS =  -DPACKAGE_NAME=\"pam_ext_ssl\" -DPACKAGE_TARNAME=\"pam_ext_ssl\" -DPACKAGE_VERSION=\"0.1\" -DPACKAGE_STRING=\"pam_ext_ssl\ 0.1\" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE_URL=\"\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -D__EXTENSIONS__=1 -D_ALL_SOURCE=1 -D_GNU_SOURCE=1 -D_POSIX_PTHREAD_SEMANTICS=1 -D_TANDEM_SOURCE=1 -DHAVE_SECURITY_PAM_APPL_H=1 -DHAVE_SECURITY_PAM_MODULES_H=1 -DHAVE_LIBPAM=1
CFLAGS = -g -O2 `curl-config --cflags`
LIBS = -lpam  `curl-config --libs`
SHOBJFLAGS = -fPIC -DPIC
SHOBJLDFLAGS = -shared -rdynamic

PREFIX = /usr/local
prefix = $(PREFIX)
exec_prefix = ${prefix}
libdir = ${exec_prefix}/lib
security_dir = $(libdir)/security

all: pam_ext_ssl.so

pam_ext_ssl.o: pam_ext_ssl.c
pam_ext_ssl.so: pam_ext_ssl.o

%.o:
	$(CC) $(SHOBJFLAGS) $(CFLAGS) $(CPPFLAGS) -o "$@" -c $(filter %.c, $^)

%.so:
	$(CC) $(SHOBJFLAGS) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(SHOBJLDFLAGS) -o "$@" $(filter %.o, $^) $(LIBS)
	objcopy --keep-global-symbols=pam_ext_ssl.syms "$@"
	objcopy --discard-all "$@"

clean:
	rm -f pam_ext_ssl.o
	rm -f pam_ext_ssl.so

distclean: clean
	rm -f Makefile pam_ext_ssl.syms config.log config.status
	rm -rf autom4te.cache

mrproper: distclean
	rm -f configure aclocal.m4

install: pam_ext_ssl.so
	rm -f "$(DESTDIR)$(security_dir)/pam_ext_ssl.so"
	mkdir -p "$(DESTDIR)$(security_dir)"
	cp pam_ext_ssl.so "$(DESTDIR)$(security_dir)/pam_ext_ssl.so"
	chmod 755 "$(DESTDIR)$(security_dir)/pam_ext_ssl.so"
	-chown root:root "$(DESTDIR)$(security_dir)/pam_ext_ssl.so"

.PHONY: all clean distclean install
