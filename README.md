<!--
N.B.: This README was automatically generated by https://github.com/YunoHost/apps/tree/master/tools/README-generator
It shall NOT be edited by hand.
-->

# Monica for YunoHost

[![Integration level](https://dash.yunohost.org/integration/monica.svg)](https://dash.yunohost.org/appci/app/monica) ![](https://ci-apps.yunohost.org/ci/badges/monica.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/monica.maintain.svg)  
[![Install Monica with YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=monica)

*[Lire ce readme en français.](./README_fr.md)*

> *This package allows you to install Monica quickly and simply on a YunoHost server.
If you don't have YunoHost, please consult [the guide](https://yunohost.org/#/install) to learn how to install it.*

## Overview

Monica is an open-source web application to organize the interactions with your loved ones. I call it a PRM, or Personal Relationship Management. Think of it as a [CRM](https://en.wikipedia.org/wiki/Customer_relationship_management) (a popular tool used by sales teams in the corporate world) for your friends or family.


**Shipped version:** 3.5.0~ynh1

**Demo:** https://demo.example.com

## Screenshots

![](./doc/screenshots/main-app.png)

## Disclaimers / important information

## Configuration

Change the settings of the app by changing the values in `.env`

## Documentation and resources

* Official app website: https://monicahq.com
* Official admin documentation: https://yunohost.org/packaging_apps
* Upstream app code repository: https://github.com/monicahq/monica
* YunoHost documentation for this app: https://yunohost.org/app_monica
* Report a bug: https://github.com/YunoHost-Apps/monica_ynh/issues

## Developer info

Please send your pull request to the [testing branch](https://github.com/YunoHost-Apps/monica_ynh/tree/testing).

To try the testing branch, please proceed like that.
```
sudo yunohost app install https://github.com/YunoHost-Apps/monica_ynh/tree/testing --debug
or
sudo yunohost app upgrade monica -u https://github.com/YunoHost-Apps/monica_ynh/tree/testing --debug
```

**More info regarding app packaging:** https://yunohost.org/packaging_apps