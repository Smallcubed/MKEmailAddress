//
//  MVNTokenSearchEmailAddress.m
//  MailMaven
//
//  Created by Scott Little on 06/09/2017.
//  Copyright © 2017 SmallCubed. All rights reserved.
//

#import "MKTokenSearchEmailAddress.h"

@implementation MKTokenSearchEmailAddress

- (NSString *)searchDisplayString {
	
	NSString * address = self.userAtDomain;
	NSString * comment = self.addressComment;

	if (self.addressBookPerson) {
		NSString * firstName = [self.addressBookPerson valueForProperty:kABFirstNameProperty];
		NSString * lastName = [self.addressBookPerson valueForProperty:kABLastNameProperty];
		ABMultiValue * emailValues = [self.addressBookPerson valueForProperty:kABEmailProperty];
		NSString * identifier = self.addressBookIdentifier;
		if (identifier.length == 0) {
			identifier = emailValues.primaryIdentifier;
		}
		NSString * emailAddress = [emailValues valueForIdentifier:identifier];
		if (emailAddress.length > 0) {
			address = emailAddress;
			switch (self.matchType) {
				case MVNTokenSearchMatchTypeEmail:
					if (firstName || lastName) {
						comment = [NSString stringWithFormat:@"%@%@%@", (firstName?:@""), ((firstName && lastName)?@" ":@""), (lastName?:@"")];
					}
					break;
					
				case MVNTokenSearchMatchTypeFirst:
				case MVNTokenSearchMatchTypeComment:
					if (!firstName) { return nil; }
					comment = [NSString stringWithFormat:@"%@%@%@", (firstName?:@""), ((firstName && lastName)?@" ":@""), (lastName?:@"")];
					break;
					
				case MVNTokenSearchMatchTypeLast:
					if (!lastName) { return nil; }
					BOOL hasBoth = (firstName && lastName);
					comment = [NSString stringWithFormat:@"%@%@%@%@", (lastName?:@""), (hasBoth?@" (":@""), (firstName?:@""), (hasBoth?@")":@"")];
					break;
					
			}
		}
	}
	
	NSString * format = @"%1$@ (%2$@)";
	if (self.matchType != MVNTokenSearchMatchTypeEmail) {
		format = @"%2$@ — %1$@";
	}
	return [NSString stringWithFormat:format, address, comment];
}

@end
