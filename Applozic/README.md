#Applozic-Chat-iOS-Framework

Applozic provides an open source iOS Chat and Messaging SDK that lets you add real time messaging in your mobile (android, iOS) applications and website.

Works for both Objective-C and Swift.

It is a light weight Objective-C Chat and Messenger SDK.

Applozic One to One and Group Chat SDK

Signup at https://www.applozic.com/signup.html to get the application key.

Documentation: https://www.applozic.com/docs/ios-chat-sdk.html

Applozic Chat Framework for Cocoa Pod

##Installation

1) Open terminal and navigate to your project root directory and run command ```pod init``` in terminal


2) Go to project directory open pod file and add code in that

```
 pod 'Applozic', '~>4.1.0'
```


3) Download **ALChatManager** class and add to your project

[**ALChatManager.h**](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/sample-with-framework/applozicdemo/ALChatManager.h)        

[**ALChatManager.m**](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/sample-with-framework/applozicdemo/ALChatManager.m)


4) Add import code

```
#import "ALChatManager.h"
#import <Applozic/Applozic.h>
```


5) Initiate **ALChatManager.h** Class Object

```  
NOTE: Replace "applozic-sample-app" by your application key

ALChatManager * chatManager = [[ALChatManager alloc] initWithApplicationKey:@"applozic-sample-app"];
```

6) For Registering user and other customization follow [**Applozic iOS DOCS**](https://www.applozic.com/docs/ios-chat-sdk.html#step-2-login-register-user)

For reference download our sample project here [**ApplozicCocoaPodDemo**](https://github.com/AppLozic/Applozic-iOS-Chat-Samples)

##Features:

One to one and Group Chat

Image capture

Photo sharing

Location sharing

Push notifications

In-App notifications

Online presence

Last seen at

Unread message count

Typing indicator

Message sent, delivery report

Offline messaging

Multi Device sync

Application to user messaging

Customized chat bubble

UI Customization Toolkit

Cross Platform Support (iOS, Android & Web)
