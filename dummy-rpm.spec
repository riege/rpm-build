Summary: Dummy package for testing the build workflow of this repository
Name: %{name}
Version: %{version}
Release: %{release}
License: UPL
Group: System Environment/Base

Packager: René Burghardt <rburghardt@riege.com>
Vendor: Riege Software International GmbH
Distribution: RHEL
URL:  https://github.com/riege/rpm-build

###  Source Files (place in SOURCES folder)
Source0: %{name}.tgz

# Build definitions
BuildArchitectures: noarch
Buildroot: %{_builddir}/%{name}

### Conflicts: Use to block other packages.
# Blocking older packages prevents multiple installations.
Conflicts: %{name} < %{version}-%{release}

### Long package description
%description
Dummy package for testing the build workflow of this repository.

%prep
%setup -c -n %{name}

### Put scripts in here to be executed before installing the files
%pre

%install
cd  %{_builddir}/%{name}
mkdir -p "$RPM_BUILD_ROOT/"
cp -R * "$RPM_BUILD_ROOT/"
:

### Put scripts in here to be executed after installing the files
%post

### Put scripts in here to be executed before uninstalling the files
%preun

### Put scripts in here to be executed after uninstalling the files
%postun

### Compiling / Building files
%build

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT

### PUT ALL FILES TO BE USED IN HERE
%files
%attr(0666,root,root) /tmp/hello_world.txt

%changelog
* Mon Jan 27 2014 René Burghardt <rburghardt@riege.com> (0.0.1)
- Initial Version
