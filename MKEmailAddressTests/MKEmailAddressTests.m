//
//  MKEmailAddressTests.m
//  MKEmailAddressTests
//
//  Created by smorr on 2015-08-05.
//  Copyright © 2015 indev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MKEmailAddress.h"
#import "NSString+MimeEncoding.h"
#import "NSData+MimeWordDecoding.h"

@interface MKEmailAddressTests : XCTestCase

@end

@implementation MKEmailAddressTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    NSString * testAddressPath = [[NSBundle  bundleForClass:[self class]] pathForResource:@"testAddresses" ofType:@"txt"];
    NSString * testAddresses  =  [NSString stringWithContentsOfFile:testAddressPath encoding:NSUTF8StringEncoding error:nil];
    [testAddresses enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        NSArray <MKEmailAddress *> * emailAddresses = [MKEmailAddress emailAddressesFromHeaderValue:line];
        for (MKEmailAddress* anAddress in emailAddresses){
            NSLog (@"%@ rfc2822: %@",anAddress, [anAddress rfc2822Representation]);
        }
     }];
 
    
}

- (void)testJson {
    
    NSString * testAddressPath = [[NSBundle  bundleForClass:[self class]] pathForResource:@"testAddresses" ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:testAddressPath];
    
    NSError *jsonError = nil;
    
    id tests = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    
    for (NSArray *row in tests) {
        NSString *testString = row[0];
        NSArray *testResults = row[1];
        
        
        NSArray <MKEmailAddress *> * emailAddresses = [MKEmailAddress emailAddressesFromHeaderValue:testString];
        
        if ([testResults count] != [emailAddresses count])
        {
            NSLog(@"Wrong count");
            continue;
        }
        
        for (NSInteger addressesIndex = 0; addressesIndex < [testResults count]; addressesIndex++)
        {
            NSArray *testResult = testResults[addressesIndex];
            NSString *resultDisplayName = testResult[0];
            NSString *resultAddress = testResult[1];
            
            MKEmailAddress *emailAddress = emailAddresses[addressesIndex];
            
            if (![resultDisplayName isEqual:[emailAddress displayName]])
            {
                NSLog(@"Wrong displayName %@ vs %@", resultDisplayName, [emailAddress displayName]);
            }
            
            if (![resultAddress isEqual:[emailAddress userAtDomain]])
            {
                NSLog(@"Wrong address %@ vs %@", resultAddress, [emailAddress userAtDomain]);
            }
        }
    }
    
    NSLog(@"jsonError %@", jsonError);
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
