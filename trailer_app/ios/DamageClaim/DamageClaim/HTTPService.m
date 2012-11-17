//
//  HttpService.m
//  DamageClaim
//
//  Created by GS LAB on 21/05/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.
//

#import "HTTPService.h"
#import "Const.h"
@implementation HTTPService

@synthesize receivedData,connection ;
@synthesize delegate,serviceURLString,headersDictionary,bodyString,isPOST,serviceRequestMethod, bodyData, request, identifier;
 
- (id)init
{
    return [self initWithURLString:nil headers:nil body:nil delegate:nil requestMethod:kRequestMethodNone];
}

- (id)initWithURLString : (NSString *)urlString headers : (NSDictionary *)headers body : (NSString *)body 
               delegate : (NSObject<HTTPServiceDelegate> *)serviceDelegate requestMethod : (RequestMethod)requestMethod {
    if (self=[super init]) {
        serviceURLString = urlString ;[serviceURLString retain] ;
        headersDictionary=[headers mutableCopy] ;//[headersDictionary retain] ;
        bodyString = body ;[bodyString retain];
        delegate=serviceDelegate; [delegate retain];
        serviceRequestMethod = requestMethod;
        identifier = @"";
    }
    return self ;
}

- (id)initWithURLString : (NSString *)urlString headers : (NSDictionary *)headers body : (NSString *)body 
               delegate : (NSObject<HTTPServiceDelegate> *)serviceDelegate requestMethod : (RequestMethod)requestMethod identifier:(NSString *)iden{
    if (self=[super init]) {
        serviceURLString = urlString ;[serviceURLString retain] ;
        headersDictionary = [headers mutableCopy] ;//[headersDictionary retain] ;
        bodyString = body; [bodyString retain];
        delegate=serviceDelegate; [serviceDelegate retain];
        serviceRequestMethod = requestMethod;
        identifier = iden; [identifier retain];
    }
    return self ;
}


- (void)startService { //setup the post request header and body and start connection
    NSURL *url = [NSURL URLWithString:self.serviceURLString];
    self.request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:TIMEOUT_INTERVAL];
    
    if (self.serviceRequestMethod == kRequestMethodPOST) { //set up request type 
       [self.request setHTTPMethod:@"POST"];
    } else if (self.serviceRequestMethod == kRequestMethodGET) {
        [self.request setHTTPMethod:@"GET"];
    } else if (self.serviceRequestMethod == kRequestMethodPUT) {
        [self.request setHTTPMethod:@"PUT"];
    } else {
        [self.request setHTTPMethod:@"DELETE"];
    }
    
    if (self.headersDictionary!=nil) { //setup headers
        NSArray *headerKeys = [self.headersDictionary allKeys];
        
        for (NSString *headerKey in headerKeys) {
            [self.request setValue:[self.headersDictionary objectForKey:headerKey] forHTTPHeaderField:headerKey];
        }
    }
    
    

    //bodyData isn't null which means it was set by user
    //use it instead of bodyString
    if (self.bodyData) {
        [self.request setHTTPBody:self.bodyData];
    } else if (self.bodyString){
        [self.request setHTTPBody:[NSData dataWithBytes:[self.bodyString UTF8String] length:[self.bodyString length]]];
    }
    
    
    self.connection = [[[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES] autorelease];

    if (!self.connection) {
        [self.delegate serviceDidFailWithError:nil forIdentifier:self.identifier];
    }
}

#pragma mark - NSURLConnection delegate methods

// Only accept self-signed certificates when debugging, and never present the user with a questioin about certificates

#if kDebug

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

#endif

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.receivedData==nil) {
        self.receivedData = [[[NSMutableData alloc] init] autorelease];
    }
    [self.receivedData appendData:data];
    
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
#if kDebug
    NSLog(@"%@", self.delegate);
#endif
    if (self.delegate != nil) {
        [self.delegate didReceiveResponse:self.receivedData forIdentifier:self.identifier];
    }
    if (self.delegate != nil) {
        [self.delegate storeResponse:self.receivedData forIdentifier:self.identifier];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
#if kDebug
    NSLog(@"%@", self.delegate);
#endif
#if kDebug
    NSLog(@"ERROR: %@", [error description]);
#endif
    if (self.delegate != nil) {
        [self.delegate serviceDidFailWithError:error forIdentifier:self.identifier];
    }
}

- (void)cancelHTTPService {
    [self.connection cancel];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
#if kDebug
    NSLog(@"%@", self.delegate);
#endif
    if (self.delegate != nil) {
        [self.delegate responseCode:code];
    }
    
}


#pragma mark -
- (void)dealloc {
    [receivedData release];
    [delegate release];
    [connection release];
    [serviceURLString release];
    [headersDictionary release];
    [bodyString release];
    [bodyData release];
    [request release];
    [super dealloc]; 
}


@end

