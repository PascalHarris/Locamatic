//
//  Locamatic.m
//  Locamatic
//
//  Created by Pascal Harris on 03/12/2013.
//  Copyright (c) 2013 Pascal Harris. All rights reserved.
//

#import "Locamatic.h"

@implementation Locamatic

#pragma mark -
#pragma mark Prefpane gofers

-(void) refreshNetworkView
{
    //if we select Automatic then hide the network table - otherwise show it.
    if ([[locationsArray objectAtIndex:[_locationsTable selectedRow]]isEqualToString:@"Automatic"])
    {
        [[_networkTable enclosingScrollView] setHidden:true];
        [_addButt setHidden:true];
        [_subButt setHidden:true];
        [_barButt setHidden:true];
        [_netNotice setHidden:true];
    }
    else
    {
        [[_networkTable enclosingScrollView] setHidden:false];
        [_addButt setHidden:false];
        [_subButt setHidden:false];
        [_barButt setHidden:false];
        [_netNotice setHidden:false];
    }
    [_networkTable reloadData]; //We've selected a new location - need to update the network table,
}

// Validate IP Address
-(bool) isValidIpAddress:(NSString *)ipAddress
{
    struct sockaddr_in sa;
    int result = inet_pton(AF_INET, [ipAddress UTF8String], &(sa.sin_addr));
    return result != 0;
}

// Validate URL
-(bool) urlIsValid:(NSString *)URL
{
    NSURL *myURL = [NSURL URLWithString:URL];
    if (myURL && myURL.scheme && myURL.host)
    {
        NSLog(@"URL is validated");
        return true;
    }
    return false;
}

