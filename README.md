<!-- # Copyright 2019 Oath Inc. All rights reserved. -->

# Vespa Cloud documentation

This repository is about documenting the Vespa Cloud service - this document explains how to write documentation.

## Practical information

Vespa documentation is served using
[GitHub Project pages](https://help.github.com/categories/github-pages-basics/)
with
[Jekyll](https://help.github.com/categories/customizing-github-pages/).
To edit documentation, check out and work off the master branch in this repository.

Documentation is written in HTML or Markdown.
We use a single Jekyll template (_layouts/default.html) to add header, footer and layout.
With Jekyll installed (follow the link above), use

    bundle exec jekyll serve

to set up a local server at localhost:4000 to see the pages as they will look when served.

The layout is written in Bootstrap, documents refers directly to the Bootstrap CSS.
Refer to [Bootstrap documentation](http://getbootstrap.com/css/) to
add style effects to articles. Note that the entire documentation page content
is contained in a Bootstrap layout column with column width 12.
Please do not add custom style sheets, as it is harder to maintain.

## Writing good documentation

