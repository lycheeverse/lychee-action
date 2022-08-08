# lychee link checking action

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-lychee-blue.svg?colorA=24292e&colorB=0366d6&style=flat&longCache=true&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAM6wAADOsB5dZE0gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAERSURBVCiRhZG/SsMxFEZPfsVJ61jbxaF0cRQRcRJ9hlYn30IHN/+9iquDCOIsblIrOjqKgy5aKoJQj4O3EEtbPwhJbr6Te28CmdSKeqzeqr0YbfVIrTBKakvtOl5dtTkK+v4HfA9PEyBFCY9AGVgCBLaBp1jPAyfAJ/AAdIEG0dNAiyP7+K1qIfMdonZic6+WJoBJvQlvuwDqcXadUuqPA1NKAlexbRTAIMvMOCjTbMwl1LtI/6KWJ5Q6rT6Ht1MA58AX8Apcqqt5r2qhrgAXQC3CZ6i1+KMd9TRu3MvA3aH/fFPnBodb6oe6HM8+lYHrGdRXW8M9bMZtPXUji69lmf5Cmamq7quNLFZXD9Rq7v0Bpc1o/tp0fisAAAAASUVORK5CYII=)](https://github.com/marketplace/actions/lychee-broken-link-checker)
[![Check Links](https://github.com/lycheeverse/lychee-action/actions/workflows/links.yml/badge.svg)](https://github.com/lycheeverse/lychee-action/actions/workflows/links.yml)

Quickly check links in Markdown, HTML, and text files using [lychee].

When used in conjunction with [Create Issue From
File](https://github.com/peter-evans/create-issue-from-file), issues will be
created when the action finds link problems.

## Usage

Here is a full example of a GitHub workflow file:

It will check all repository links once per day and create an issue in case of
errors. Save this under `.github/workflows/links.yml`:

```yaml
name: Links

on:
  repository_dispatch:
  workflow_dispatch:
  schedule:
    - cron: "00 18 * * *"

jobs:
  linkChecker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Link Checker
        id: lychee
        uses: lycheeverse/lychee-action@v1.5.1
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}

      - name: Create Issue From File
        if: steps.lychee.outputs.exit_code != 0
        uses: peter-evans/create-issue-from-file@v3
        with:
          title: Link Checker Report
          content-filepath: ./lychee/out.md
          labels: report, automated issue
```

### Alternative approach:

This will check all repository links during any git push event and for all pull
requests. If there's an error, it will fail the action. This has the benefit of
ensuring that during a Pull Request, no link is added that is broken and any
existing link will be caught if they become broken. Save this under
`.github/workflows/links-fail-fast.yml`:

```yaml
name: Links (Fail Fast)

on:
  push:
  pull_request:

jobs:
  linkChecker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Link Checker
        uses: lycheeverse/lychee-action@v1.5.1
        with:
          fail: true
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```

## Passing arguments

This action uses [lychee] for link checking.
lychee arguments can be passed to the action via the `args` parameter.

On top of that, the action also supports some additional arguments.

| Argument      | Examples                | Description                                                                     |
| ------------- | ----------------------- |-------------------------------------------------------------------------------- |
| args          | `--cache`, `--insecure` | See [lychee's documentation][lychee-args] for all arguments and values          |
| format        | `markdown`, `json`      | Summary output format                                                           |
| output        | `lychee/results.md`     | Summary output file path                                                        |
| fail          | `false`                 | Fail workflow run on error (i.e. when [lychee exit code][lychee-exit] is not 0) |
| jobSummary    | `false`                 | Write Github job summary (on Markdown output only)                              |
| lycheeVersion | `0.10.1`                | Overwrite the lychee version to be used                                         |

See [action.yml](./action.yml) for a full list of supported arguments and their default values.

### Example of argument passing

```yml
- name: Link Checker
  uses: lycheeverse/lychee-action@v1.5.1
  with:
    # Check all markdown and html files in repo (default)
    args: --verbose --no-progress './**/*.md' './**/*.html'
    # Use json as output format (instead of markdown)
    format: json
    # Use different output file path
    output: /tmp/foo.txt
    # Fail action on broken links
    fail: true
```

## Utilising the cache feature

In order to mitigate issues regarding rate limiting or to reduce stress on external resources, one can setup lychee's cache similar to this:

```yml
- name: Restore lychee cache
  uses: actions/cache@v3
  with:
    path: .lycheecache
    key: cache-lychee-${{ github.sha }}
    restore-keys: cache-lychee-

- name: Run lychee
  uses: lycheeverse/lychee-action@v1.5.1
  with:
    args: '--cache --max-cache-age 1d'
```

Note that there is no need for another step at the end to store the cache.
There will automatically be a `Post` step (generated from the used `actions/cache` action) taking care of that.
It will compare and save the cache based on the given key.
So in this setup, as long as a user triggers the CI run from the same commit, it will be the same key. The first run will save the cache, subsequent runs will not update it (because it's the same commit hash).
For restoring the cache, the most recent available one is used (commit hash doesn't matter).


## Excluding links from getting checked

Add a `.lycheeignore` file to the root of your repository to exclude links from
getting checked. It supports regular expressions. One expression per line.

## Fancy badge

Pro tip: You can add a little badge to your repo to show the status of your
links. Just replace `org` with your organisation name and `repo` with the
repository name and put it into your `README.md`:

```
[![Check Links](https://github.com/org/repo/actions/workflows/links.yml/badge.svg)](https://github.com/org/repo/actions/workflows/links.yml)
```

It will look like this:

[![Check Links](https://github.com/lycheeverse/lychee-action/actions/workflows/links.yml/badge.svg)](https://github.com/lycheeverse/lychee-action/actions/workflows/links.yml)

## Troubleshooting and common problems

See [lychee's Troubleshooting Guide][troubleshooting] for solutions to common
link-checking problems.

## Performance

A full CI run to scan 576 links takes approximately 1 minute for the
[analysis-tools-dev/static-analysis](https://github.com/analysis-tools-dev/static-analysis)
repository.

## Security and Updates

It is recommended to pin lychee-action to a fixed version [for security
reasons][security]. You can use dependabot to automatically keep your Github
actions up-to-date. This is a great way to pin lychee-action, while still
receiving updates in the future. It's a relatively easy thing to do.

Create a file named `.github/dependabot.yml` with the following contents:

```yml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: ".github/workflows"
    schedule:
      interval: "daily"
```

When you add or update the `dependabot.yml` file, this triggers an immediate check for version updates.
Please see [the documentation][dependabot] for all configuration options.

### Security tip

For additional security when relying on automation to update actions you can pin
the action to a SHA-256 rather than the semver version so as to avoid tag
spoofing Dependabot will still be able to automatically update this.

For example:

```yml
- name: Link Checker
  uses: lycheeverse/lychee-action@cb79c9607b37671965f8dbb54cae47795758a440 #1.1.1
  #...
```

## Credits

This action is based on
[peter-evans/link-checker](https://github.com/peter-evans/link-checker) and uses
lychee (written in Rust) instead of liche (written in Go) for link checking. For
a comparison of both tools, check out this [comparison
table](https://github.com/lycheeverse/lychee#features).

## License

lychee is licensed under either of

- Apache License, Version 2.0, (LICENSE-APACHE or
  https://www.apache.org/licenses/LICENSE-2.0)
- MIT license (LICENSE-MIT or https://choosealicense.com/licenses/mit/)

at your option.

[lychee]: https://github.com/lycheeverse/lychee
[lychee-args]: https://github.com/lycheeverse/lychee#commandline-parameters
[lychee-exit]: https://github.com/lycheeverse/lychee#exit-codes
[troubleshooting]: https://github.com/lycheeverse/lychee/blob/master/docs/TROUBLESHOOTING.md
[security]: https://francoisbest.com/posts/2020/the-security-of-github-actions
[dependabot]: https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file
