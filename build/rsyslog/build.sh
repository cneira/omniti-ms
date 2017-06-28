#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=rsyslog
VER=8.27.0
VERDEV=8
VERHUMAN="$VER (v${VERDEV}-stable)"
PKG=omniti/logging/rsyslog
SUMMARY="The enhanced syslogd for Linux and Unix"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="developer/parser/bison omniti/library/python-2/docutils library/security/openssl omniti/security/libguardtime omniti/security/guardtime omniti/library/libee omniti/library/libestr omniti/library/json-c omniti/library/uuid omniti/security/libgcrypt omniti/library/liblogging-stdlog omniti/library/pkgconf developer/build/autoconf developer/build/automake developer/build/libtool"
DEPENDS_IPS="library/security/openssl omniti/security/libguardtime omniti/security/guardtime omniti/library/libee omniti/library/libestr omniti/library/json-c omniti/library/uuid omniti/security/libgcrypt omniti/library/liblogging-stdlog"

CFLAGS="-I/opt/omni/include -I/opt/omni/include/json-c"
CFLAGS64="-I/usr/include/amd64 -I/opt/omni/include/amd64 $CFLAGS64"
LDFLAGS64=" -mimpure-text -L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64"
ACLOCAL_PATH=/opt/omni/share/aclocal

CONFIGURE_OPTS="--enable-imfile --enable-imsolaris --enable-omprog --enable-omuxsock --enable-omstdout --enable-guardtime --enable-diagtools --enable-usertools --disable-generate-man-pages"

run_autoconf() {
    export ACLOCAL_PATH
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "--- Running autoreconf -fvi"
    logcmd autoreconf -fvi
}

build32_opts() {
    CFLAGS="-DHAVE_LSEEK64 $CFLAGS"
    LDFLAGS="-L/opt/omni/lib -R/opt/omni/lib"
    LIBESTR_CFLAGS="$CFLAGS"
    LIBESTR_LIBS="$LDFLAGS -lestr"
    LIBEE_CFLAGS="$CFLAGS"
    LIBEE_LIBS="$LDFLAGS -lee"
    JSON_C_CFLAGS="$CFLAGS"
    JSON_C_LIBS="$LDFLAGS -ljson-c"
    LIBUUID_CFLAGS="$CFLAGS"
    LIBUUID_LIBS="$LDFLAGS -luuid"
    GUARDTIME_CFLAGS="$CFLAGS"
    GUARDTIME_LIBS="$LDFLAGS -lgtbase -lgthttp -lgtpng"
    LIBLOGGING_STDLOG_CFLAGS="$CFLAGS"
    LIBLOGGING_STDLOG_LIBS="$LDFLAGS -llogging-stdlog"
    export LIBESTR_CFLAGS LIBESTR_LIBS \
           LIBEE_CFLAGS LIBEE_LIBS \
           JSON_C_CFLAGS JSON_C_LIBS \
           LIBUUID_CFLAGS LIBUUID_LIBS \
           GUARDTIME_CFLAGS GUARDTIME_LIBS \
           LIBLOGGING_STDLOG_CFLAGS LIBLOGGING_STDLOG_LIBS
    export PATH=/opt/omni/bin:/opt/python26/bin:$PATH
}

build64_opts() {
    LIBESTR_CFLAGS="$CFLAGS64"
    LIBESTR_LIBS="$LDFLAGS64 -lestr"
    LIBEE_CFLAGS="$CFLAGS64"
    LIBEE_LIBS="$LDFLAGS64 -lee"
    JSON_C_CFLAGS="$CFLAGS"
    JSON_C_LIBS="$LDFLAGS64 -ljson-c"
    LIBUUID_CFLAGS="$CFLAGS64"
    LIBUUID_LIBS="$LDFLAGS64 -luuid"
    GUARDTIME_CFLAGS="$CFLAGS64"
    GUARDTIME_LIBS="$LDFLAGS64 -lgtbase -lgthttp -lgtpng"
    LIBLOGGING_STDLOG_CFLAGS="$CFLAGS"
    LIBLOGGING_STDLOG_LIBS="$LDFLAGS -llogging-stdlog"
    export LIBESTR_CFLAGS LIBESTR_LIBS \
           LIBEE_CFLAGS LIBEE_LIBS \
           JSON_C_CFLAGS JSON_C_LIBS \
           LIBUUID_CFLAGS LIBUUID_LIBS \
           GUARDTIME_CFLAGS GUARDTIME_LIBS \
           LIBLOGGING_STDLOG_CFLAGS LIBLOGGING_STDLOG_LIBS
    export PATH=/opt/omni/bin/amd64:/usr/bin/amd64:/opt/python26/bin:$PATH
}

copy_manifest() {
    # SMF manifest
    logmsg "--- Copying SMF manifest"
    logcmd mkdir -p ${DESTDIR}/lib/svc/manifest/system
    logcmd cp $SRCDIR/files/rsyslogd.xml ${DESTDIR}/lib/svc/manifest/system
}

copy_config() {
    logmsg "--- Copying config files"
    logcmd mkdir -p ${DESTDIR}/${PREFIX}/etc/rsyslog.d
    logcmd cp $SRCDIR/files/rsyslog.conf ${DESTDIR}/${PREFIX}/etc/rsyslog.conf
}

init
download_source $PROG $PROG ${VER}
patch_source
prep_build
#run_autoconf
#build32_opts
#build32
build64_opts
build64
make_isa_stub
copy_manifest
copy_config
VER=${VER}.${VERDEV}
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
