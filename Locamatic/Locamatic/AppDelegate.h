//
//  AppDelegate.h
//  Locamatic
//
//  Created by Pascal Harris on 21/02/2013.
//  Copyright (c) 2013 Pascal Harris. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Reachability.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreWLAN/CoreWLAN.h>
#include "PascalCLibrary.h"
#import "PreferencesHelper.h"
#import <Growl/Growl.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, NSMenuDelegate>
{
    IBOutlet NSMenu *locamaticMenu;
    
    NSStatusItem    *statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightImage;
    
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
    
    id preferencesController;
    NSMutableDictionary *pluginDictionary;

    bool noStartAlert;
    bool showMenuBarItem;
    bool paused;
}
@property (assign) IBOutlet NSWindow *window;

-(bool) setLocationForNetwork;
-(void)setMenubar:(NSNotification*)aNote;
-(void)quitLocamatic:(NSNotification*)aNote;
-(void)refreshPrefs:(NSNotification*)aNote;
-(IBAction)showPreferences:(id)sender;
-(IBAction)quitEngine:(id)sender;
-(IBAction)pauseLocamatic:(id)sender;
-(IBAction)aboutLocamatic:(id)sender;

-(void)showMyHelp:(NSNotification *) aNote;
@end