- (void)getAllKnownNetworks
{
    NSString *configPath = @"/Library/Preferences/SystemConfiguration/preferences.plist";
    
    if (knownNetworksArray == nil)
        knownNetworksArray = [[NSMutableArray alloc] init];
    
    @try
    {
        NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:configPath];
        NSDictionary *sets = [config objectForKey:@"Sets"];
        
        for (NSString *setKey in sets)
        {
            NSDictionary *set = [sets objectForKey:setKey];
            NSDictionary *network = [set objectForKey:@"Network"];
            NSDictionary *interface = [network objectForKey:@"Interface"];
            for(NSString *interfaceKey in interface)
            {
                NSDictionary *bsdInterface = [interface objectForKey:interfaceKey];
                for(NSString *namedInterfaceKey in bsdInterface)
                {
                    NSDictionary *namedInterface = [bsdInterface objectForKey:namedInterfaceKey];
                    NSArray *networks = [namedInterface objectForKey:@"PreferredNetworks"];
                    for (NSDictionary *network in networks)
                    {
                        NSString *ssid = [network objectForKey:@"SSID_STR"];
                        if ([knownNetworksArray indexOfObject:ssid] == NSNotFound)
                        {
                            [knownNetworksArray addObject:ssid];
                        }
                    }
                }
            }
        }
    }
    @catch (NSException * e)
    {
        NSLog(@"Failed to read known networks: %@", e);
    }
    
    NSString *rememberedPath = @"/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist";
    
    @try
    {
        NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:rememberedPath];
        NSArray *RNetworks = [config objectForKey:@"RememberedNetworks"];
        
        for (NSDictionary* network in RNetworks)
        {
            NSString *ssid = [network objectForKey:@"SSIDString"];
            if ([knownNetworksArray indexOfObject:ssid] == NSNotFound)
            {
                [knownNetworksArray addObject:ssid];
            }
        }
    }
    @catch (NSException * e)
    {
        NSLog(@"Failed to read remembered networks: %@", e);
    }
    
    [knownNetworksArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

-(void) getNetworkLocations
{
    if (locationsArray==nil)
        locationsArray = [[NSMutableArray alloc] init];
    
    SCPreferencesRef prefs = SCPreferencesCreate(NULL, CFSTR("SystemConfiguration"), NULL);
    NSArray *locations = (__bridge NSArray *)SCNetworkSetCopyAll(prefs);
    for (id item in locations)
    {
        if([locationsArray indexOfObject:(__bridge NSString *)SCNetworkSetGetName((__bridge SCNetworkSetRef)item)] == NSNotFound)
            [locationsArray addObject:(__bridge NSString *)SCNetworkSetGetName((__bridge SCNetworkSetRef)item)];
    }
    [locationsArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    CFRelease((__bridge CFTypeRef)(locations));
    CFRelease(prefs);
    [_locationsTable reloadData];
}

-(void) getKnownPrinters
{
    [_printerList removeAllItems];
    [_printerList addItemWithTitle:@""];
    [_printerList addItemsWithTitles:[NSPrinter printerNames]];
}

-(void) getKnownHomePages
{
    if (homePageArray==nil)
        homePageArray = [[NSMutableArray alloc] init];
    //set some defaults
    [homePageArray addObject:@"http://www.google.com"]; //will want to localize these
    [homePageArray addObject:@"http://www.duckduckgo.com"];
    [homePageArray addObject:@"http://www.dogpile.com"];
    [homePageArray addObject:@"http://www.ask.com"];
    [homePageArray addObject:@"http://www.bing.com"];
    [homePageArray addObject:@"http://www.yahoo.com"];
    [homePageArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    [homePageArray addObjectsFromArray:additionalHomepages];
    
}

#pragma mark -
#pragma mark Prefpane user interface

-(IBAction)selectView:(id)sender
{
    [_preferenceViews selectTabViewItemAtIndex:[[sender identifier]intValue]];
    [_pluginTable setRowHeight:36];
    [_pluginTable reloadData];
    
}

- (IBAction)printerSelect:(id)sender
{
    NSMutableDictionary* mutableEntry = [[preferencesDictionary objectForKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]]mutableCopy];
    [mutableEntry setObject:[_printerList titleOfSelectedItem] forKey:@"SelectedPrinter"];
    [preferencesDictionary setObject:mutableEntry forKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]];
}

-(NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return [homePageArray count];
}

-(id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)loc
{
    return [homePageArray objectAtIndex:loc];
}

-(IBAction)homepageEditComplete:(id)sender
{
    //change to names rather than numbers
    if ([homePageArray indexOfObject:[sender objectValue]] == NSNotFound)
    {
        NSString* myURL;
        if ([self urlIsValid:[sender objectValue]])
        {
            myURL =[sender objectValue];
        }
        else if ([self urlIsValid:[@"http://" stringByAppendingString:[sender objectValue]]])
        {
            myURL = [@"http://" stringByAppendingString:[sender objectValue]];
        }
        if (myURL)
        {
            [homePageArray addObject:myURL];
            [additionalHomepages addObject:myURL]; // need to develop a way of removing additional Homepages
        }
    }
    
    NSMutableDictionary* mutableEntry = [[preferencesDictionary objectForKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]]mutableCopy];
    
    if ([_homepageList indexOfSelectedItem]>=0)
    {
        [mutableEntry setObject:[homePageArray objectAtIndex:[_homepageList indexOfSelectedItem]] forKey:@"SelectedHomepage"];
    }
    else
    {
        [mutableEntry setObject:[homePageArray objectAtIndex:[homePageArray count]-1] forKey:@"SelectedHomepage"];
        
    }
    // replace entry
    [preferencesDictionary setObject:mutableEntry
                              forKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]];
}
#pragma mark -
#pragma mark Table Combo Box Handler
-(id)comboBoxCell:(NSComboBoxCell*)cell objectValueForItemAtIndex:(int)index
{
    NSArray *values = [cell representedObject];
    
    if(values == nil)
        return @"";
    else
        return [values objectAtIndex:index];
}

