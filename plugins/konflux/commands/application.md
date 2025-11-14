---
description: Manage Konflux application
---

## Name
konflux:application

## Synopsis

```bash
/konflux:application status <application>
```

## Description
The `konflux:application` command to manage Konflux application.

This command helps you:
- List all components in the application
- Understand the status of the components in the application - last build, snapshots, releases

## Implementation

### Subcommand: status

The command performs the following steps:

1. **Prerequisites Check**:
    - Verify `oc` CLI is installed: `which oc`
    - Verify cluster access: `oc whoami`
    - If not installed or not authenticated, provide clear instructions
    - Verify `jq` CLI is installed: `which jq`
    - Verify `git` CLI is installed: `which git`
    - Verify the current directory is a Git repository: `git remote -v`

2. **Parse Arguments**:
    - `application`: Application name (required)

3. **List components that belong to the application**:
    - Get components
      ```bash
      kubeclt get component -o yaml | jq '.items[] | select(.spec.application=="{application}")
      ```
    - The application name is provided in `.spec.application`
    - The component name is provided in `.spec.componentName`
    - The Git repository URL is provided in `.spec.source.git.url`
    - The commit SHA is provided in `.status.lastBuiltCommit`
 
4. **Get Git information**:
    - Use the Git repository URL and commit SHA to obtain the Git branch name and commit message
    - Use `git branch -a --contains <commit-sha>` to find the branch name

5. **Get Snapshots**:
    - Get snapshots of each component and order by oldest
      ```bash
      kubectl get snapshot -l pac.test.appstudio.openshift.io/sha={commit},appstudio.openshift.io/component={component} --sort-by=.metadata.creationTimestamp
      ```

7. **Get Releases**:
    - Get releases object for each snapshot
      ```bash
      kubectl get release -l pac.test.appstudio.openshift.io/sha={commit},appstudio.openshift.io/component={component}
      ```
    - The snapshot is specified in `.spec.snapshot`
    - The `.status.conditions` show if the release failed or succeeded
      ```

5. **Display result**:
   - Display the result for each component:
     ```
     | Component        | Built SHA | Commit Message              | Git Branch   | Snapshots (oldest first) |
     |------------------|-----------|-----------------------------|--------------|--------------------------|
     | {component}      | {commit}  | {commit-message}            | {git-branch} | {snapshots}              |
     | otel-bundle-main | 8ba2e60   | Fix service account (#693)  | main         | otel-main-jnhfz          |
     ```
   - Display snapshot with release information for each snapshot per component
     ```
     Component: {component}
     | Snapshot        | Release                       | Release status                           |
     |-----------------|-------------------------------|------------------------------------------|
     | {snapshot}      | {release}                     | {release-status}                         |
     | otel-main-jnhfz | otel-main-jnhfz-8ba2e60-nnwnp | Failed (ManagedPipelineProcessed failed) |
     ```

## Return Value
- **status**: Table of all components that belong to the provided application

## Examples

1. **Get status all components of the otel-main application**:
   ```bash
   /konflux:application status otel-main
   ```

## Arguments

### status

- **application** (required): Name of the Konflux application

## Troubleshooting


## Related Commands

* `/konflux:component status <component>` - Show component status
* `/konflux:component build <components> [--wait <duration>] [--nudge]` - Trigger component build

## Additional Resources

- [Konflux upstream documentation](https://konflux-ci.dev/docs/)
- [Konflux architecture documentation](https://github.com/konflux-ci/architecture)
