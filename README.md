
# Monica app for YunoHost
[![Integration level](https://dash.yunohost.org/integration/monica.svg)](https://ci-apps.yunohost.org/jenkins/job/monica%20%28Community%29/lastBuild/consoleFull)

[![Installer Monica with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=monica)

Shipped version: **2.12.0**
<p align="center"><img src="37693034-5783b3d6-2c93-11e8-80ea-bd78438dcd51.png"></p>
<h1 align="center">Personal Relationship Manager</h1>


- [Yunohost project](https://yunohost.org)
- [Monica](https://monicahq.com/)
- [Monica source code at Github](https://github.com/monicahq/monica)

## Introduction

Monica is an open-source web application to organize the interactions with your loved ones. I call it a PRM, or Personal Relationship Management. Think of it as a [CRM](https://en.wikipedia.org/wiki/Customer_relationship_management) (a popular tool used by sales teams in the corporate world) for your friends or family.

## Install
##### This app will install PHP7.1 
```
 sudo yunohost app install https://github.com/YunoHost-Apps/monica_ynh
```
**First User Registraion:** Visit the app **domain** after the installtion is complete to register as **first user**. After the first user is registerd the registration will be **locked**. You can open the register for all by chaning the value **APP_DISABLE_SIGNUP** to **false** in **.env**. There is **no admin interface** in the Monica app currently.

## Update
```
 sudo yunohost app upgrade -u https://github.com/YunoHost-Apps/monica_ynh monica
```
#### Change the settings of the app by changing the values in .env

## What works?
* [X] Update and remove script
* [X] Upgrade script
* [X] Backup and restore script (**Need testing**)
* [X] Multi-instance (**Need testing**)
* [x] make root domain redirect to index.php
* [x] Chang URL (Need testing,backup before trying this)
* [ ] LDAP/SSO support
* [ ] Make monica installable into subdirectory (eg. https://example.com/monica/)
  * Currently it is only possible to install monica into the root of a domain (eg. https://example.com/)
  * This is due to a limitation in monica, not yunohost!
  * See [here](https://github.com/monicahq/monica/issues/139) for the current progress.

## License

GPL-3.0
