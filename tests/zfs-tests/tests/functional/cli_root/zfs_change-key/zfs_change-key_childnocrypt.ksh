#!/bin/ksh -p
#
# CDDL HEADER START
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# CDDL HEADER END

#
# Copyright 2019 Joyent, Inc.
#

. $STF_SUITE/include/libtest.shlib
. $STF_SUITE/tests/functional/cli_root/zfs_load-key/zfs_load-key_common.kshlib

#
# DESCRIPTION:
# 'zfs change-key' on a dataset with unencrypted children should not panic.
#
# STRATEGY:
# 1. Create a parent encrypted dataset
# 2. Create an encrypted child dataset, using the parent as its encryption root
# 3. Create an unencrypted child dataset
# 4. Change the key in the parent

verify_runnable "both"

function cleanup
{
	datasetexists $TESTPOOL/$TESTFS1 && \
		log_must zfs destroy -r $TESTPOOL/$TESTFS1
}
log_onexit cleanup

log_assert "'zfs change-key' should not panic when unencrypted children are" \
	"present"

log_must eval "echo $PASSPHRASE | zfs create -o encryption=on" \
	"-o keyformat=passphrase -o keylocation=prompt $TESTPOOL/$TESTFS1"

log_must zfs create $TESTPOOL/$TESTFS1/child_encrypted
log_must verify_encryption_root $TESTPOOL/$TESTFS1/child_encrypted \
	$TESTPOOL/$TESTFS1

log_must zfs create -o encryption=off $TESTPOOL/$TESTFS1/child_unencrypted

log_must eval "echo $PASSPHRASE2 | zfs change-key $TESTPOOL/$TESTFS1"

log_pass "'zfs change-key' must not panic when unencrypted children are present"
