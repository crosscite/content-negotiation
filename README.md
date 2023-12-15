# DOI Content Negotiation

[![Identifier](https://img.shields.io/badge/doi-10.5438%2Ft1jg--hvhn-fca709.svg)](https://doi.org/10.5438/t1jg-hvhn)
[![Build Status](https://github.com/crosscite/content-negotiation/actions/workflows/stage.yml/badge.svg?branch=master)](https://github.com/crosscite/content-negotiation/workflows/Deploy/badge.svg)
![Release](https://github.com/crosscite/content-negotiation/workflows/Deploy/badge.svg)
[![Code Climate](https://codeclimate.com/github/crosscite/content-negotiation/badges/gpa.svg)](https://codeclimate.com/github/crosscite/content-negotiation)
[![Test Coverage](https://codeclimate.com/github/crosscite/content-negotiation/badges/coverage.svg)](https://codeclimate.com/github/crosscite/content-negotiation/coverage)

Rails API application for conversion of DOI metadata form/to other metadata formats, including [schema.org](https://schema.org). Based on the [bolognese](https://github.com/datacite/bolognese) library for metadata conversion.

## Installation

Using Docker. There is no required configuration file.

```
docker run -p 8085:80 crosscite/content-negotiation
```

You can now point your browser to `http://localhost:8085` and use the application.
This is an API with no user interface.

## Development

We use Rspec for unit and acceptance testing:

```
bundle exec rspec
```

Follow along via [Github Issues](https://github.com/crosscite/content-negotiation/issues).

### Note on Patches/Pull Requests

* Fork the project
* Write tests for your new feature or a test that reproduces a bug
* Implement your feature or make a bug fix
* Do not mess with Rakefile, version or history
* Commit, push and make a pull request. Bonus points for topical branches.

## License
**Content Negotiation** is released under the [MIT License](https://github.com/crosscite/content-negotiation/blob/master/LICENSE).