-(NSInteger)numberOfItemsInComboBoxCell:(NSComboBoxCell*)cell
{
    NSArray *values = [cell representedObject];
    if(values == nil)
        return 0;
    else
        return [values count];
}

-(NSInteger)comboBoxCell:(NSComboBoxCell*)cell indexOfItemWithStringValue:(NSString*)st
{
    NSArray *values = [cell representedObject];
    if(values == nil)
        return NSNotFound;
    else
        return [values indexOfObject:st];
}

/* delegate for the NSTableView
 since there's only one combo box for all the lines, we need to populate it with the proper
 values for the line as set its selection, etc.
 this is optional, the alternative is to set a list of values in interface builder  */

-(void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn row:(int)index
{
    if((tableView == _networkTable) && [cell isKindOfClass:[NSComboBoxCell class]]) //[[tableColumn identifier] isEqual:@"operation"] &&
    {
        [cell setRepresentedObject:knownNetworksArray];
        [cell reloadData];
    }
}

#pragma mark -
#pragma mark Plugin Table Handlers
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == _locationsTable)
        return [locationsArray count];
    else if (tableView == _networkTable)
    {
        return [[[preferencesDictionary objectForKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]]objectForKey:@"SelectedNetworks"] count];
    }
    else
        return 0;
}

-(void)tableView:(NSTableView*)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn*)tableColumn row:(int)index
{
	if(nil == value)
		value = @"";
	if(tableView == _networkTable)
	{
        //Need to validate the entry here - check that the gateway address being added is valid
        if ([knownNetworksArray indexOfObject:value] == NSNotFound)
        {
            //   if([self isValidIpAddress:value])
            [knownNetworksArray addObject:value];
            //       else value = @"";
        }
        NSComboBoxCell *cell = [tableView selectedCell];
        [cell reloadData];
        
        [[[preferencesDictionary objectForKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]] objectForKey:@"SelectedNetworks"] replaceObjectAtIndex:index withObject:value];
	}
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn
			row:(NSInteger)row
{
    id theValue; //, theRecord;
    
    if (tableView == _locationsTable)
    {
        if ([_locationsTable selectedRow]>[locationsArray count])
        {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[locationsArray count]-1];
            [_locationsTable selectRowIndexes:indexSet byExtendingSelection:NO];
        }
        
        
        theValue = [locationsArray objectAtIndex:row];
        id SelectedRow = [locationsArray objectAtIndex:[_locationsTable selectedRow]];
        if (![preferencesDictionary objectForKey:SelectedRow])
        {
            [preferencesDictionary setObject:[[NSMutableDictionary alloc]init] forKey:SelectedRow];
        }
        
        [self refreshNetworkView];
        
        if ([[preferencesDictionary objectForKey:SelectedRow] objectForKey:@"SelectedPrinter"])
        {
            [_printerList selectItemWithTitle:[[preferencesDictionary objectForKey:SelectedRow] objectForKey:@"SelectedPrinter"]];
        }
        else
        {
            [_printerList selectItemAtIndex:0];
        }
        
        if ([[preferencesDictionary objectForKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]] objectForKey:@"SelectedHomepage"])
        {
            [_homepageList reloadData];
            
            [_homepageList selectItemAtIndex:[homePageArray indexOfObject:[[preferencesDictionary objectForKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]] objectForKey:@"SelectedHomepage"]]];
            
            
        }
        else
        {
            [_homepageList deselectItemAtIndex:[_homepageList indexOfSelectedItem]];
        }
    }
    else if (tableView == _networkTable)
    {
        theValue = [[[preferencesDictionary objectForKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]]objectForKey:@"SelectedNetworks"]objectAtIndex:row];
    }
    else
        theValue = nil;
 	
	return theValue;
}

- (IBAction)locationRowSelected:(id)sender
{
    //  reload the settings for the currently selected location.
}

