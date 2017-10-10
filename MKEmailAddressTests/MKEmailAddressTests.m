//
//  MKEmailAddressTests.m
//  MKEmailAddressTests
//
//  Created by smorr on 2015-08-05.
//  Copyright © 2015 indev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "MKEmailAddress.h"
#import "NSString+MimeEncoding.h"
#import "NSData+MimeWordDecoding.h"

#define TEST_PERSON_UUID @"TEST_PERSON_IDENTIFIER"


@interface FakePerson:NSObject
- (id)valueForProperty:(NSString *)property;
- (NSString *)uniqueId;
@end

@interface MKEmailAddressTests : XCTestCase
@property (strong) id mockPerson;
@property (strong) id mockMultiValue;
@property (strong) id mockAddressBook;
@end

@implementation MKEmailAddressTests


#pragma mark - Creation Tests

- (void)testBasicCreationFromParts {
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithAddressComment:@"John Doe" userName:@"john" domain:@"doe.me"];
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"John Doe <john@doe.me>", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.invertedDisplayAddress, @"john@doe.me (John Doe)", @"Incorrect inverted display address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"\"John Doe\" <john@doe.me>", @"Incorrect rfc2822 representation.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");
}

- (void)testBasicCreationFromRawEmail {
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithRawAddress:@"John Doe <john@doe.me>"];
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"John Doe <john@doe.me>", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.invertedDisplayAddress, @"john@doe.me (John Doe)", @"Incorrect inverted display address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"\"John Doe\" <john@doe.me>", @"Incorrect rfc2822 representation.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");
}

- (void)testBasicCreationFromRawEmailWithoutComment {
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithRawAddress:@"john@doe.me"];
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"john@doe.me", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.invertedDisplayAddress, @"john@doe.me", @"Incorrect inverted display address.");
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
	XCTAssertEqualObjects(newAddress.invertedDisplayAddress, @"john@doe.me (John Doe)", @"Incorrect inverted display address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"\"John Doe\" <john@doe.me>", @"Incorrect rfc2822 representation.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");
}

- (void)testClassMethodCreationFromRawEmailWithoutComment {
	MKEmailAddress * newAddress = [MKEmailAddress emailAddressWithRawAddress:@"john@doe.me"];
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"john@doe.me", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.invertedDisplayAddress, @"john@doe.me", @"Incorrect inverted display address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"john@doe.me", @"Incorrect rfc2822 representation.");
	XCTAssertNil(newAddress.addressComment, @"Comment is not nil.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");
}

- (void)testBasicCreationFromEmailAddressWithoutComment {
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithAddressComment:@"" emailAddress:@"john@doe.me"];
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"john@doe.me", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.invertedDisplayAddress, @"john@doe.me", @"Incorrect inverted display address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"john@doe.me", @"Incorrect rfc2822 representation.");
	XCTAssertEqualObjects(newAddress.addressComment, @"", @"Comment is not empty.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");
}

- (void)testBasicCreationFromEmailAddressWithoutNilComment {
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithAddressComment:nil emailAddress:@"john@doe.me"];
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"john@doe.me", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.invertedDisplayAddress, @"john@doe.me", @"Incorrect inverted display address.");
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
	XCTAssertEqualObjects(newAddress.invertedDisplayAddress, @"john@doe.me (John Doe)", @"Incorrect inverted display address.");
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
	XCTAssertEqualObjects(newAddress.invertedDisplayAddress, @"john@doe.me", @"Incorrect inverted display address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"john@doe.me", @"Incorrect rfc2822 representation.");
	XCTAssertNil(newAddress.addressComment, @"Comment is not nil.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");
}

