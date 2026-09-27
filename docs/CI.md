# CI

The structure-validation workflow lives at [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) in the project tree (and in the release zip).

**Why it may be missing on GitHub:** pushing files under `.github/workflows/` requires the `workflow` OAuth scope. If that scope was not available when the repo was created, copy this file into place:

```bash
mkdir -p .github/workflows
cp docs/github-actions-ci.yml .github/workflows/ci.yml
git add .github/workflows/ci.yml
git commit -m "Add structure-validation GitHub Actions workflow"
git push
```

Or paste `docs/github-actions-ci.yml` via the GitHub UI as `.github/workflows/ci.yml`.

Linux Actions **cannot** compile iOS apps. The workflow only validates project structure, Info.plist camera usage text, disclaimer copy, and that sources are listed in `project.pbxproj`. Build on a Mac with Xcode — see the root README.
