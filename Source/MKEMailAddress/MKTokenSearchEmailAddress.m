//
//  MVNTokenSearchEmailAddress.m
//  MailMaven
//
//  Created by Scott Little on 06/09/2017.
//  Copyright © 2017 SmallCubed. All rights reserved.
//

#import "MKTokenSearchEmailAddress.h"

@implementation MKTokenSearchEmailAddress

- (NSString *)searchDisplayStringWithPrefix:(NSString *)prefix {
	
	if (self.addressBookPerson) {
		NSString * firstName = [self.addressBookPerson valueForProperty:kABFirstNameProperty];
		NSString * lastName = [self.addressBookPerson valueForProperty:kABLastNameProperty];
		ABMultiValue * emailValues = [self.addressBookPerson valueForProperty:kABEmailProperty];

		NSString * emailAddress = [emailValues valueForIdentifier:self.addressBookIdentifier];
		if (emailAddress.length == 0) {
			return nil;
		}
		
		NSString * lowerPrefix = [prefix lowercaseString];
		NSMutableString * result = [NSMutableString string];
		if ([[emailAddress lowercaseString] hasPrefix:lowerPrefix]) {
			[result appendString:emailAddress];
			if (firstName || lastName) {
				[result appendString:@" ("];
				[result appendFormat:@"%@%@%@)", (firstName?:@""), ((firstName && lastName)?@" ":@""), (lastName?:@"")];
			}
		}
		else if ([[firstName lowercaseString] hasPrefix:lowerPrefix]) {
			if (!firstName) { return nil; }
			[result appendFormat:@"%@%@%@", (firstName?:@""), ((firstName && lastName)?@" ":@""), (lastName?:@"")];
			[result appendFormat:@" — %@", emailAddress];
		}
		else if ([[lastName lowercaseString] hasPrefix:lowerPrefix]) {
			if (!lastName) { return nil; }
			BOOL hasBoth = (firstName && lastName);
			[result appendFormat:@"%@%@%@%@", (lastName?:@""), (hasBoth?@" (":@""), (firstName?:@""), (hasBoth?@")":@"")];
			[result appendFormat:@" — %@", emailAddress];
		}
		else {
			return nil;
		}
		return result;
	}

	NSString * address = self.userAtDomain;
	NSString * comment = self.addressComment;
	NSString * format = @"%1$@ (%2$@)";
	if (comment.length == 0) {
		format = @"%1$@%2$@";
		comment = @"";
	}
	return [NSString stringWithFormat:format, address, comment];
}

@end
