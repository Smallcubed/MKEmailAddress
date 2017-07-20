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


#pragma mark - Creation Tests

- (void)testBasicCreationFromParts {
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithAddressComment:@"John Doe" userName:@"john" domain:@"doe.me"];
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"John Doe <john@doe.me>", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"\"John Doe\" <john@doe.me>", @"Incorrect rfc2822 representation.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");
}

- (void)testBasicCreationFromRawEmail {
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithRawAddress:@"John Doe <john@doe.me>"];
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"John Doe <john@doe.me>", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"\"John Doe\" <john@doe.me>", @"Incorrect rfc2822 representation.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");
}

- (void)testBasicCreationFromRawEmailWithoutComment {
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithRawAddress:@"john@doe.me"];
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"john@doe.me", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"john@doe.me", @"Incorrect rfc2822 representation.");
	XCTAssertNil(newAddress.addressComment, @"Comment is not nil.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");
}

- (void)testClassMethodCreationFromRawEmail {
	MKEmailAddress * newAddress = [MKEmailAddress emailAddressWithRawAddress:@"John Doe <john@doe.me>"];
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"John Doe <john@doe.me>", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"\"John Doe\" <john@doe.me>", @"Incorrect rfc2822 representation.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");
}

- (void)testClassMethodCreationFromRawEmailWithoutComment {
	MKEmailAddress * newAddress = [MKEmailAddress emailAddressWithRawAddress:@"john@doe.me"];
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"john@doe.me", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"john@doe.me", @"Incorrect rfc2822 representation.");
	XCTAssertNil(newAddress.addressComment, @"Comment is not nil.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");
}

- (void)testMultiHeaderCreationFromRawEmail {
	NSArray <MKEmailAddress *> * newAddresses = [MKEmailAddress emailAddressesFromHeaderValue:@"John Doe <john@doe.me>"];
	XCTAssertEqual(newAddresses.count, 1, @"Did not get one emailAddress object.");
	MKEmailAddress * newAddress = newAddresses.firstObject;
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"John Doe <john@doe.me>", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"\"John Doe\" <john@doe.me>", @"Incorrect rfc2822 representation.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");
}

- (void)testMultiHeaderCreationFromRawEmailWithoutComment {
	NSArray <MKEmailAddress *> * newAddresses = [MKEmailAddress emailAddressesFromHeaderValue:@"john@doe.me"];
	XCTAssertEqual(newAddresses.count, 1, @"Did not get one emailAddress object.");
	MKEmailAddress * newAddress = newAddresses.firstObject;
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"john@doe.me", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"john@doe.me", @"Incorrect rfc2822 representation.");
	XCTAssertNil(newAddress.addressComment, @"Comment is not nil.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");
}



#pragma mark - Creationg Failure Tests

- (void)testFailureCreationFromInvalidParts {
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithAddressComment:@"John Doe" userName:@"john" domain:@"abc"];
	XCTAssertNotNil(newAddress, @"Created email address from illegal values.");
	XCTAssertFalse(newAddress.valid, @"Address should be marked as valid.");
	XCTAssertNotNil(newAddress.invalidRawAddress, @"The raw input is not nil.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @"John Doe <john@abc>", @"Not the expected invalid raw input.");
}

- (void)testBasicFailureCreatingFromRawEmail {
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithRawAddress:@"John Doe <john@abc>"];
	XCTAssertNotNil(newAddress, @"Created email address from illegal values.");
	XCTAssertFalse(newAddress.valid, @"Address should be marked as invalid.");
	XCTAssertNotNil(newAddress.invalidRawAddress, @"The raw input is nil.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @"John Doe <john@abc>", @"Not the expected invalid raw input.");
}

- (void)testBasicFailureCreatingFromRawEmailWithoutComment {
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithRawAddress:@"abc"];
	XCTAssertNotNil(newAddress, @"Created email address from illegal values.");
	XCTAssertFalse(newAddress.valid, @"Address should be marked as invalid.");
	XCTAssertNotNil(newAddress.invalidRawAddress, @"The raw input is nil.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @"abc <>", @"Not the expected invalid raw input.");
}

