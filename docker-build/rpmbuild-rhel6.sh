#!/usr/bin/env bash

# need to change ownership because of "Bad owner/group" error otherwise
chown -R root:root /rpmbuild
spectool -g -R /rpmbuild/SPECS/"$RPM_NAME".spec || exit 1
rpmbuild -bb /rpmbuild/SPECS/"$RPM_NAME".spec || exit 1
RPMFILE=$(find "/rpmbuild/RPMS" -name "*.rpm") || exit 1

chmod 666 "$RPMFILE"
