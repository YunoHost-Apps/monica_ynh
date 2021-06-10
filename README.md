# Monica for YunoHost

[![Integration level](https://dash.yunohost.org/integration/monica.svg)](https://dash.yunohost.org/appci/app/monica) ![](https://ci-apps.yunohost.org/ci/badges/monica.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/monica.maintain.svg)

[![Install Monica with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=monica)

> *This package allows you to install Monica quickly and simply on a YunoHost server.
If you don't have YunoHost, please consult [the guide](https://yunohost.org/#/install) to learn how to install it.*

## Overview
Monica is an open-source web application to organize the interactions with your loved ones. I call it a PRM, or Personal Relationship Management. Think of it as a [CRM](https://en.wikipedia.org/wiki/Customer_relationship_management) (a popular tool used by sales teams in the corporate world) for your friends or family.

**Shipped version:** 3.0.1

## Screenshots

![](https://www.monicahq.com/img/dashboard.png)

## Configuration

Change the settings of the app by changing the values in `.env`

## YunoHost specific features

- **First User:** An email with credentials for login will be sent to user who was chosen while the installation process of Monica. There is no **admin interface** on Monica, so every registered users will considered as normal user.

#### Supported architectures

* x86-64 - [![Build Status](https://ci-apps.yunohost.org/ci/logs/monica%20%28Apps%29.svg)](https://ci-apps.yunohost.org/ci/apps/monica/)
* ARMv8-A - [![Build Status](https://ci-apps-arm.yunohost.org/ci/logs/monica%20%28Apps%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/monica/)

## Links

 * Report a bug: https://github.com/YunoHost-Apps/monica_ynh/issues
 * App website: https://monicahq.com/
 * Upstream app repository: https://github.com/monicahq/monica
 * YunoHost website: https://yunohost.org/

---

## Developer info

Please send your pull request to the [testing branch](https://github.com/YunoHost-Apps/monica_ynh/tree/testing).

To try the testing branch, please proceed like that.
```
sudo yunohost app install https://github.com/YunoHost-Apps/monica_ynh/tree/testing --debug
or
sudo yunohost app upgrade monica -u https://github.com/YunoHost-Apps/monica_ynh/tree/testing --debug
```
