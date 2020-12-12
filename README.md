# lychee link checking action

Quickly check links in Markdown, HTML, and text files.

When used in conjunction with [Create Issue From File](https://github.com/peter-evans/create-issue-from-file), issues will be created when Link Checker finds connectivity problems with links.

## Usage

Using with the default settings will check the `README.md` in your repository.

```yml
- name: Link Checker
  uses: lycheeverse/lychee-action@v1
```

This action uses [lychee](https://github.com/lycheeverse/lychee) for link checking.
lychee arguments can be passed to the action via the `args` parameter. If not set, the default `-v README.md` will be used.

```yml
- name: Link Checker
  uses: lycheeverse/lychee-action@v1
  with:
    args: -v README.md
```

See [lychee's documentation](https://github.com/lycheeverse/lychee) for further argument details.

#### Optional environment variables

Issues with links will will be written to a file containing the error report.
The default path is `lychee/out.md`. The path and filename may be overridden with the following variables.

- `LYCHEE_OUTPUT_DIR` - The output directory the markdown error report
- `LYCHEE_OUTPUT_FILENAME` - The error report filename

#### Receiving issues containing the error report

Below is an example of using this action in conjunction with [Create Issue From File](https://github.com/peter-evans/create-issue-from-file). The workflow executes on a schedule every month. Issues will be created when Link Checker finds connectivity problems with links.

```yml
on:
  schedule:
  - cron: '0 0 1 * *'
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


## Credits

This action is based on [peter-evans/link-checker](https://github.com/peter-evans/link-checker) and uses lychee (written in Rust) instead of liche (written in Go) for link checking. For a comparison of both tools, check out this [comparison table](https://github.com/lycheeverse/lychee#features).

