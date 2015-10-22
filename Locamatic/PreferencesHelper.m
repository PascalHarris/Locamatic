//
//  PreferencesHelper.m
//  Locamatic
//
//  Created by Pascal Harris on 15/11/2013.
//  Copyright (c) 2013 Pascal Harris. All rights reserved.
//

#import "PreferencesHelper.h"

@implementation PreferencesHelper

+(NSString*)getStringForKey:(NSString*)key withPersistentDomain:(NSString*)domainName
{
    NSString* val = @"";
    NSDictionary *standardUserDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:domainName];
    if (standardUserDefaults) val = [standardUserDefaults valueForKey:key];
    if (val == NULL) val = @"";
    return val;
}

+(NSInteger)getIntForkey:(NSString *)key withPersistentDomain:(NSString*)domainName
{
    NSDictionary *standardUserDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:domainName];
    
    NSInteger val = 0;
    if (standardUserDefaults) val = [[standardUserDefaults valueForKey:key] intValue];
    return val;
}

+(NSDictionary*)getDictForKey:(NSString*)key withPersistentDomain:(NSString*)domainName
{
    NSDictionary* val = nil;
    NSDictionary *standardUserDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:domainName];
    if (standardUserDefaults) val = [standardUserDefaults valueForKey:key];
    return val;
}

+(NSArray*)getArrayForKey:(NSString*)key withPersistentDomain:(NSString*)domainName
{
    NSArray* val = nil;
    NSDictionary *standardUserDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:domainName];
    if (standardUserDefaults) val = [standardUserDefaults valueForKey:key];
    return val;
}

+(BOOL)getBoolForKey:(NSString*)key withPersistentDomain:(NSString*)domainName
{
    BOOL val = FALSE;
    NSDictionary *standardUserDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:domainName];
    if (standardUserDefaults) val = [[standardUserDefaults valueForKey:key] boolValue];
    return val;
}

+(NSString*)getStringForKey:(NSString*)key
{
    NSString* val = @"";
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) val = [standardUserDefaults stringForKey:key];
    if (val == NULL) val = @"";
    return val;
}

+(NSInteger)getIntForkey:(NSString *)key
{
    NSInteger val = 0;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) val = [standardUserDefaults integerForKey:key];
    return val;
}

+(NSDictionary*)getDictForKey:(NSString*)key
{
    NSDictionary* val = nil;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) val = [standardUserDefaults dictionaryForKey:key];
    return val;
}

+(NSArray*)getArrayForKey:(NSString*)key
{
    NSArray* val = nil;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) val = [standardUserDefaults arrayForKey:key];
    return val;
}

+(BOOL)getBoolForKey:(NSString*)key
{
    BOOL val = FALSE;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) val = [standardUserDefaults boolForKey:key];
    return val;
}

+(void)setString:(NSString*)value forKey:(NSString*)key
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults)
    {
		[standardUserDefaults setObject:value forKey:key];
		[standardUserDefaults synchronize];
	}
}

+(void)setInt:(NSInteger)value forKey:(NSString*)key
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults)
    {
		[standardUserDefaults setInteger:value forKey:key];
		[standardUserDefaults synchronize];
	}
}

+(void)setDict:(NSDictionary*)value forKey:(NSString*)key
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults)
    {
		[standardUserDefaults setObject:value forKey:key];
		[standardUserDefaults synchronize];
	}
}

+(void)setArray:(NSArray*)value forKey:(NSString*)key
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults)
    {
		[standardUserDefaults setObject:value forKey:key];
		[standardUserDefaults synchronize];
	}
}

+(void)setBool:(BOOL)value forKey:(NSString*)key
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults)
    {
		[standardUserDefaults setBool:value forKey:key];
		[standardUserDefaults synchronize];
	}
}

@end
