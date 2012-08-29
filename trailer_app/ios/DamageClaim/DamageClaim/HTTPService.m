//
//  HttpService.m
//  Plunk
//
//  Created by GS LAB on 21/05/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.
//

#import "HTTPService.h"
#import "Const.h"

@implementation HTTPService

@synthesize receivedData,connection ;
@synthesize delegate,serviceURLString,headersDictionary,bodyString,isPOST,serviceRequestMethod, bodyData, request;
 
- (id)init
{
    return [self initWithURLString:nil headers:nil body:nil delegate:nil requestMethod:kRequestMethodNone];
}

- (id)initWithURLString : (NSString *)urlString headers : (NSDictionary *)headers body : (NSString *)body 
               delegate : (id<HTTPServiceDelegate>)serviceDelegate requestMethod : (RequestMethod)requestMethod {
    if (self=[super init]) {
        serviceURLString = urlString ;[serviceURLString retain] ;
        headersDictionary=[headers mutableCopy] ;//[headersDictionary retain] ;
        bodyString = body ;[bodyString retain];
        delegate=serviceDelegate ;
        serviceRequestMethod = requestMethod;
    }
    return self ;
}


- (void)startService { //setup the post request header and body and start connection
    NSURL *url = [NSURL URLWithString:self.serviceURLString];
    self.request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:TIMEOUT_INTERVAL];
    
    if (self.serviceRequestMethod == kRequestMethodPOST) { //set up request type 
       [self.request setHTTPMethod:@"POST"];
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
        [self.delegate serviceDidFailWithError:nil forURLString:self.serviceURLString];
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
    
    [self.delegate didReceiveResponse:self.receivedData forURLString:self.serviceURLString];
    if ([(UIViewController *)self.delegate respondsToSelector:@selector(storeResponse:forCallType:)]) {
        [self.delegate storeResponse:self.receivedData forURLString:self.serviceURLString];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
#if kDebug
    NSLog(@"ERROR: %@", [error description]);
#endif
    [self.delegate serviceDidFailWithError:error forURLString:self.serviceURLString];
}

- (void)cancelHTTPService {
    [self.connection cancel];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    [self.delegate responseCode:code];
    
}
#pragma mark - 


- (void)dealloc {
    [receivedData release];
    delegate = nil;
    [connection release];
    [serviceURLString release];
    [headersDictionary release];
    [bodyString release];
    [bodyData release];
    [request release];
    [super dealloc]; 
}


@end
