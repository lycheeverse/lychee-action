FROM lycheeverse/lychee:0.9.0@sha256:d5b7a864beb60cb56d0eb0034fcabf2ede343ddef1c64d6f69b5493a57fc38c3

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
