//
//  Validators.h
//  Locamatic
//
//  Created by Pascal Harris on 14/12/2013.
//  Copyright (c) 2013 Pascal Harris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Validators : NSObject {}
+(BOOL)validateEmailAddress:(NSString*)emailAddress;
+(BOOL)validateLicenseKey:(NSString*)licenceKey withEmailAddress:(NSString*)emailAddress withKeyFile:(NSString*)keyFilePath;

@end
