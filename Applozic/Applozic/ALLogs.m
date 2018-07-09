//
//  ALLogs.m
//  Applozic
//
//  Created by devashish on 22/06/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALLogs.h"

void ALExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...)
{
    
    if(![ALUserDefaultsHandler isDebugLogsRequire])
    {
        return;
    }
    
    // Type to hold information about variable arguments.
    va_list ap;
    
    // Initialize a variable argument list.
    va_start (ap, format);
    
    // NSLog only adds a newline to the end of the NSLog format if
    // one is not already there.
    // Here we are utilizing this feature of NSLog()
    if (![format hasSuffix: @"\n"])
    {
        format = [format stringByAppendingString: @"\n"];
    }
    
    NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
    
    // End using variable argument list.
    va_end (ap);
    
    NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    
//    COMMENTED DO NOT DELETE VIMP
//    fprintf(stderr, "%s Applozic : [%s] [%s:%d] :: %s",[timeStamp UTF8String], functionName, [fileName UTF8String], lineNumber, [body UTF8String]);
     fprintf(stderr, "%s Applozic : [%s:%d] :: %s",[timeStamp UTF8String], [fileName UTF8String], lineNumber, [body UTF8String]);
    
}