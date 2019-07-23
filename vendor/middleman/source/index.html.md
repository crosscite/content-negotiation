---
layout: index
title: Crosscite Content Negotiation
description: DOI metadata from DataCite and Crossref in multiple formats.
---

### Content Negotiation

In this method you will not access this service directly. Instead, you will make a DOI resolution via [doi.org](https://doi.org/) using an HTTPs client (not your regular web browser) which allows you to specify the [HTTP Accept header](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html).

Content negotiation for DOI names is a collaborative effort of [CrossRef](http://www.crossref.org/)and DataCite and it is endorsed by the [International DOI Foundation](http://doi.org/).

For details on how to use DOI Content Negotiation please be sure to check [our documentation](https://support.datacite.org/docs/datacite-content-resolver).

### Link-based Content Type Requests

This method can be used with a regular web browser. In order to get a specific format please construct a URL following this pattern: `https://data.datacite.org/MIME_TYPE/DOI`.
