# oras-downstream
A repo showcasing a basic 'MidStream' solution

# Basic definitions
- Upstream repo: The open source project repo we want to track
- Downstream repo: The Red Hat repo holding the git submodule reference to the upstream repo

# Workflow
## Create a downstream repo
This repo will be used to hold the git submodule reference to the upstream repository.

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

## Additional Tooling
### Github
#### Keep your upstream repo git module reference up to date
##### Dependabot
**Note:** 
- It appears that Konflux already does this. No need to add external tooling.
- Here is an [example](https://github.com/CryptoRodeo/oras-downstream/pull/12)

On Github you can use the Dependabot tool to keep your git submodule's dependencies up to date.
Dependabot will create pull requests to update these dependencies when new versions are available.

Create the .github directory for your repo:
```bash
mkdir .github
```

Create the dependabot yaml config file
```
touch .github/dependabot.yml
```

Here is a basic dependabot configuration that will watch our git submodule daily for any changes
```yaml

# To get started with Dependabot version updates, you'll need to specify which
# package ecosystems to update and where the package manifests are located.
# Please see the documentation for all configuration options:
# https://docs.github.com/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file

version: 2
updates:
  - package-ecosystem: "gitsubmodule" # See documentation for possible values
    directory: "/" # Location of package manifests
    schedule:
      interval: "daily"
```

### Gitlab
**Currently there does not seem to be Konflux support for Gitlab repos.**
