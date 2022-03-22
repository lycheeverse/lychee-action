FROM lycheeverse/lychee:0.9.0@sha256:68c5d76e0e87c6267cf2954b5e1d9b5765a47a5d7ae352e227ecbfb16db99f71

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
