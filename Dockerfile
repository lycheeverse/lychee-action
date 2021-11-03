FROM lycheeverse/lychee:0.8.0@sha256:96b5479e660127486850e9bf80ce9c22afc464787096122d5eff4ae9dca85666

LABEL maintainer="Matthias Endler <matthias-endler@gmx.net>"
LABEL repository="https://github.com/lycheeverse/lychee-action"
LABEL homepage="https://github.com/lycheeverse/lychee-action"

LABEL com.github.actions.name="Link Checker"
LABEL com.github.actions.description="Quickly check links in Markdown, HTML, and text files"
LABEL com.github.actions.icon="external-link"
LABEL com.github.actions.color="purple"

COPY README.md /
COPY LICENSE-MIT LICENSE-APACHE /

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
