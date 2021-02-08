# lychee link checking action

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-lychee%20action-blue.svg?colorA=24292e&colorB=0366d6&style=flat&longCache=true&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAM6wAADOsB5dZE0gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAERSURBVCiRhZG/SsMxFEZPfsVJ61jbxaF0cRQRcRJ9hlYn30IHN/+9iquDCOIsblIrOjqKgy5aKoJQj4O3EEtbPwhJbr6Te28CmdSKeqzeqr0YbfVIrTBKakvtOl5dtTkK+v4HfA9PEyBFCY9AGVgCBLaBp1jPAyfAJ/AAdIEG0dNAiyP7+K1qIfMdonZic6+WJoBJvQlvuwDqcXadUuqPA1NKAlexbRTAIMvMOCjTbMwl1LtI/6KWJ5Q6rT6Ht1MA58AX8Apcqqt5r2qhrgAXQC3CZ6i1+KMd9TRu3MvA3aH/fFPnBodb6oe6HM8+lYHrGdRXW8M9bMZtPXUji69lmf5Cmamq7quNLFZXD9Rq7v0Bpc1o/tp0fisAAAAASUVORK5CYII=)](https://github.com/marketplace/actions/lychee-link-checker-action)

Quickly check links in Markdown, HTML, and text files using [lychee].

When used in conjunction with [Create Issue From File](https://github.com/peter-evans/create-issue-from-file), issues will be created when the action finds link problems.

## Usage

Using with the default settings will check the `README.md` in your repository.

```yml
- name: Link Checker
  uses: lycheeverse/lychee-action@v1
```

This action uses [lychee] for link checking.
lychee arguments can be passed to the action via the `args` parameter. If not set, the default `-v README.md` will be used.

```yml
- name: Link Checker
  uses: lycheeverse/lychee-action@v1
  with:
    args: -v README.md
```

#### Detailed arguments (`args`) information

See [lychee's documentation][lychee] for further argument details.

#### Optional environment variables

Issues with links will will be written to a file containing the error report.
The default path is `lychee/out.md`. The path and filename may be overridden with the following variable:

- `LYCHEE_OUT` - The path to the output file for the markdown error report

#### Receiving issues containing the error report

Below is an example of using this action in conjunction with [Create Issue From File](https://github.com/peter-evans/create-issue-from-file). The workflow executes on a schedule every month. Issues will be created when Link Checker finds connectivity problems with links.

```yml
on:
  schedule:
    - cron: "0 0 1 * *"
name: Check markdown links
jobs:
  linkChecker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Link Checker
        uses: lycheeverse/lychee-action@v1
      - name: Create Issue From File
        uses: peter-evans/create-issue-from-file@v2
        with:
          title: Link Checker Report
          content-filepath: ./lychee/out.md
          labels: report, automated issue
```

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
        id: lc
        uses: lycheeverse/lychee-action@v1
      - name: Fail if there were link errors
        run: exit ${{ steps.lc.outputs.exit_code }}
```

#### Troubleshooting and common problems

See [lychee's Troubleshooting Guide](https://github.com/lycheeverse/lychee/blob/master/TROUBLESHOOTING.md)
for solutions to common link-checking problems.


## Credits

This action is based on [peter-evans/link-checker](https://github.com/peter-evans/link-checker) and uses lychee (written in Rust) instead of liche (written in Go) for link checking. For a comparison of both tools, check out this [comparison table](https://github.com/lycheeverse/lychee#features).

[lychee]: https://github.com/lycheeverse/lychee
