//
//  MKEmailAddress.m
//  EmailAddressParser
//
//  Created by smorr on 2015-01-15.
//  Copyright (c) 2015 Indev Software. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


#import "MKEmailAddress.h"

#import "NSScanner+RFC2822.h"


@implementation MKEmailAddress

-(instancetype) initWithAddressComment:(NSString*)commentPart userName:(NSString*) userPart domain:(NSString*)domainPart {
    self = [super init];
    if (self){
        self.addressComment =commentPart;
        self.userName = userPart;
        self.domain = domainPart;
    }
    return self;
}


+(NSArray*)emailAddressesFromHeaderValue:(NSString*)headerValue{
    NSScanner * scanner = [NSScanner scannerWithString:headerValue];
    NSString * displayName= nil;
    NSString * userName = nil;
    NSString * domain = nil;
    NSError * error = nil;
    NSMutableArray * emailAddresses = [NSMutableArray array];
    while (![scanner isAtEnd] && !error){
        if([scanner scanRFC2822EmailAddressIntoDisplayName:&displayName localName:&userName domain:&domain error:&error]){
            if (displayName||(userName && domain)){
                MKEmailAddress * address = [[MKEmailAddress alloc] initWithAddressComment:displayName userName:userName domain:domain];
                [emailAddresses addObject:address];
            }
        }
        else{
            NSLog(@"\n\t\t%@\n\t\t\t\tERROR: %@",headerValue,error);
            emailAddresses = nil;
            break;
        }
    }
    return emailAddresses;
    
    return nil;
    
    
}

#pragma mark NSCopying, Equality 

-(MKEmailAddress*)copyWithZone:(NSZone*)aZone{
    MKEmailAddress* theCopy = [[MKEmailAddress alloc] initWithAddressComment:self.addressComment userName:self.userName domain:self.domain];
    return theCopy;
}

-(BOOL) isEqualTo:(id)object{
    if ([object isKindOfClass:[MKEmailAddress class]]){
        return [self.commentedAddress isEqualToString:[(MKEmailAddress*)object commentedAddress]];
    }
    else {
        return NO;
    }
}
-(BOOL) isEqual:(id)object{
    if ([object isKindOfClass:[MKEmailAddress class]]){
        return [self.commentedAddress isEqualToString:[(MKEmailAddress*)object commentedAddress]];
    }
    else {
        return NO;
    }
}


-(NSUInteger) hash{
    if ([self.commentedAddress isEqualToString:@"Scott Morrison <smorr@indev.ca>"]){
        
    }
    return [self.commentedAddress hash];
}


#pragma mark -

-(NSString*)commentedAddress{
    if (self.addressComment){
        return [NSString stringWithFormat:@"%@ <%@@%@>",self.addressComment,self.userName, self.domain];
    }
    return [self userAtDomain];
}

-(NSString *)description{
    return [NSString stringWithFormat:@"<%@: %p> %@",[self class],self,[self commentedAddress]];
}

-(NSString*)userAtDomain{
    return [NSString stringWithFormat:@"%@@%@",self.userName, self.domain];
}

-(NSString*)displayName{
    NSString * address =self.addressComment;
    if (!address) address = self.userAtDomain;
    return address;
}
@end

