//
//  KYAEventManager.m
//  KYAApplicationEvents
//
//  Created by Marcel Dierkes on 20.02.22.
//

#import <KYAApplicationEvents/KYAEventManager.h>
#import <ApplicationServices/ApplicationServices.h>
#import <KYAApplicationEvents/KYAEventHandler.h>
#import "KYADefines.h"

@implementation KYAEventManager

+ (void)configureEventHandler
{
    Auto eventManager = NSAppleEventManager.sharedAppleEventManager;
    [eventManager setEventHandler:self
                      andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                    forEventClass:kInternetEventClass
                       andEventID:kAEGetURL];
}

+ (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)reply
{
    Auto parameter = [event paramDescriptorForKeyword:keyDirectObject].stringValue;
    
    Auto eventHandler = KYAEventHandler.defaultHandler;
    [eventHandler handleEventForURL:[NSURL URLWithString:parameter]];
}

@end
