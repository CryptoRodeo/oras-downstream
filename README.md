# Upstream/Downstream git module solution (ROUGH DRAFT)
**Draft Version:** -1

# Basic definitions
- **Upstream repo**: The open source project repo we want to track, sync and pull in.
- **Downstream repo**: The Red Hat product repo holding the git submodule reference(s) to the upstream repo.
- **Git Submodule**:
  - A repository within another repository.
  - It allows you to include and track the contents of an external repository (upstream in this case) within your own project (downstream).
  - Useful when you want to include third-party libraries or other code that is managed separately but needs to be part of your project.
- **Konflux**: A platform to automate the process of building, testing, and releasing applications.
- **Konflux CI**: The Tekton pipelines used to build, test and release the software/product artifacts.
- **Workspace**:
  - A Kubernetes namespace managed by an individual or a group.
  - All Tekton Pipelines, including build, test, and release, run within a workspace.
- **Component**:
  - An internal representation of a software artifact that Konflux builds and tests, using source code from a git repository.
  - Components are stored in an OCI container registry such as quay.io after they are built.
- **Application**: 1 or more components running together for building and releasing.

For more Konflux specific definitions, see the [official glossary](https://konflux-ci.dev/docs/glossary/).

# About
This repo demonstrates a container-first approach to move code from an upstream repository to an internal Red Hat product repository, using Git submodules and Konflux.

This repo:
- has been onboarded onto Konflux as an application component
- is configured with MintMaker to detect and sync any changes on:
  - the upstream git submodule reference
  - Containerfile image digests
- is configured in Konflux to pull changes from this component, build the software artifacts, and runs tests.

**NOTE**:
Consider this demo repo and documentation as a **guideline** for achieving an upstream to downstream sync, with Konflux.
**Do not** consider this guideline as officially supported by Konflux, rather it is a "pattern" to follow, replicate and modify
for your specific situation, if that situation involves git submodules.

## How this solution pattern works
1. Create a "downstream" repo in github.
2. Track your upstream git repo with a git submodule reference.
3. Onboard to Konflux, use [Renovate](https://github.com/renovatebot/renovate) to keep your Git submodule references up to date
4. In your downstream repo, apply patches in your Containerfile if you need to carry downstream patches.

# Implementing this solution pattern
## Create a downstream repo
The downstream repo will:
- be used to hold the git submodule reference to the upstream repository.
- contain a Containerfile that references and pulls in the git submodule(s) content.
- become a Component of our Konflux application.

## Create the git submodule for the upstream repo to track it
After creating the downstream repo, add a git submodule for the upstream repo:
```bash
git submodule add <upstream-url>
```

Check and configure the git submodule config:
```
# .gitmodules
[submodule "oras"]
  path = oras
  url = https://github.com/oras-project/oras.git
  branch = main # Ensure the branch is correct
```

See the [Git documentation](https://git-scm.com/docs/gitsubmodules) for more details.

## Onboard onto to Konflux
After creating the repository, onboard to Konflux and configure your application and its components.
---
**Note:**
The [official Konflux docs](https://konflux-ci.dev/docs/getting-started/) are currently geared towards configuring YAML files.
> At the time of publication, to create applications in Konflux, you need to manually configure them by editing YAML files

This repo was configured using the Konflux UI.
There does not seem to be any detailed steps on how to do this yet via the UI.
---

Here are some **brief** steps on onboarding to Konflux using the UI:
- Create an application in your workspace.
- Configure your application component.
- If you're using Github, ensure that you have the [redhat-konflux-bot](https://github.com/apps/red-hat-konflux) enabled.
- Check your Konflux CI results. Ensure that your component was able to be pulled from, built and tested.

For more information on configuring creating applications and components, please see [the documentation](https://konflux-ci.dev/docs/how-tos/creating/).

# Potential Benefits of this pattern
1. **Separation of Concerns**: The downstream repo can stay focused on its specific development goals while the submodule handles its own code. This keeps your downstream repo clean and modular.

2. **Automatic Dependency Syncing with [Renovate](https://github.com/renovatebot/renovate)**: By automating the dependency sync process, whether its syncing the git submodule, the Containerfile, etc. your downstream repo can always use the latest code from the upstream repo(s), ensuring that your project benefits from new features, bug fixes, and security updates.

3. **Version Control for upstream repos**: You can lock the submodule to a specific commit or version, giving you control over when and how updates are integrated. This is especially useful if an upstream update introduces breaking changes.

4. **Konflux CI**: Automated building and testing of your software artifacts help ensure that changes in the upstream repo don't break your downstream project.

# Potential drawbacks
1. **Complexity**: Managing submodules and automating their updates adds complexity to your workflow, such as:
  - Debugging issues related to submodule updates
  - Your automation configuration can be more challenging.

2. **Dependency Management**: Breaking changes in the upstream repo can affect your downstream repo, requiring manual intervention to fix integration issues.

3. **Merge Conflicts**: If you have automatic updates configured, this might lead to merge conflicts, especially if both the upstream and downstream repos are being actively developed. Resolving these conflicts might require manual effort.


# Gitlab support

**Credit to Qixiang Wan for this information:**

GitLab is supported, you need to follow https://konflux-ci.dev/docs/how-tos/configuring/creating-secrets/#creating-secrets-for-gitlab-sourced-apps to provide the token to access your GitLab repository.

To do that you have to create a secret from command line. Refer to https://gitlab.cee.redhat.com/konflux/docs/users/-/blob/main/topics/getting-started/getting-access.md#accessing-konflux-via-cli for how to login with CLI.

Also refer to this doc for which cluster you can use: https://gitlab.cee.redhat.com/konflux/docs/users/-/blob/main/topics/overview/deployments.md for example, you can't access internal network with public clusters, with internal clusters, you can only use internal gitlab repositories plus gitlab.com/redhat repositories, there are other restrictions as well.

After onboarding your downstream Red Hat product repo in Gitlab onto Konflux you should be able to follow a similar workflow pattern to the one outlined here.

Here is an example of a downstream Gitlab repo with one upstream Github submodule reference: https://gitlab.cee.redhat.com/bramos/konflux-gitmodule-pattern

**Note**: The Gitlab repo example has not onboarded onto Konflux yet.