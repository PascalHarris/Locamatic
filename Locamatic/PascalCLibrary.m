/*
 *  PascalCLibrary.c
 *  Mail Reader
 *
 *  Created by Pascal Harris on 03/06/2008.
 *  Copyright 2008 - 2010 45RPM Software. All rights reserved. 
 *
 */

#include "PascalCLibrary.h"

#pragma mark -
#pragma mark Task Functions

NSString* runTask (NSString* taskName, NSArray* taskParams)
{
    NSLog(@"%@ - %@",taskName,taskParams);
    
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:taskName];	
	[task setArguments: taskParams];
	NSPipe *taskPipe = [NSPipe pipe];
	[task setStandardOutput: taskPipe];
	[task setStandardError: [task standardOutput]];
	NSFileHandle *taskFile = [taskPipe fileHandleForReading];
	[task launch]; 
	NSString *taskOutput = [[NSString alloc] initWithData: [taskFile readDataToEndOfFile] 
												 encoding: NSUTF8StringEncoding];	
	return [taskOutput copy];//[[taskOutput copy] autorelease];//
}

NSString* bashTask (NSString* taskName)
{
    NSLog(@"%@",taskName);
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:@"/bin/bash"];
	[task setArguments: @[@"-c",taskName]];
	NSPipe *taskPipe = [NSPipe pipe];
	[task setStandardOutput: taskPipe];
	[task setStandardError: [task standardOutput]];
	NSFileHandle *taskFile = [taskPipe fileHandleForReading];
	[task launch];
	NSString *taskOutput = [[NSString alloc] initWithData: [taskFile readDataToEndOfFile]
												 encoding: NSUTF8StringEncoding];
	return [taskOutput copy];//[[taskOutput copy] autorelease];//
}


