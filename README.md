# RPM-Build Reusable Workflow

## About

This repo provides a [reusable workflow for GitHub Actions](https://docs.github.com/en/actions/learn-github-actions/reusing-workflows)
that can be used to build RPM packages given some source and a `.spec` file.

## Usage

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    steps:

      - name: Determine Version
        id: version
        uses: riege/action-version@v1

      # build your build artifact, e.g. a .tgz file...

      - name: Upload build artifact for RPM job
        uses: actions/upload-artifact@v2
        with:
          name: tgz
          path: some/build/path/*.tgz

    outputs:
      rpm_version: ${{ steps.version.outputs.version-without-v }}

  rpmbuild:
    needs: release
    uses: "riege/rpm-build/.github/workflows/rpm-build.yml@main"
    with:
      rpm_name: my-package-name
      rpm_version: ${{ needs.release.outputs.rpm_version }}
      rhel_version: 7
      rpm_source_path: path/to/rpm/sources
      build_artifact: tgz
    secrets:
      sign_key: "... my GPG sign key, usually a secret ..."
      sign_key_passphrase: "... my sign key passphrase, usually a secret ..."

  rpm_post_process:
    needs: rpmbuild
    runs-on: ubuntu-latest
    steps:
      - name: Download RPM from Workflow
        uses: actions/download-artifact@v2
        with:
          name: rpms

      - name: Post Process RPM
        run: |
          # upload all RPMs
          find . -name "*.rpm" -exec echo RPM {} uploaded \;
```

## How it works

As you might have guessed the actual workflow building the RPM is in job
`rpmbuild` in the example above. We'll get to the other jobs (`release` and
`rpm_post_process`) later. Roughly the workflow does the following:

1. The workflow expects a SPEC file `<rpm_name>-<rpm_version>.spec` and a
`SOURCES` folder at the path specified by input parameter `rpm_source_path`
(defaults to ".").
2. The workflow will create a `.tgz` archive from the files inside `SOURCES`
and runs `rpmbuild` from a custom Docker container image on these files
producing a `.rpm` file.
3. This RPM file will then be uploaded as workflow artifact under the name
`rpms` for later use.

### Disclaimer

**Building RPMs isn't magic!** You need to provide a carefully authored `.spec`
file that properly packages the files you provide. It's totally up to you how
you do this. You need to have deep knowledge how your build artifacts are
structured and which commands to issue to install the files on the host system.

### Prerequisites

You will need a `.spec` file and a `SOURCES` folder containing the files to be
packaged in some directory. This can be the root directory of your repository
(if your RPM only contains configuration files for example) or something like
`src/main/rpm` for e.g. Java applications. This directory will be passed as
input parameter `rpm_source_path` to the reusable workflow and default to the
current directory "." (aka the root of your repository).

### RPM Version

The `rpm-build` workflow requires a version number. The recommendation is to
use some GitHub action to determine such a version number (e.g.
`riege/action-version`) in a preceding job and pass this version number as
job output to the `rpm-build` job.

### Build Artifacts

If you want to package an application that consists of one or many build
artifacts (e.g. a `tgz` archive) you need to build and upload these artifacts
in a previously executed job. See job `release` in the example above. Use any
artifact name you like (here: `tgz`). This artifact name must then be passed
as optional input parameter `build_artifact` to the `rpm-build` workflow. The
build artifacts will then be copied to the `SOURCES` directory before
`rpmbuild` is being run. The SPEC file is responsible for proper processing of
the build artifact.

Providing a build artifact is **optional**. If your RPM only contains
configuration files or anything else in its own `SOURCES` directory you may
omit any job that produces a build artifact and also the optional
`build_artifact` input parameter. Note that you might possibly still need a
preceding job to determine a RPM version number.

### Post Process RPM

If you want to e.g. upload the built RPM files you need a subsequent workflow
job that first downloads the produced RPM from the `rpmbuild` job. Also the
workflow needs a `needs: rpmbuild` specification so that it waits for the
`rpmbuild` job to be finished first. See job `rpm_post_process` in the example
above.

## Input Parameters

| Parameter | Required | Description |
| --- | --- | --- |
| `rpm_name` | `true` | Name of RPM package. |
| `rpm_version` | `true` | Version to be built. Usually a semver version. Note that RPM doesn't allow arbitrary characters in version numbers. |
| `rpm_release` | `false` | The release number of the RPM version. Defaults to the GitHub workflow run number. |
| `rhel_version` | `false` | Version of RHEL (Default: 8). |
| `rpm_source_path` | `false` | Path to the directory containing rpm SOURCES and spec file (Default: '.'). |
| `build_artifact` | `false` | Optional: name of uploaded build artifact that should be put into SOURCES folder before building. |

## Input Secrets

As the reusable workflow doesn't have access to the parent workflows secrets
you must pass them as secrets.

| Secret | Description |
| --- | --- |
| `sign_key` | Key to sign the RPM. |
| `sign_key_passphrase` | Passphrase for sign key. |