- (void)testBasicFailureClassMethodCreationFromRawEmail {
	MKEmailAddress * newAddress = [MKEmailAddress emailAddressWithRawAddress:@"John Doe <john@abc>"];
	XCTAssertNotNil(newAddress, @"Created email address from illegal values.");
	XCTAssertFalse(newAddress.valid, @"Address should be marked as invalid.");
	XCTAssertNotNil(newAddress.invalidRawAddress, @"The raw input is nil.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @"John Doe <john@abc>", @"Not the expected invalid raw input.");
}

- (void)testBasicFailureClassMethodCreationFromRawEmailWithoutComment {
	MKEmailAddress * newAddress = [MKEmailAddress emailAddressWithRawAddress:@"abc"];
	XCTAssertNotNil(newAddress, @"Created email address from illegal values.");
	XCTAssertFalse(newAddress.valid, @"Address should be marked as invalid.");
	XCTAssertNotNil(newAddress.invalidRawAddress, @"The raw input is nil.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @"abc <>", @"Not the expected invalid raw input.");
}

- (void)testBasicFailureMultiHeaderCreationFromRawEmail {
	NSArray <MKEmailAddress *> * newAddresses = [MKEmailAddress emailAddressesFromHeaderValue:@"John Doe <john@abc>"];
	XCTAssertEqual(newAddresses.count, 1, @"Did not get one emailAddress object.");
	MKEmailAddress * newAddress = newAddresses.firstObject;
	XCTAssertNotNil(newAddress, @"Created email address from illegal values.");
	XCTAssertFalse(newAddress.valid, @"Address should be marked as invalid.");
	XCTAssertNotNil(newAddress.invalidRawAddress, @"The raw input is nil.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @"John Doe <john@abc>", @"Not the expected invalid raw input.");
}

- (void)testBasicFailureMultiHeaderCreationFromRawEmailWithoutComment {
	NSArray <MKEmailAddress *> * newAddresses = [MKEmailAddress emailAddressesFromHeaderValue:@"abc"];
	XCTAssertEqual(newAddresses.count, 1, @"Did not get one emailAddress object.");
	MKEmailAddress * newAddress = newAddresses.firstObject;
	XCTAssertNotNil(newAddress, @"Created email address from illegal values.");
	XCTAssertFalse(newAddress.valid, @"Address should be marked as invalid.");
	XCTAssertNotNil(newAddress.invalidRawAddress, @"The raw input is nil.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @"abc <>", @"Not the expected invalid raw input.");
}


#pragma mark - Validation of Edge Case List Tests

- (void)testJSONListOfEdgeCases {
	
	NSString * testAddressPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"testAddresses" ofType:@"json"];
	NSData * data = [NSData dataWithContentsOfFile:testAddressPath];
	NSError * jsonError = nil;
	NSArray * tests = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
	XCTAssertNil(jsonError, @"There was an error reading json file: %@", jsonError);
	
	NSInteger caseCount = 0;
	for (NSDictionary * aTest in tests) {
		NSString * testString = aTest[@"header_row"];
		NSArray * testResults = aTest[@"result_list"];
		
		NSArray <MKEmailAddress *> * emailAddresses = [MKEmailAddress emailAddressesFromHeaderValue:testString];
		XCTAssertEqual(testResults.count, emailAddresses.count, @"Incorrect email addresses created.");
		
		[testResults enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull testResult, NSUInteger idx, BOOL * _Nonnull stop) {
			NSString * resultDisplayName = testResult[@"display_name"];
			NSString * resultAddress = testResult[@"address"];
			MKEmailAddress * emailAddress = emailAddresses[idx];
			XCTAssertEqualObjects(resultDisplayName, emailAddress.displayName, @"Incorrect displayName for address.");
			XCTAssertEqualObjects(resultAddress, emailAddress.userAtDomain, @"Incorrect email address found.");
		}];
		caseCount++;
	}
	NSLog(@"Ran %@ edge cases!!", @(caseCount));
}

 
#pragma mark - Configuration

- (void)setUp {
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

@end
