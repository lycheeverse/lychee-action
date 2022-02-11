FROM lycheeverse/lychee:0.8.2@sha256:afe2b5b757787b9b71e53e09d3ad9edfd3a3bdead904c188f5dae36007732113

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
