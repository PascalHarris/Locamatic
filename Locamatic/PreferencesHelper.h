//
//  PreferencesHelper.h
//  Locamatic
//
//  Created by Pascal Harris on 15/11/2013.
//  Copyright (c) 2013 Pascal Harris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferencesHelper : NSObject {}

+(NSString*)getStringForKey:(NSString*)key withPersistentDomain:(NSString*)domainName;
+(NSInteger)getIntForkey:(NSString*)key withPersistentDomain:(NSString*)domainName;
+(NSDictionary*)getDictForKey:(NSString*)key withPersistentDomain:(NSString*)domainName;
+(NSArray*)getArrayForKey:(NSString*)key withPersistentDomain:(NSString*)domainName;
+(BOOL)getBoolForKey:(NSString*)key withPersistentDomain:(NSString*)domainName;
+(NSString*)getStringForKey:(NSString*)key;
+(NSInteger)getIntForkey:(NSString*)key;
+(NSDictionary*)getDictForKey:(NSString*)key;
+(NSArray*)getArrayForKey:(NSString*)key;
+(BOOL)getBoolForKey:(NSString*)key;
+(void)setString:(NSString*)value forKey:(NSString*)key;
+(void)setInt:(NSInteger)value forKey:(NSString*)key;
+(void)setDict:(NSDictionary*)value forKey:(NSString*)key;
+(void)setArray:(NSArray*)value forKey:(NSString*)key;
+(void)setBool:(BOOL)value forKey:(NSString*)key;

@end
