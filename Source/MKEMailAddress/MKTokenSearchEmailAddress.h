//
//  MVNTokenSearchEmailAddress.h
//  MailMaven
//
//  Created by Scott Little on 06/09/2017.
//  Copyright © 2017 SmallCubed. All rights reserved.
//

#import <MailKit/MailKit.h>

@interface MKTokenSearchEmailAddress : MKEmailAddress
- (NSString *)searchDisplayStringWithPrefix:(NSString *)prefix;
@end
