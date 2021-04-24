# lychee link checking action

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-lychee-blue.svg?colorA=24292e&colorB=0366d6&style=flat&longCache=true&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAM6wAADOsB5dZE0gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAERSURBVCiRhZG/SsMxFEZPfsVJ61jbxaF0cRQRcRJ9hlYn30IHN/+9iquDCOIsblIrOjqKgy5aKoJQj4O3EEtbPwhJbr6Te28CmdSKeqzeqr0YbfVIrTBKakvtOl5dtTkK+v4HfA9PEyBFCY9AGVgCBLaBp1jPAyfAJ/AAdIEG0dNAiyP7+K1qIfMdonZic6+WJoBJvQlvuwDqcXadUuqPA1NKAlexbRTAIMvMOCjTbMwl1LtI/6KWJ5Q6rT6Ht1MA58AX8Apcqqt5r2qhrgAXQC3CZ6i1+KMd9TRu3MvA3aH/fFPnBodb6oe6HM8+lYHrGdRXW8M9bMZtPXUji69lmf5Cmamq7quNLFZXD9Rq7v0Bpc1o/tp0fisAAAAASUVORK5CYII=)](https://github.com/marketplace/actions/lychee-broken-link-checker)

Quickly check links in Markdown, HTML, and text files using [lychee].

When used in conjunction with [Create Issue From File](https://github.com/peter-evans/create-issue-from-file), issues will be created when the action finds link problems.

## Usage

Here is a full example of a Github workflow file.
It will check all repository links once per day and create an issue in case of errors.
Save this under `.github/workflows/links.yml`:

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
      - uses: actions/checkout@v2

      - name: Link Checker
        uses: lycheeverse/lychee-action@1.0.8
        with:
          args: --verbose --no-progress **/*.md **/*.html
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
        
      - name: Create Issue From File
        uses: peter-evans/create-issue-from-file@v2
        with:
          title: Link Checker Report
          content-filepath: ./lychee/out.md
          labels: report, automated issue
```

#### Detailed arguments (`args`) information

This action uses [lychee] for link checking.
lychee arguments can be passed to the action via the `args` parameter.

```yml
- name: Link Checker
  uses: lycheeverse/lychee-action@v1.0.8
  with:
    args: --verbose --no-progress *.md
```

See [lychee's documentation][lychee] for all possible arguments.

#### Optional environment variables

Issues with links will be written to a file containing the error report.
The default path is `lychee/out.md`. The path and filename may be overridden with the following variable:

- `LYCHEE_OUT` - The path to the output file for the Markdown error report

#### Creating a failing check for link errors

To create a failing check when there are link errors, you can use the `exit_code` output from the action as follows.

```yml
on: push
jobs:
  linkChecker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: lychee Link Checker
        id: lychee
        uses: lycheeverse/lychee-action@v1.0.8
      - name: Fail if there were link errors
        run: exit ${{ steps.lychee.outputs.exit_code }}
```

#### Troubleshooting and common problems

See [lychee's Troubleshooting Guide](https://github.com/lycheeverse/lychee/blob/master/TROUBLESHOOTING.md)
for solutions to common link-checking problems.

#### Performance

A full CI run to scan 576 links takes approximately 1 minute for the [analysis-tools-dev/static-analysis](https://github.com/analysis-tools-dev/static-analysis) repository.

## Credits

This action is based on [peter-evans/link-checker](https://github.com/peter-evans/link-checker) and uses lychee (written in Rust) instead of liche (written in Go) for link checking. For a comparison of both tools, check out this [comparison table](https://github.com/lycheeverse/lychee#features).

[lychee]: https://github.com/lycheeverse/lychee
