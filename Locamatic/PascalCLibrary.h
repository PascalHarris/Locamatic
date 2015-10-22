/*
 *  PascalCLibrary.h
 *  Mail Reader
 *
 *  Created by Pascal Harris on 03/06/2008.
 *  Copyright 2008 - 2010 45RPM Software. All rights reserved. 
 *
 */
#include <stdio.h>
#include <math.h>
#include <string.h> 
#include <stdlib.h>
#include <stdarg.h>
#include <CoreFoundation/CoreFoundation.h>

#pragma mark -
#pragma mark Task Functions
NSString* runTask (NSString* taskName, NSArray* taskParams);
NSString* bashTask (NSString* taskName);
