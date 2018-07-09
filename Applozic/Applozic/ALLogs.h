//
//  ALLogs.h
//  Applozic
//
//  Created by devashish on 22/06/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ALUserDefaultsHandler.h"

#define APPLOZIC_ENABLE_FLAG 1

#ifdef APPLOZIC_ENABLE_FLAG
#define NSLog(args...) ALExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
#define NSLog(x...)
#endif

void ALExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);