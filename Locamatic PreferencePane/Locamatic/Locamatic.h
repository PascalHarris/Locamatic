//
//  Locamatic.h
//  Locamatic
//
//  Created by Pascal Harris on 03/12/2013.
//  Copyright (c) 2013 Pascal Harris. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <PreferencePanes/PreferencePanes.h>
#import <CoreFoundation/CoreFoundation.h>
#include <SystemConfiguration/SystemConfiguration.h>
#include <arpa/inet.h>
#import "Validators.h"
#import "AddToLoginItems.h"
#import <Sparkle/Sparkle.h>

@interface Locamatic : NSPreferencePane
{
    NSDictionary* pluginPackDictionary;
    
    
    NSMutableArray* locationsArray;
    NSMutableArray* knownNetworksArray;
    NSMutableArray* homePageArray;
    
    NSMutableArray* additionalHomepages;
    
    NSMutableDictionary* preferencesDictionary;
    NSMutableDictionary* licensing;
    
    NSString* bundlepath;
    
    SUUpdater *updater;
//    BOOL locamaticLoaded;
}
@property (assign) IBOutlet NSTabView* preferenceViews;
@property (assign) IBOutlet NSTableView* pluginTable;
@property (assign) IBOutlet NSTableView* locationsTable;
@property (assign) IBOutlet NSTableView* networkTable;
@property (assign) IBOutlet NSPopUpButton* printerList;
@property (assign) IBOutlet NSComboBox* homepageList;
@property (assign) IBOutlet NSView* pluginView;
@property (assign) IBOutlet NSButton* addButt;
@property (assign) IBOutlet NSButton* subButt;
@property (assign) IBOutlet NSButton* barButt;
@property (assign) IBOutlet NSTextField* netNotice;

@property (assign) IBOutlet NSButton* showMenuItem;
@property (assign) IBOutlet NSButton* onOffSwitch;
@property (assign) IBOutlet NSButton* launchAtStart;


//@property (assign) IBOutlet NSWindow* prefPaneWindow;
@property (assign) IBOutlet NSWindow* licensingWindow;
@property (assign) IBOutlet NSButton* cancelLicence;
@property (assign) IBOutlet NSButton* acceptLicence;
@property (assign) IBOutlet NSButton* showLicenceSheet;
@property (assign) IBOutlet NSTextField* emailAddress;
@property (assign) IBOutlet NSTextField* licenceKey;
@property (assign) IBOutlet NSImageView* validemail;
@property (assign) IBOutlet NSImageView* validlicense;
@property (assign) IBOutlet NSTextField* licensedTo;

@property (assign) IBOutlet NSTextField* copyright;

//- (void)mainViewDidLoad;
- (void)saveChanges:(NSNotification*)aNotification;

- (IBAction)selectView:(id)sender;

- (IBAction)homepageEditComplete:(id)sender;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn
			row:(NSInteger)row;
- (IBAction)locationRowSelected:(id)sender;
- (void)tableView:(NSTableView*)tableView
  willDisplayCell:(id)cell
   forTableColumn:(NSTableColumn*)tableColumn
              row:(int)index;


- (IBAction)addNetworkRow:(id)sender;
- (IBAction)removeNetworkRow:(id)sender;
- (IBAction)editNetworkRow:(id)sender;

- (IBAction)printerSelect:(id)sender;

- (IBAction)showMenuBarItem:(id)sender;
- (IBAction)setActive:(id)sender;
- (IBAction)toggleLaunchAtStartup:(id)sender;

- (BOOL)locamaticIsRunning;
//- (void)willSelect;
//- (void)mainViewDidLoad;
-(IBAction)showLicencingSheet:(id)sender;
-(IBAction)acceptLicencingSheet:(id)sender;
-(IBAction)cancelLicencingSheet:(id)sender;

-(IBAction)validateEmailField:(id)sender;
-(IBAction)validateLicenceField:(id)sender;

- (IBAction)updateLocamatic:(id)sender;


- (IBAction)showHelp:(id)sender;
@end