- (IBAction)addNetworkRow:(id)sender
{
    NSMutableDictionary* mutableEntry;// =[[preferencesDictionary objectForKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]]mutableCopy];
    NSMutableArray* mutableNetworkList; //List of array entries

    if (![[preferencesDictionary objectForKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]] objectForKey:@"SelectedNetworks"])
    {
        mutableEntry = [[NSMutableDictionary alloc]init];
        mutableNetworkList = [[NSMutableArray alloc]init];
    }
    else
    {
        mutableEntry = [[preferencesDictionary objectForKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]]mutableCopy];
        mutableNetworkList =  [[[preferencesDictionary objectForKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]] objectForKey:@"SelectedNetworks"]mutableCopy];
    }
    [mutableNetworkList addObject:@""];//Add a new, blank, array object for modification by the user
    [mutableEntry setObject:mutableNetworkList forKey:@"SelectedNetworks"];
    [preferencesDictionary setObject:mutableEntry
                              forKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]];
    
    unsigned long rowCount = [[[preferencesDictionary objectForKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]] objectForKey:@"SelectedNetworks"] count];
    [_networkTable reloadData];
    [_networkTable selectRowIndexes:[NSIndexSet indexSetWithIndex:(rowCount - 1)] byExtendingSelection:NO];
    [_networkTable editColumn:0 row:(rowCount - 1) withEvent:nil select:YES];
}

- (IBAction)removeNetworkRow:(id)sender
{
    unsigned long rowCount = [[[preferencesDictionary objectForKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]] objectForKey:@"SelectedNetworks"] count];
    if ([_networkTable selectedRow] < 0 || [_networkTable selectedRow] >= rowCount)
        return;
    
    NSMutableDictionary* mutableEntry = [[preferencesDictionary objectForKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]]mutableCopy];
    NSMutableArray* mutableArray = [[mutableEntry objectForKey:@"SelectedNetworks"]mutableCopy];
    [mutableArray removeObjectAtIndex:[_networkTable selectedRow]];
    [mutableEntry setObject:mutableArray forKey:@"SelectedNetworks"];
    [preferencesDictionary setObject:mutableEntry forKey:[locationsArray objectAtIndex:[_locationsTable selectedRow]]];
    
    [_networkTable reloadData];
    
}

- (IBAction)editNetworkRow:(id)sender
{
    
}

#pragma mark -
#pragma mark Locamatic Application Settings

- (IBAction)showMenuBarItem:(id)sender
{
    bool openDialogue = [_showMenuItem state]==NSOnState?true:false;
    NSDistributedNotificationCenter *centre = [NSDistributedNotificationCenter defaultCenter];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:openDialogue] forKey:@"ShowMenuBar"];
    [centre postNotificationName:@"com.45rpmsoftware.locamatic.SetMenubar" object:nil userInfo:dict];
    
 //   NSLog(@"Posted Toggle Menu bar item");

}

- (void)activityCheck
{
    if (([self locamaticIsRunning])&&([_onOffSwitch state]==NSOffState))
    {
        [_onOffSwitch setState:NSOnState];
    }
    else if ((![self locamaticIsRunning])&&([_onOffSwitch state]==NSOnState))
    {
        [_onOffSwitch setState:NSOffState];
    }
    [self setActive:_onOffSwitch];

}

