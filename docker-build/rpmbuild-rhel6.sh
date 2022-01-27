#!/usr/bin/env bash -x

rpmbuild -bb /rpmbuild/SPECS/"$RPM_NAME".spec || exit 1
RPMFILE=$(find "/rpmbuild/RPMS" -name "*.rpm") || exit 1

chmod 666 "$RPMFILE"
