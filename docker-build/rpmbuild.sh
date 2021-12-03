#!/usr/bin/env bash

tar -czvf /rpmbuild/SOURCES/"$RPM_NAME".tgz -C "$PWD"/SOURCES/ .

rpmbuild --undefine=_disable_source_fetch --sign -ba /rpmbuild/SPECS/"$RPM_NAME".spec \
         --define "release $GITHUB_RUN_NUMBER" \
         --define "name $RPM_NAME" \
         --define "version $GITHUB_REF_NAME"

RPMFILE=$(find "/rpmbuild/RPMS" -name "*.rpm")

KEYFILE=/rpmbuild/RPM_SIGN_KEY

echo "$RPM_SIGN_KEY" > "$KEYFILE"

KEYID="$(gpg --with-colons "$KEYFILE" | head -n1 | cut -d : -f 5)"

gpg --import "$KEYFILE"
echo "
%_signature gpg
%_gpg_name $KEYID
" > ~/.rpmmacros

chmod +x ./rpmexpect
./rpmexpect "$RPMFILE" "$BSIGNPASSWORD"
