#!/usr/bin/env bash

KEYFILE=/rpmbuild/rpm_signing_key.gpg
KEYID="$(gpg --with-colons "$KEYFILE" | head -n1 | cut -d : -f 5)"

find /rpmbuild/SOURCES/ -iname .gitkeep -delete

tar -czvf /rpmbuild/SOURCES/"$RPM_NAME".tgz -C /rpmbuild/SOURCES/ .

gpg --import "$KEYFILE"
echo "
%_signature gpg
%_gpg_name $KEYID
%_topdir /rpmbuild
%release $GITHUB_RUN_NUMBER
%name $RPM_NAME
%version $GITHUB_REF_NAME
%debug_package %{nil}
" > ~/.rpmmacros

rpmbuild --undefine=_disable_source_fetch -bb /rpmbuild/SPECS/"$RPM_NAME".spec

RPMFILE=$(find "/rpmbuild/RPMS" -name "*.rpm")

/usr/bin/expect -df /rpmexpect "$RPMFILE" "$RPM_SIGN_KEY_PASSPHRASE"
