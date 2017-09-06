//
//  MVNTokenSearchEmailAddress.h
//  MailMaven
//
//  Created by Scott Little on 06/09/2017.
//  Copyright © 2017 SmallCubed. All rights reserved.
//

#import <MailKit/MailKit.h>

typedef NS_ENUM(NSUInteger, MVNTokenSearchMatchType) {
	MVNTokenSearchMatchTypeEmail,
	MVNTokenSearchMatchTypeFirst,
	MVNTokenSearchMatchTypeLast,
	MVNTokenSearchMatchTypeComment
};

@interface MKTokenSearchEmailAddress : MKEmailAddress
@property (assign) MVNTokenSearchMatchType matchType;
@property (strong, readonly) NSString * _Nullable searchDisplayString;
@end