- (IBAction)setActive:(id)sender
{
    SEL theSelector = @selector(activityCheck);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [self methodSignatureForSelector:theSelector]];
    [invocation setSelector:theSelector];
    [invocation setTarget:self];
    
    NSImage* buttonImage;
    if ([sender state]==NSOnState)
    {
        buttonImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/SwitchRight.tiff",bundlepath]];
        
        //need to load locamatic here
        if (![self locamaticIsRunning])
        {
            [[NSWorkspace sharedWorkspace] launchApplication:[NSString stringWithFormat:@"%@/Contents/Resources/Locamatic Engine.app",bundlepath]];
            
            [NSTimer scheduledTimerWithTimeInterval:0.5 invocation:invocation repeats:NO];
        }
        
    }
    else if ([sender state]==NSOffState)
    {
        buttonImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/SwitchLeft.tiff",bundlepath]];
        
        if ([self locamaticIsRunning])
        {
            NSDistributedNotificationCenter *centre = [NSDistributedNotificationCenter defaultCenter];
            NSDictionary *dict = [NSDictionary dictionaryWithObject:@"quit" forKey:@"QuitApplication"];
            [centre postNotificationName:@"com.45rpmsoftware.locamatic.SetOff" object:nil userInfo:dict];
            
    //        NSLog(@"Posted Quit");
            
            [NSTimer scheduledTimerWithTimeInterval:1 invocation:invocation repeats:NO];
        }
    }
    
    [sender setImage:buttonImage];
    [sender setAlternateImage:buttonImage];
}

- (IBAction)toggleLaunchAtStartup:(id)sender
{
    if ([sender state]==NSOnState)
    {
        [AddToLoginItems setLaunchAtStartupTo:TRUE ForBundlePath:[NSString stringWithFormat:@"%@/Contents/Resources/Locamatic Engine.app",bundlepath]];
    }
    else
    {
        [AddToLoginItems setLaunchAtStartupTo:FALSE ForBundlePath:[NSString stringWithFormat:@"%@/Contents/Resources/Locamatic Engine.app",bundlepath]];
    }
}

#pragma mark -
#pragma mark Prefpane handlers

-(void) loadPreferences
{
    NSDictionary *prefs=[[NSUserDefaults standardUserDefaults]
                         persistentDomainForName:[[NSBundle bundleForClass:[self class]]
                                                  bundleIdentifier]];

    preferencesDictionary = [[NSMutableDictionary alloc]
                             initWithDictionary:[prefs objectForKey:@"Location Settings"]];
    additionalHomepages = [[NSMutableArray alloc]
                           initWithArray:[prefs objectForKey:@"Additional Homepages"]];
    licensing = [[NSMutableDictionary alloc]
                 initWithDictionary:[prefs objectForKey:@"Licensing"]];

}

- (BOOL)locamaticIsRunning
{
    NSArray *appNames = [[NSWorkspace sharedWorkspace] runningApplications];
    NSMutableArray *appNameArray = [[NSMutableArray alloc]init];
    
    for (NSRunningApplication* appName in appNames)
    {
        [appNameArray addObject:appName.localizedName];
    }

    if ([appNameArray containsObject:@"Locamatic Engine"])
    {
        return YES;
    }
    
    return NO;
}

- (void)saveChanges:(NSNotification*)aNotification
{

    if ((preferencesDictionary!=nil)&&(additionalHomepages!=nil))
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
        
        //need to force Locamatic to reload settings here.
        NSDictionary *prefs=[[NSDictionary alloc] initWithObjectsAndKeys:
                             [preferencesDictionary copy], @"Location Settings",
                             [additionalHomepages copy], @"Additional Homepages",
                             [licensing copy],@"Licensing",
                             [NSNumber numberWithBool:[updater automaticallyChecksForUpdates]],@"SUEnableAutomaticChecks",
                             [[formatter stringFromDate:[updater lastUpdateCheckDate]] copy],@"SULastCheckTime",
                             nil];

        [[NSUserDefaults standardUserDefaults] setPersistentDomain:prefs
                                                           forName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //Now refresh settings
        NSDistributedNotificationCenter *centre = [NSDistributedNotificationCenter defaultCenter];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"refresh" forKey:@"RefreshPreferences"];
        [centre postNotificationName:@"com.45rpmsoftware.locamatic.Refresh" object:nil userInfo:dict];
        
    }
}

