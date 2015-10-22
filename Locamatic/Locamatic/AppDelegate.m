//
//  AppDelegate.m
//  Locamatic
//
//  Created by Pascal Harris on 21/02/2013.
//  Copyright (c) 2013 Pascal Harris. All rights reserved.
//

#import "AppDelegate.h"
#import "System Preferences.h"

@implementation AppDelegate

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
#if MD_DEBUG
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif

    return YES;
}

- (NSArray*)defaultRouter
{
    NSMutableArray* returnArray = [[NSMutableArray alloc]init];
    if ([CWInterface interface].ssid)
        [returnArray addObject:[CWInterface interface].ssid];
    
    SCDynamicStoreRef ds = SCDynamicStoreCreate(kCFAllocatorDefault, CFSTR("myapp"), NULL, NULL);
    CFDictionaryRef dr = SCDynamicStoreCopyValue(ds, CFSTR("State:/Network/Global/IPv4"));
    if (dr)
    {
        CFStringRef router = CFDictionaryGetValue(dr, CFSTR("Router"));
        if ((__bridge NSString *)router)
            [returnArray addObject:[NSString stringWithString:(__bridge NSString *)router]];
        CFRelease(dr);
    }
    CFRelease(ds);
    
    return [returnArray copy];
}

- (bool) setLocationForNetwork //:(NSString*)networkName
{
    if (paused) return NO;
    
    NSString *pathToscselect = [NSString stringWithFormat:@"/usr/sbin/scselect"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:pathToscselect])
		return false;
    
    if ([[self defaultRouter] count]==0)
        return false;
    
    NSString* currentGateway = [[NSString alloc]init];
    NSArray* routerArray = [self defaultRouter]; //18Oct
    if ([routerArray count]==0) return false; //maybe just set to automatic in this case
    currentGateway = [routerArray objectAtIndex:0];
    
    NSMutableString* networkLocation = [[NSMutableString alloc]init];
    
    NSDictionary* locationSettings = [[NSMutableDictionary alloc] initWithDictionary:[PreferencesHelper getDictForKey:@"Location Settings" withPersistentDomain:@"com.45RPMSoftware.Locamatic"]];
    
    for (NSString* locationName in [locationSettings allKeys])
    {
        if ([[[locationSettings objectForKey:locationName] objectForKey:@"SelectedNetworks"] containsObject:currentGateway])
        {
            networkLocation = [NSMutableString stringWithString:locationName];
            
            break;
        }
    }
    if ((!networkLocation)||([networkLocation length]==0))
        networkLocation = [NSMutableString stringWithString:@"Automatic"];
    
    //Insert location into Menu
    NSMenuItem *newMenu = [[NSMenuItem alloc] initWithTitle:networkLocation
                                                     action:NULL //@selector(locationClicked:)
                                              keyEquivalent:@""];
    [newMenu setTarget:self];
    [newMenu setEnabled:NO];
    [locamaticMenu removeItemAtIndex:0];
    [locamaticMenu insertItem:newMenu atIndex:0];
    
    //Change network Location
    NSString *cmdResult = bashTask([NSString stringWithFormat:@"/usr/sbin/scselect \"%@\"",networkLocation]);
    
    CFURLRef appURL;
    LSGetApplicationForURL((__bridge CFURLRef)[NSURL URLWithString: @"http:"],
                           kLSRolesAll, NULL, (CFURLRef*)&appURL);
    NSString* defaultWebBrowser = [[(__bridge_transfer NSURL*)appURL path]lastPathComponent];
    
    //Change default homepage
    NSString* thisHomepage = [[locationSettings objectForKey:networkLocation] objectForKey:@"SelectedHomepage"];
    if ((thisHomepage)&&([thisHomepage length]>0))
    {
        if ([defaultWebBrowser isEqualToString:@"Safari.app"]) //need to handle Firefox, Chrome, Opera, Omniweb
        {
            //check the default browser and update the appropriate settings.
            cmdResult = bashTask([NSString stringWithFormat:@"defaults write com.apple.Safari HomePage '%@'",[NSString stringWithString:thisHomepage]]);
            cmdResult = bashTask([NSString stringWithFormat:@"defaults write com.apple.internetconfigpriv WWWHomePage '%@'",[NSString stringWithString:thisHomepage]]);
            bool restartBrowser=false; //this will be a preference setting
            if (restartBrowser) //need to be cleverer than this and check if safari is running before doing this.  Also need to check what the default browser is.
            {
                //      [[NSWorkspace sharedWorkspace] runningApplications];
                for (NSRunningApplication *currApp in [[NSWorkspace sharedWorkspace] runningApplications])
                {
                    if ([[currApp localizedName] isEqualToString:@"Safari"])
                    {
                        cmdResult = bashTask(@"osascript -e 'quit app \"Safari\"'");
                        cmdResult = bashTask(@"open -a Safari");
                    }
                }
            }
        }
    }
    
    NSString* thisPrinter = [[locationSettings objectForKey:networkLocation] objectForKey:@"SelectedPrinter"];
    if ((thisPrinter)&&([thisPrinter length]>0))
    {
        cmdResult = bashTask([NSString stringWithFormat:@"lpoptions -d \"%@\"",[NSString stringWithString:thisPrinter]]);
    }
    
    NSString* notificationTitle = @"Locamatic has changed your Location";
    NSString* informationText = [NSString stringWithFormat:@"New Location is %@",networkLocation];
    if ([[[[NSDictionary dictionaryWithContentsOfFile:
            @"/System/Library/CoreServices/SystemVersion.plist"]
           objectForKey:@"ProductVersion"] substringToIndex:4]floatValue]>=10.8)
    {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = notificationTitle;
        notification.informativeText = informationText;
        notification.soundName = nil;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    else if ([GrowlApplicationBridge isGrowlRunning]) //need to grey out Growl in preferences too.
    {
        //use Growl
        [GrowlApplicationBridge notifyWithTitle:notificationTitle
                                    description:informationText
                               notificationName:@"locamaticNotification"
                                       iconData:nil
                                       priority:0
                                       isSticky:NO
                                   clickContext:nil];
    }

    return true;
}


- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    if(curReach == hostReach)
    {
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        BOOL connectionRequired= [curReach connectionRequired];
        
        NSString* baseLabel=  @"";
        if(connectionRequired)
        {
            printf("Network is available\n"); //this just seems to indicate that we have an available NIC
        }
        else
        {
            printf("Connection Established\n"); //and this indicates that we can connect to the network - whether or not we can reach the actual internet
            
            bool LocationSet = [self setLocationForNetwork];
            //   SCNetworkSetRef currLoc = SCNetworkSetCopyCurrent(prefs);
            
            //Need to set the location here.
            //need to set the printer
            //need to set the home page
            //need to run any applicable preferences
        }
    }
    if(curReach == internetReach)
    {
        printf("internetReach\n");
    }
    if(curReach == wifiReach)
    {
        printf("wifiReach\n");
    }
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
}

- (void) receiveWakeNote: (NSNotification*) note
{
    dispatch_block_t codeForExecutionOnMainThread = ^{ //need to ensure that we run on the main thread
        noStartAlert=true;
    };
    if ([NSThread isMainThread]) //If this is the main thread, go ahead
    {
        codeForExecutionOnMainThread();
    }
    else //If it isn't then switch to the main thread before executing.
    {
        dispatch_sync(dispatch_get_main_queue(), codeForExecutionOnMainThread);
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //Listen to instructions from the Preference Pane
    NSDistributedNotificationCenter *centre = [NSDistributedNotificationCenter defaultCenter];
    [centre addObserver:self
               selector:@selector(setMenubar:)
                   name:@"com.45rpmsoftware.locamatic.SetMenubar"
                 object:nil
     suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
    [centre addObserver:self
               selector:@selector(quitLocamatic:)
                   name:@"com.45rpmsoftware.locamatic.SetOff"
                 object:nil
     suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
    [centre addObserver:self
               selector:@selector(refreshPrefs:)
                   name:@"com.45rpmsoftware.locamatic.Refresh"
                 object:nil
     suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
    [centre addObserver:self
               selector:@selector(showMyHelp:)
                   name:@"com.45rpmsoftware.locamatic.ShowHelp"
                 object:nil
     suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
    
    // Insert code here to initialize your application
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];

    hostReach = [Reachability reachabilityWithHostName: @"www.apple.com"];
    [hostReach startNotifier];
    [self updateInterfaceWithReachability: hostReach];
    
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    [self updateInterfaceWithReachability: internetReach];
    
    wifiReach = [Reachability reachabilityForLocalWiFi];
    [wifiReach startNotifier];
    [self updateInterfaceWithReachability: wifiReach];
    
    paused=false;
    
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

-(void)displayMenu:(BOOL)displayMenu
{
    if (displayMenu)
    {
        //Create the NSStatusBar and set its length
        statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        
        //Used to detect where our files are
        NSBundle *bundle = [NSBundle mainBundle];
        
        //Allocates and loads the images into the application which will be used for our NSStatusItem
        statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"House" ofType:@"tiff"]];
        statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"HouseInverted" ofType:@"tiff"]];
        
        //Sets the images in our NSStatusItem
        [statusItem setImage:statusImage];
        [statusItem setAlternateImage:statusHighlightImage];
        
        //Tells the NSStatusItem what menu to load
        [statusItem setMenu:locamaticMenu];
        
        //Enables highlighting
        [statusItem setHighlightMode:YES];
    }
    else
    {
        [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
    }

}

-(void)setMenubar:(NSNotification *) aNote
{
    [self displayMenu:[[aNote.userInfo objectForKey:@"ShowMenuBar"]boolValue]];
}

-(void)quitLocamatic:(NSNotification *) aNote
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self
                                                               name: @"com.45rpmsoftware.locamatic.SetMenubar"
                                                             object: nil];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self
                                                               name: @"com.45rpmsoftware.locamatic.SetOff"
                                                             object: nil];
    
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self
                                                               name: @"com.45rpmsoftware.locamatic.Refresh"
                                                             object: nil];
    
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self
                                                               name: @"com.45rpmsoftware.locamatic.ShowHelp"
                                                             object: nil];
    
   [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

-(void)refreshPrefs:(NSNotification *) aNote
{
    NSLog(@"Received Notification, Refreshing Preferences");
}

-(IBAction)quitEngine:(id)sender
{
    [self quitLocamatic:nil];
}

- (void) awakeFromNib
{
    [self displayMenu:TRUE];
}

-(IBAction)showPreferences:(id)sender
{
   //Need to load preference pane here.
    SystemPreferencesApplication *SystemPreferences = [SBApplication applicationWithBundleIdentifier:@"com.apple.systempreferences"];
    @try {
        [SystemPreferences activate];
        SystemPreferences.currentPane = [SystemPreferences.panes objectWithID:@"com.45RPMSoftware.Locamatic"];
    } @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
    }
}

-(IBAction)pauseLocamatic:(id)sender
{
    paused = !paused;
    (paused==false)?[[locamaticMenu itemAtIndex:1]setTitle:@"Pause"]:[[locamaticMenu itemAtIndex:1]setTitle:@"Resume"];
}

-(IBAction)aboutLocamatic:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:self];
}

-(void)showMyHelp:(NSNotification *) aNote
{
    [[NSApplication sharedApplication] showHelp:nil]; 
}


@end
