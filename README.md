# Monica app for YunoHost

- [Yunohost project](https://yunohost.org)
- [Monica](https://monicahq.com/)

Personal Relationship Manager - a new kind of CRM to organize interactions with your friends and family.

## TODO

* [ ] LDAP/SSO support
  * As for now, the specified admin user with the password `admin` is created in monica
* [ ] Make monica installable into subdirectory (eg. https://example.com/monica/)
  * Currently it is only possible to install monica into the root of a domain (eg. https://example.com/)
  * This is due to a limitation in monica, not yunohost!
  * See [here](https://github.com/monicahq/monica/issues/139) for the current progress.
* [x] make root domain redirect to index.php