- (void)awakeFromNib
{
    bundlepath = [[NSString alloc] initWithString:[[NSBundle bundleForClass:[self class]] bundlePath]];
    
    if (![[NSHelpManager sharedHelpManager] registerBooksInBundle:[NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/Contents/Resources/Locamatic Engine",bundlepath]]])
    {
        NSLog(@"Failed to register Help for Locamatic.prefpane in bundle %@",[NSString stringWithFormat:@"%@/Contents/Resources/Locamatic Engine",bundlepath]);
    }
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSDictionary* activityState = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Locamatic/activitycheck",
                                                                                [paths objectAtIndex:0]]];
    if (activityState) //clearly we did do an update
    {
        if ([[activityState objectForKey:@"state"] booleanValue])
        {
            [[NSWorkspace sharedWorkspace] launchApplication:[NSString stringWithFormat:@"%@/Contents/Resources/Locamatic Engine.app",bundlepath]];
        }
        //delete our update state settings
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        [fileMgr removeItemAtPath:[NSString stringWithFormat:@"%@/Locamatic/activitycheck",[paths objectAtIndex:0]] error:NULL];
        
    }
    
    if (_onOffSwitch!=nil)
    {
        if ([self locamaticIsRunning])
        {
            [_onOffSwitch setState:NSOnState];
        }
        else
        {
            [_onOffSwitch setState:NSOffState];
        }
        [self setActive:_onOffSwitch];
        
    }
    
    updater = [[SUUpdater alloc]initForBundle:[NSBundle bundleForClass:[self class]]];
    [updater setAutomaticallyChecksForUpdates:YES];
    [updater resetUpdateCycle];
    updater.delegate = self;
}

- (void) mainViewDidLoad
{
    [_copyright setStringValue:[NSString stringWithFormat:@"Locamatic %@ ©2007-2014 Pascal Harris",[[[NSBundle bundleForClass:[self class]]infoDictionary]objectForKey:@"CFBundleShortVersionString"]]];
    
    [self loadPreferences];
    //Check for, and delete, legacy Locamatic Files
    //empty cache directory
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [fileMgr removeItemAtPath:[NSString stringWithFormat:@"%@/Locamatic",[paths objectAtIndex:0]]
                        error:NULL];
    
    [_pluginTable reloadData];
    [_preferenceViews selectTabViewItemAtIndex:0];
    
    [self getNetworkLocations];
    [self getAllKnownNetworks];
    [self getKnownPrinters];
    [self getKnownHomePages];
    
    //    NSLog(@"Pax %@",knownNetworksArray);
    
    //Select the first row in the locations table
    [_locationsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveChanges:)
                                                 name:NSApplicationWillTerminateNotification
                                               object:nil]; //Add functionality to save prefs.
    
    [self refreshNetworkView];
    
    //set license
    if ((![licensing objectForKey:@"LicenceEmail"])||
        (![licensing objectForKey:@"LicenceKey"])||
        (![Validators validateLicenseKey:[licensing objectForKey:@"LicenceKey"]
                       withEmailAddress:[licensing objectForKey:@"LicenceEmail"]
                            withKeyFile:[NSString stringWithFormat:@"%@/Contents/Resources/public.pem",bundlepath]]))
        [_licensedTo setStringValue:@"Nobody"];
    else
        [_licensedTo setStringValue:[licensing objectForKey:@"LicenceEmail"]];
    
    
    if ([AddToLoginItems isLaunchAtStartupForBundlePath:[NSString stringWithFormat:@"%@/Contents/Resources/Locamatic Engine.app",bundlepath]])
    {
        [_launchAtStart setState:NSOnState];
    }
    else
    {
        [_launchAtStart setState:NSOffState];
    }
}

- (void)didUnselect
{
    //tell Locamatic to update settings, if necessary
    [self saveChanges:nil];
}

#pragma mark -
#pragma mark Licensing nonsense

- (void)sheetDidEnd:(NSWindow *)sheetDidEnd
		 returnCode:(int)returnCode
		contextInfo:(void *)contextInfo
{
}

