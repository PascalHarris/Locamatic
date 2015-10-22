//
//  Validators.m
//  Locamatic
//
//  Created by Pascal Harris on 14/12/2013.
//  Copyright (c) 2013 Pascal Harris. All rights reserved.
//

#import "Validators.h"

@implementation Validators

+(BOOL)validateEmailAddress:(NSString*)emailAddress
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,4})$";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailAddress];
}

+(BOOL)validateLicenseKey:(NSString*)licenceKey withEmailAddress:(NSString*)emailAddress withKeyFile:(NSString*)keyFilePath
{
    NSString* decryptChecksum = bashTask([NSString stringWithFormat:@"echo %@ | openssl enc -base64 -d  | openssl rsautl -verify -inkey %@ -pubin  | xxd -l 120 -ps -c 20",licenceKey,[keyFilePath stringByReplacingOccurrencesOfString:@" " withString:@"\\ "]]);
    NSString* emailChecksum = bashTask([NSString stringWithFormat:@"echo -n \"%@\" | openssl dgst -sha1",emailAddress]);
    
    if ([decryptChecksum isEqualToString:emailChecksum]) return true;
    
    return false;
}

@end
