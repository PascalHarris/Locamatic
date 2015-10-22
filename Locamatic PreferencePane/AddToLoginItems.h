//
//  AddToLoginItems.h
//  Locamatic
//
//  Created by Pascal Harris on 14/12/2013.
//  Copyright (c) 2013 Pascal Harris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddToLoginItems : NSObject {}

+ (BOOL)isLaunchAtStartupForBundlePath:(NSString*)path;
+ (void)toggleLaunchAtStartupForBundlePath:(NSString*)path;
+ (void)setLaunchAtStartupTo:(BOOL)startupState ForBundlePath:(NSString*)path;
+ (LSSharedFileListItemRef)itemRefInLoginItemsForBundlePath:(NSString*)path;

@end
