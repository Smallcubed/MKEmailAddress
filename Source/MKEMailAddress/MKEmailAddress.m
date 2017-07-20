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
#import "NSString+MimeEncoding.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSData(MKE_MKEmailAddress)
- (NSString *)MKEpathSafeBase64EncodedString {
    
    if ([self respondsToSelector:@selector(base64EncodedStringWithOptions:)]){
        NSString    *cleaned = [[self base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        cleaned = [cleaned stringByReplacingOccurrencesOfString:@"+" withString:@"_"];
        return cleaned;
    }
    else{
        const char* input =  [self bytes];
        NSInteger length = [self length];
        
        static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_=";
        
        NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
        uint8_t* output = (uint8_t*)data.mutableBytes;
        
        NSInteger i;
        for (i=0; i < length; i += 3) {
            NSInteger value = 0;
            NSInteger j;
            for (j = i; j < (i + 3); j++) {
                value <<= 8;
                if (j < length) {
                    value |= (0xFF & input[j]);
                }
            }
            
            NSInteger theIndex = (i / 3) * 4;
            output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
            output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
            output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
            output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
        }
        return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] ;
    }
}
@end

@implementation NSString(MKE_MKEmailAddress)
-(NSString*)MKEshortSHAHashString{
#define ID_SIZE 12
    // Size 12 = 72 bits = number of inputs to have a 50% chance of collision: 8.09*10^10 (80.9 billion)
    // number of input will be much greater once there are constraints to the inputs.
    
    const char *s=[self cStringUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(s, (CC_LONG)strlen(s), digest);
    
    NSData * digestData = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    
    NSString * generatedID =[[digestData MKEpathSafeBase64EncodedString] substringToIndex:ID_SIZE];
    return generatedID;
}

@end


@implementation MKEmailAddress


- (instancetype)initWithInvalidHeaderString:(NSString*)headerString {
    self =[self init];
    if (self){
        self.invalidHeaderString = headerString;
    }
    return self;
}

- (instancetype)initWithAddressComment:(NSString*)commentPart userName:(NSString*) userPart domain:(NSString*)domainPart {
    self = [self init];
    if (self){
        self.addressComment =commentPart;
        self.userName = userPart;
        self.domain = domainPart;
    }
    return self;
}

- (instancetype)initWithCommentedAddress:(NSString*)commentedAddress {
    self = [self init];
    if (commentedAddress) {
        NSScanner * scanner = [NSScanner scannerWithString:commentedAddress];
        NSString * displayName= nil;
        NSString * userName = nil;
        NSString * domain = nil;
        NSError * error = nil;
        [scanner scanRFC2822EmailAddressIntoDisplayName:&displayName localName:&userName domain:&domain error:&error];
        self.addressComment = displayName;
        self.userName = userName;
        self.domain = domain;
    }
    return self;
}

+ (MKEmailAddress *)addressWithComment:(NSString*)commentPart userName:(NSString*) userPart domain:(NSString*)domainPart {
	return [[[self class] alloc] initWithAddressComment:commentPart
											   userName:userPart
												 domain:domainPart];
}

+ (MKEmailAddress *)addressWithABPerson:(ABPerson *)person forIdentifier:(NSString *)identifier {
	if ((person == nil) || (identifier == nil)) {
		return nil;
	}
	ABMultiValue * addressValues = [person valueForProperty:kABEmailProperty];
	NSString * addressString = [addressValues valueForIdentifier:identifier];
	NSScanner * scanner = [NSScanner scannerWithString:addressString];
	NSString * displayName = nil;
	NSString * userName = nil;
	NSString * domain = nil;
	NSError * error = nil;
	[scanner scanRFC2822EmailAddressIntoDisplayName:&displayName localName:&userName domain:&domain error:&error];
	if (error == nil) {
		displayName = [NSString stringWithFormat:@"%@ %@", [person valueForProperty:kABFirstNameProperty], [person valueForProperty:kABLastNameProperty]];
		return [[self class] addressWithComment:displayName userName:userName domain:domain];
	}
	return nil;
}

+ (NSString*)rfc2822RepresentationForAddresses:(MKEmailAddressArray *)addresses {
    NSMutableArray * rfc2822Reps = [NSMutableArray array];
    for (MKEmailAddress* anAddr in addresses){
        NSString * rfcRep = [anAddr rfc2822Representation];
        if (rfcRep){
            [rfc2822Reps addObject:rfcRep];
        }
    }
    if ([rfc2822Reps count]){
        return [rfc2822Reps componentsJoinedByString:@","];
    }
    return nil;
}

+ (NSArray*)emailAddressesFromHeaderValue:(NSString*)headerValue {
    if (!headerValue) return nil;
    NSMutableArray * emailAddresses = [NSMutableArray array];
    @autoreleasepool {
        NSScanner * scanner = [NSScanner scannerWithString:headerValue];
         NSError * error = nil;
         while (![scanner isAtEnd] && !error){
            NSString * displayName= nil;
            NSString * userName = nil;
            NSString * domain = nil;
            NSString * invalidPart = nil;
            error = nil;
            if([scanner scanRFC2822EmailAddressIntoDisplayName:&displayName localName:&userName domain:&domain invalid:&invalidPart error:&error]){
                if (displayName||(userName && domain)){
                    NSString * decodedDisplayName = [displayName decodedMimeEncodedString];
                    MKEmailAddress * address = [[MKEmailAddress alloc] initWithAddressComment:decodedDisplayName userName:userName domain:domain];
                    [emailAddresses addObject:address];
                }
                else if (invalidPart){
                    MKEmailAddress * address = [[MKEmailAddress alloc] initWithInvalidHeaderString:invalidPart];
                    [emailAddresses addObject:address];
                }
            }
            else{
               
                NSLog(@"\n\t\t%@\n\t\t\t\tERROR: %@",headerValue,error);
                emailAddresses = nil;
                break;
            }
        }
    }
    return emailAddresses;    
}

- (NSString*)digest {
    NSString * stringToHash = [self rfc2822Representation];
    if (!stringToHash){
        stringToHash = self.commentedAddress;
    }
    if (!stringToHash){
        stringToHash = self.invalidHeaderString;
    }
    return [stringToHash MKEshortSHAHashString];
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
    return [self.commentedAddress hash];
}


#pragma mark -
-(NSString*)rfc2822Representation{
    if (self.addressComment){
        NSString * escapedQuotedComment = [self.addressComment stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        
        if (self.userAtDomain){
            if ([self.addressComment canBeConvertedToEncoding:NSASCIIStringEncoding]){
                return [NSString stringWithFormat:@"\"%@\" <%@>",escapedQuotedComment,self.userAtDomain];
            }
            else{
                NSString * encodedComment = [NSString mimeWordWithString:self.addressComment preferredEncoding:NSISOLatin1StringEncoding encodingUsed:nil];
                return [NSString stringWithFormat:@"\"%@\" <%@>",encodedComment,self.userAtDomain];
            }
        }
        else{
            // technically this is not RFC2822 compliant as there is no user@domain portion
            if ([self.addressComment canBeConvertedToEncoding:NSASCIIStringEncoding]){
                return [NSString stringWithFormat:@"\"%@\"",escapedQuotedComment];
            }
            else{
                NSString * encodedComment = [NSString mimeWordWithString:self.addressComment preferredEncoding:NSISOLatin1StringEncoding encodingUsed:nil];
                return [NSString stringWithFormat:@"\"%@\"",encodedComment];
            }
        }
    }
    else{
        return self.userAtDomain;
    }
}

-(NSString*)commentedAddress{
    if (self.addressComment){
        if (self.userAtDomain){
            return [NSString stringWithFormat:@"%@ <%@>",self.addressComment,self.userAtDomain];
        }
    }
    else if(self.userAtDomain){
        return self.userAtDomain;
    }
       return nil;
}

-(NSString *)description{
    NSString * commentedAddress = self.commentedAddress;
    if (commentedAddress){
        return [NSString stringWithFormat:@"<%@: %p> %@",[self class],self,commentedAddress];
    }
    else{
        return [NSString stringWithFormat:@"<%@: %p> (INVALID) %@",[self class],self,self.invalidHeaderString];

    }
}

-(NSString*)userAtDomain{
    if (self.userName && self.domain){
        return [NSString stringWithFormat:@"%@@%@",self.userName, self.domain];
    }
    return nil;
}

-(NSString*)displayName{
    return [self.addressComment decodedMimeEncodedString]?:self.userAtDomain;
}
-(BOOL)isValid{
    return YES;
}
@end

