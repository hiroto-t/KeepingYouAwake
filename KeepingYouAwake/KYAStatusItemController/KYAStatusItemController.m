//
//  KYAStatusItemController.m
//  KeepingYouAwake
//
//  Created by Marcel Dierkes on 10.09.17.
//  Copyright © 2017 Marcel Dierkes. All rights reserved.
//

#import "KYAStatusItemController.h"
#import "KYADefines.h"
#import "KYAMenuBarIcon.h"

@interface KYAStatusItemController ()
@property (nonatomic, readwrite) NSStatusItem *systemStatusItem;
@end

@implementation KYAStatusItemController

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        [self configureStatusItem];
    }
    return self;
}

#pragma mark - Configuration

- (void)configureStatusItem
{
    Auto statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.highlightMode = ![NSUserDefaults standardUserDefaults].kya_menuBarIconHighlightDisabled;
    if([statusItem respondsToSelector:@selector(behavior)])
    {
        statusItem.behavior = NSStatusItemBehaviorTerminationOnRemoval;
    }
    if([statusItem respondsToSelector:@selector(isVisible)])
    {
        statusItem.visible = YES;
    }
    
    Auto button = statusItem.button;
    
    [button sendActionOn:NSEventMaskLeftMouseUp|NSEventMaskRightMouseUp];
    button.target = self;
    button.action = @selector(toggleStatus:);
    
#if DEBUG
    if(@available(macOS 10.14, *))
    {
        button.contentTintColor = NSColor.systemBlueColor;
    }
    KYALog(@"Blue status bar item color is enabled for DEBUG builds.");
#endif
    
    self.systemStatusItem = statusItem;
    self.activeAppearanceEnabled = NO;
}

- (void)toggle
{
    [self toggleStatus:nil];
}

- (void)toggleStatus:(id)sender
{
    Auto delegate = self.delegate;
    Auto event = NSApplication.sharedApplication.currentEvent;
    
    if((event.modifierFlags & NSEventModifierFlagControl)   // ctrl click
       || (event.modifierFlags & NSEventModifierFlagOption) // alt click
       || (event.type == NSEventTypeRightMouseUp))          // right click
    {
        if([delegate respondsToSelector:@selector(statusItemControllerShouldPerformAlternativeAction:)])
        {
            [delegate statusItemControllerShouldPerformAlternativeAction:self];
        }
        return;
    }
    
    if([delegate respondsToSelector:@selector(statusItemControllerShouldPerformMainAction:)])
    {
        [delegate statusItemControllerShouldPerformMainAction:self];
    }
}

#pragma mark - Active Appearance

- (BOOL)isActiveAppearanceEnabled
{
    Auto menubarIcon = KYAMenuBarIcon.currentIcon;
    return self.systemStatusItem.image == menubarIcon.activeIcon;
}

- (void)setActiveAppearanceEnabled:(BOOL)activeAppearanceEnabled
{
    Auto button = self.systemStatusItem.button;
    Auto menubarIcon = KYAMenuBarIcon.currentIcon;
    
    if(activeAppearanceEnabled)
    {
        button.image = menubarIcon.activeIcon;
        button.toolTip = NSLocalizedString(@"Click to allow sleep\nRight click to show menu",
                                           @"Click to allow sleep\nRight click to show menu");
    }
    else
    {
        button.image = menubarIcon.inactiveIcon;
        button.toolTip = NSLocalizedString(@"Click to prevent sleep\nRight click to show menu",
                                           @"Click to prevent sleep\nRight click to show menu");
    }
}

#pragma mark - Menu

- (void)showMenu:(NSMenu *)menu
{
    [self.systemStatusItem popUpStatusItemMenu:menu];
}

@end