- (void)testMultiHeaderCreationWithThreeAddresses {
	NSArray <MKEmailAddress *> * newAddresses = [MKEmailAddress emailAddressesFromHeaderValue:@"john@doe.me, Jane Smith <jsmith@smallcubed.com>, \"No Name\" <no-name@smallcubed.com>"];
	XCTAssertEqual(newAddresses.count, 3, @"Did not get three emailAddress object.");
	MKEmailAddress * newAddress = newAddresses.firstObject;
	XCTAssertNotNil(newAddress, @"First email address object is nil.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"john@doe.me", @"Incorrectly formatted address.");
	newAddress = newAddresses[1];
	XCTAssertNotNil(newAddress, @"Second email address object is nil.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"Jane Smith <jsmith@smallcubed.com>", @"Incorrectly formatted address.");
	newAddress = newAddresses[2];
	XCTAssertNotNil(newAddress, @"Third email address object is nil.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"No Name <no-name@smallcubed.com>", @"Incorrectly formatted address.");
}

- (void)testMultiHeaderCreationWithThreeAddressesOneInvalid {
	NSArray <MKEmailAddress *> * newAddresses = [MKEmailAddress emailAddressesFromHeaderValue:@"john@doe.me, Jane Smith <jsmith@smallcubed.com>, invalid@smallcu"];
	XCTAssertEqual(newAddresses.count, 3, @"Did not get three emailAddress object.");
	MKEmailAddress * newAddress = newAddresses.firstObject;
	XCTAssertNotNil(newAddress, @"First email address object is nil.");
	XCTAssertTrue(newAddress.valid, @"The first email should be valid.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"john@doe.me", @"Incorrectly formatted address.");
	newAddress = newAddresses[1];
	XCTAssertNotNil(newAddress, @"Second email address object is nil.");
	XCTAssertTrue(newAddress.valid, @"The second email should be valid.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"Jane Smith <jsmith@smallcubed.com>", @"Incorrectly formatted address.");
	newAddress = newAddresses[2];
	XCTAssertNotNil(newAddress, @"Third email address object is nil.");
	XCTAssertFalse(newAddress.valid, @"The third email should be invalid.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @" <invalid@smallcu>", @"Incorrect invalidRawAddress.");
	XCTAssertNil(newAddress.userName, @"UserName is not nil.");
	XCTAssertNil(newAddress.addressComment, @"AddressComment is not nil.");
	XCTAssertNil(newAddress.domain, @"Domain is not nil.");
}

- (void)testCreateWithRawAddressLinkAddressBook {
	[self setupPersonMockWithDict:@{@"first": @"John", @"last": @"Doe", @"email": @"john@doe.me"}];
	[self setupAddressBookWithPerson];
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithRawAddress:@"John Doeme <john@doe.me>"];
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"John Doeme <john@doe.me>", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.invertedDisplayAddress, @"john@doe.me (John Doeme)", @"Incorrect inverted display address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"\"John Doeme\" <john@doe.me>", @"Incorrect rfc2822 representation.");

	//	After getting the address book person the other data should use that
	XCTAssertNotNil(newAddress.addressBookPerson, @"The AddressBookPerson is nil.");
	XCTAssertEqualObjects(newAddress.addressBookPerson.uniqueId, TEST_PERSON_UUID, @"Unique Person id is incorrect.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"John Doe <john@doe.me>", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.invertedDisplayAddress, @"john@doe.me (John Doe)", @"Incorrect inverted display address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"\"John Doe\" <john@doe.me>", @"Incorrect rfc2822 representation.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");

}

- (void)testCreationWithABPerson {
	NSString * primaryIdentifier = [self setupPersonMockWithDict:@{@"first": @"John", @"last": @"Doe", @"email": @"john@doe.me"}];
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithABPerson:self.mockPerson forIdentifier:primaryIdentifier];
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"John Doe <john@doe.me>", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.invertedDisplayAddress, @"john@doe.me (John Doe)", @"Incorrect inverted display address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"\"John Doe\" <john@doe.me>", @"Incorrect rfc2822 representation.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");
}

- (void)testCreationWithABPersonEmptyIdentifer {
	[self setupPersonMockWithDict:@{@"first": @"John", @"last": @"Doe", @"email": @"john@doe.me"}];
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithABPerson:self.mockPerson forIdentifier:@""];
	XCTAssertNotNil(newAddress, @"Could not create email address object.");
	XCTAssertEqualObjects(newAddress.userAtDomain, @"john@doe.me", @"Incorrect email address.");
	XCTAssertEqualObjects(newAddress.displayAddress, @"John Doe <john@doe.me>", @"Incorrect formatted address.");
	XCTAssertEqualObjects(newAddress.invertedDisplayAddress, @"john@doe.me (John Doe)", @"Incorrect inverted display address.");
	XCTAssertEqualObjects(newAddress.rfc2822Representation, @"\"John Doe\" <john@doe.me>", @"Incorrect rfc2822 representation.");
	XCTAssertTrue(newAddress.valid, @"Address is marked as invalid.");
	XCTAssertNil(newAddress.invalidRawAddress, @"The raw input should be nil.");
}


#pragma mark - Creation Failure Tests

- (void)testFailureCreationFromInvalidParts {
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithAddressComment:@"John Doe" userName:@"john" domain:@"abc"];
	XCTAssertNotNil(newAddress, @"Created email address from illegal values.");
	XCTAssertFalse(newAddress.valid, @"Address should be marked as valid.");
	XCTAssertNotNil(newAddress.invalidRawAddress, @"The raw input is not nil.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @"John Doe <john@abc>", @"Not the expected invalid raw input.");
	XCTAssertNil(newAddress.userName, @"UserName is not nil.");
	XCTAssertNil(newAddress.addressComment, @"AddressComment is not nil.");
	XCTAssertNil(newAddress.domain, @"Domain is not nil.");
}

- (void)testBasicFailureCreatingFromRawEmail {
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithRawAddress:@"John Doe <john@abc>"];
	XCTAssertNotNil(newAddress, @"Created email address from illegal values.");
	XCTAssertFalse(newAddress.valid, @"Address should be marked as invalid.");
	XCTAssertNotNil(newAddress.invalidRawAddress, @"The raw input is nil.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @"John Doe <john@abc>", @"Not the expected invalid raw input.");
	XCTAssertNil(newAddress.userName, @"UserName is not nil.");
	XCTAssertNil(newAddress.addressComment, @"AddressComment is not nil.");
	XCTAssertNil(newAddress.domain, @"Domain is not nil.");
}

- (void)testBasicFailureCreatingFromRawEmailWithoutComment {
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithRawAddress:@"abc"];
	XCTAssertNotNil(newAddress, @"Created email address from illegal values.");
	XCTAssertFalse(newAddress.valid, @"Address should be marked as invalid.");
	XCTAssertNotNil(newAddress.invalidRawAddress, @"The raw input is nil.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @"abc <>", @"Not the expected invalid raw input.");
	XCTAssertNil(newAddress.userName, @"UserName is not nil.");
	XCTAssertNil(newAddress.addressComment, @"AddressComment is not nil.");
	XCTAssertNil(newAddress.domain, @"Domain is not nil.");
}

- (void)testBasicFailureClassMethodCreationFromRawEmail {
	MKEmailAddress * newAddress = [MKEmailAddress emailAddressWithRawAddress:@"John Doe <john@abc>"];
	XCTAssertNotNil(newAddress, @"Created email address from illegal values.");
	XCTAssertFalse(newAddress.valid, @"Address should be marked as invalid.");
	XCTAssertNotNil(newAddress.invalidRawAddress, @"The raw input is nil.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @"John Doe <john@abc>", @"Not the expected invalid raw input.");
	XCTAssertNil(newAddress.userName, @"UserName is not nil.");
	XCTAssertNil(newAddress.addressComment, @"AddressComment is not nil.");
	XCTAssertNil(newAddress.domain, @"Domain is not nil.");
}

- (void)testBasicFailureClassMethodCreationFromRawEmailWithoutComment {
	MKEmailAddress * newAddress = [MKEmailAddress emailAddressWithRawAddress:@"abc"];
	XCTAssertNotNil(newAddress, @"Created email address from illegal values.");
	XCTAssertFalse(newAddress.valid, @"Address should be marked as invalid.");
	XCTAssertNotNil(newAddress.invalidRawAddress, @"The raw input is nil.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @"abc <>", @"Not the expected invalid raw input.");
	XCTAssertNil(newAddress.userName, @"UserName is not nil.");
	XCTAssertNil(newAddress.addressComment, @"AddressComment is not nil.");
	XCTAssertNil(newAddress.domain, @"Domain is not nil.");
}

- (void)testBasicFailureMultiHeaderCreationFromRawEmail {
	NSArray <MKEmailAddress *> * newAddresses = [MKEmailAddress emailAddressesFromHeaderValue:@"John Doe <john@abc>"];
	XCTAssertEqual(newAddresses.count, 1, @"Did not get one emailAddress object.");
	MKEmailAddress * newAddress = newAddresses.firstObject;
	XCTAssertNotNil(newAddress, @"Created email address from illegal values.");
	XCTAssertFalse(newAddress.valid, @"Address should be marked as invalid.");
	XCTAssertNotNil(newAddress.invalidRawAddress, @"The raw input is nil.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @"John Doe <john@abc>", @"Not the expected invalid raw input.");
	XCTAssertNil(newAddress.userName, @"UserName is not nil.");
	XCTAssertNil(newAddress.addressComment, @"AddressComment is not nil.");
	XCTAssertNil(newAddress.domain, @"Domain is not nil.");
}

- (void)testBasicFailureMultiHeaderCreationFromRawEmailWithoutComment {
	NSArray <MKEmailAddress *> * newAddresses = [MKEmailAddress emailAddressesFromHeaderValue:@"abc"];
	XCTAssertEqual(newAddresses.count, 1, @"Did not get one emailAddress object.");
	MKEmailAddress * newAddress = newAddresses.firstObject;
	XCTAssertNotNil(newAddress, @"Created email address from illegal values.");
	XCTAssertFalse(newAddress.valid, @"Address should be marked as invalid.");
	XCTAssertNotNil(newAddress.invalidRawAddress, @"The raw input is nil.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @"abc <>", @"Not the expected invalid raw input.");
	XCTAssertNil(newAddress.userName, @"UserName is not nil.");
	XCTAssertNil(newAddress.addressComment, @"AddressComment is not nil.");
	XCTAssertNil(newAddress.domain, @"Domain is not nil.");
}

- (void)testCreationWithABPersonInvalidEmail {
	NSString * primaryIdentifier = [self setupPersonMockWithDict:@{@"first": @"John", @"last": @"Doe", @"email": @"abc"}];
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithABPerson:self.mockPerson forIdentifier:primaryIdentifier];
	XCTAssertNotNil(newAddress, @"Created email address from illegal values.");
	XCTAssertFalse(newAddress.valid, @"Address should be marked as invalid.");
	XCTAssertNotNil(newAddress.invalidRawAddress, @"The raw input is nil.");
	XCTAssertEqualObjects(newAddress.invalidRawAddress, @"John Doe <@abc>", @"Not the expected invalid raw input.");
	XCTAssertNil(newAddress.userName, @"UserName is not nil.");
	XCTAssertNil(newAddress.addressComment, @"AddressComment is not nil.");
	XCTAssertNil(newAddress.domain, @"Domain is not nil.");
}

- (void)testCreationWithABPersonWithoutEmail {
	[self setupPersonMockWithDict:@{@"first": @"John", @"last": @"Doe"}];
	MKEmailAddress * newAddress = [[MKEmailAddress alloc] initWithABPerson:self.mockPerson forIdentifier:@""];
	XCTAssertNil(newAddress, @"Created email address from Empty Person record.");
}


#pragma mark Representation Testing

- (void)testRepresentationsForEmailAddressObjects {
	NSArray <MKEmailAddress *> * newAddresses = [MKEmailAddress emailAddressesFromHeaderValue:@"John Doe <john@doe.me>, Jane Smith <jsmith@smallcubed.com>, an-email@smallcubed.com"];
	XCTAssertEqual(newAddresses.count, 3, @"Did not get three emailAddress object.");
	NSString * rfcRep = [MKEmailAddress rfc2822RepresentationForAddresses:newAddresses];
	XCTAssertEqualObjects(@"\"John Doe\" <john@doe.me>,\"Jane Smith\" <jsmith@smallcubed.com>,an-email@smallcubed.com", rfcRep, @"RFC String is incorrect.");
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

- (NSString *)setupPersonMockWithDict:(NSDictionary *)dict {
	//	Mocking Setup
	ABPerson * personObject = (ABPerson *)[FakePerson new];
	ABMutableMultiValue * multiValue = [ABMutableMultiValue new];
	self.mockPerson = OCMPartialMock(personObject);
	self.mockMultiValue = multiValue;
	OCMStub([self.mockPerson uniqueId]).andReturn(TEST_PERSON_UUID);
	OCMStub([self.mockPerson valueForProperty:kABEmailProperty]).andReturn(self.mockMultiValue);
	OCMStub([self.mockPerson valueForProperty:kABFirstNameProperty]).andReturn(dict[@"first"]);
	OCMStub([self.mockPerson valueForProperty:kABLastNameProperty]).andReturn(dict[@"last"]);
	NSString * primaryIdentifier = @"";
	if (dict[@"email"]) {
		[multiValue insertValue:dict[@"email"] withLabel:@"TEST_LABEL" atIndex:0];
		primaryIdentifier = [multiValue identifierAtIndex:0];
		[multiValue setPrimaryIdentifier:primaryIdentifier];
	}
	return primaryIdentifier;
}

- (void)setupAddressBookWithPerson {
	//	Mocking Setup
	ABAddressBook * book = [ABAddressBook sharedAddressBook];
	self.mockAddressBook = OCMPartialMock(book);
	OCMStub([self.mockAddressBook recordForUniqueId:TEST_PERSON_UUID]).andReturn(self.mockPerson);
	OCMStub([self.mockAddressBook recordsMatchingSearchElement:[OCMArg any]]).andReturn(@[self.mockPerson]);
}

@end


#pragma mark - FakeMockObjects!

@implementation FakePerson
- (id)valueForProperty:(NSString *)property { return nil; }
- (NSString *)uniqueId { return nil; }
@end



