# TiFlamebase 
## Appcelerator iOS Titanium Mobile Module Project

**currently only for iOS**

Appcelerator Native iOS Module for receiving Push Notification from Firebase Cloud Messaging

## GET STARTED

1. Download the zip: [ti.flamebase-iphone-1.0.0.zip](https://github.com/asyncerror/TiFlamebase/blob/master/iphone/ti.flamebase-iphone-1.0.0.zip)

2. Unzip the file in your application root folder.
	- After unpacking, your directory will look like this:

```
<App_Dir>
├── modules
│   └── iphone
│       └── ti.flamebase
│           └── 1.0.0
│               ├── Resources
│               ├── assets
│               ├── documentation
│               ├── example
│               └── platform
```
	
3. Download the **GoogleService-Info.plist** file from your Firebase Console project.
	- Save it in the **Resources** folder (specified in step 2) of the TiFlamebase module.

4. Add the module to your **tiapp.xml**.

```xml
<modules>
	...other modules nodes
	<module platform="iphone">ti.flamebase</module>                                                                                                                        
</modules>
```

5. [MORE INFO COMING]


