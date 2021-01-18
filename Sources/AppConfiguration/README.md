# App configuration

Collection of classes that can help you to work with configuration variables much easier.

Main class is `ConfigurationVariable` and all you need to do to use it is set an array of `ConditionValue`s and take a `value` where needed.

`ConditionValue` is a simple wrap on a value with a condition block which should return `true` if this variable should be used.

> **Note**
>
> All condition values will be checked in the same order you set in `ConfigurationVariable`. So please be careful with it and put AppStore value at first place all the time.

## Default implementation

Here at Rosberry we have default implementation of `ConditionValue`s. They are take place in the folder `DefaltValues` and documented well. The only thing you need to know is that they are based on build and server configurations. 

#### `BuildConfiguration`
We use the following active compilation conditions for build distinguishing:
* `DEBUG`
* `ADHOC`
* `APPSTORE`

#### `ServerConfiguration`
We use the following active compilation conditions for server distinguishing:
* `DEV_SERVER`
* `STAGING_SERVER`
* `PRODUCTION_SERVER`

Also `ServerConfiguration` allows you to switch server on the fly. To do so you should set one of the `ServerName` values to `serverName` variable in `UserDefaults.standard`. In UI we do it with help of `ServerPlugin` for `Deboogger`. After user selects a server, plugin sends `ServerChanged` notification via `NotificationCenter` and your app can react on it in any way. Preferably you should react on it in `AppCoordinator` and just reset app view controllers stack and session related data. 