-(IBAction)showLicencingSheet:(id)sender
{
	[NSApp beginSheet:_licensingWindow
	   modalForWindow:[_locationsTable window]
		modalDelegate:self
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
    
    if ((![licensing objectForKey:@"LicenceEmail"])||
        (![licensing objectForKey:@"LicenceKey"])||
        (![Validators validateLicenseKey:[licensing objectForKey:@"LicenceKey"]
                        withEmailAddress:[licensing objectForKey:@"LicenceEmail"]
                             withKeyFile:[NSString stringWithFormat:@"%@/Contents/Resources/public.pem",bundlepath]]))
    {
        [_licenceKey setStringValue:@""];
        [_emailAddress setStringValue:@""];
    }
    else
    {
        [_licenceKey setStringValue:[licensing objectForKey:@"LicenceKey"]];
        [_emailAddress setStringValue:[licensing objectForKey:@"LicenceEmail"]];
        
        [_licensedTo setStringValue:[licensing objectForKey:@"LicenceEmail"]];

    }
    
}

-(IBAction)acceptLicencingSheet:(id)sender
{
    [_licensingWindow orderOut:sender];
	[NSApp endSheet:_licensingWindow returnCode:1];

}

-(IBAction)cancelLicencingSheet:(id)sender
{
    [_licensingWindow orderOut:sender];
	[NSApp endSheet:_licensingWindow returnCode:1];
}

-(IBAction)validateEmailField:(id)sender
{
    NSImage* buttonImage;
    if ([[_emailAddress stringValue] length]==0)
        buttonImage = nil;
    else if ([Validators validateEmailAddress:[_emailAddress stringValue]])
        buttonImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/check.tiff",bundlepath]];
    else
        buttonImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/cross.tiff",bundlepath]];
    [_validemail setImage:buttonImage];
}

-(IBAction)validateLicenceField:(id)sender
{
    NSImage* buttonImage;
    if ([[_licenceKey stringValue] length]==0)
        buttonImage = nil;
    else if([Validators validateLicenseKey:[_licenceKey stringValue]
                  withEmailAddress:[_emailAddress stringValue]
                       withKeyFile:[NSString stringWithFormat:@"%@/Contents/Resources/public.pem",bundlepath]])
    {
        buttonImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/check.tiff",bundlepath]];
        [licensing setObject:[_licenceKey stringValue] forKey:@"LicenceKey"];
        [licensing setObject:[_emailAddress stringValue] forKey:@"LicenceEmail"];
    }
    else
        buttonImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/cross.tiff",bundlepath]];
    [_validlicense setImage:buttonImage];
    
}

#pragma mark -
#pragma mark Update Locamatic
- (void)updater:(SUUpdater *)updater willInstallUpdate:(SUAppcastItem *)update
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSDictionary* activityState = @{@"state":[NSNumber numberWithBool:[self locamaticIsRunning]]};
    [activityState writeToFile:[NSString stringWithFormat:@"%@/Locamatic/activitycheck",
                                [paths objectAtIndex:0]] atomically:NO];
    
    NSDistributedNotificationCenter *centre = [NSDistributedNotificationCenter defaultCenter];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"quit" forKey:@"QuitApplication"];
    [centre postNotificationName:@"com.45rpmsoftware.locamatic.SetOff" object:nil userInfo:dict];
    
}

- (IBAction)updateLocamatic:(id)sender
{
    [updater checkForUpdates:self];
}

#pragma mark -
#pragma mark Show Help
- (IBAction)showHelp:(id)sender
{
 //   [updater checkForUpdates:self];
    NSDistributedNotificationCenter *centre = [NSDistributedNotificationCenter defaultCenter];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"help" forKey:@"ShowHelp"];
    [centre postNotificationName:@"com.45rpmsoftware.locamatic.ShowHelp" object:nil userInfo:dict];

}

@end
