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
@synthesize delegate,serviceURLString,headersDictionary,bodyString,isPOST,serviceRequestMethod, callType, bodyData;
 
- (id)init
{
    return [self initWithURLString:nil headers:nil body:nil delegate:nil requestMethod:kRequestMethodNone];
}

- (id)initWithURLString : (NSString *)urlString headers : (NSDictionary *)headers body : (NSString *)body 
               delegate : (id<HTTPServiceDelegate>)serviceDelegate requestMethod : (RequestMethod)requestMethod {
    if (self=[super init]) {
        serviceURLString =urlString ;[serviceURLString retain] ;
        headersDictionary=[headers mutableCopy] ;//[headersDictionary retain] ;
        bodyString = body ;[bodyString retain];
        delegate=serviceDelegate ;
        serviceRequestMethod =requestMethod ;
    }
    return self ;
}

- (id)initWithURLString : (NSString *)urlString callType:(DC_URL_CALL_TYPE)serviceCallType headers : (NSDictionary *)headers body : (NSString *)body 
               delegate : (id<HTTPServiceDelegate>)serviceDelegate requestMethod : (RequestMethod)requestMethod {
    if (self=[super init]) {
        callType = serviceCallType;
        serviceURLString =urlString ;[serviceURLString retain] ;
        headersDictionary=[headers mutableCopy] ;//[headersDictionary retain] ;
        bodyString = body ;[bodyString retain];
        delegate=serviceDelegate ;
        serviceRequestMethod =requestMethod ;
    }
    return self ;
}

- (id)initWithURLString : (NSString *)urlString headers : (NSDictionary *)headers bodyData : (NSData *)data 
               delegate : (id<HTTPServiceDelegate>)serviceDelegate requestMethod : (RequestMethod)requestMethod {
    if (self=[super init]) {
        serviceURLString =urlString ;[serviceURLString retain] ;
        headersDictionary=[headers mutableCopy] ;//[headersDictionary retain] ;
        bodyData = data ;[bodyData retain];
        delegate=serviceDelegate ;
        serviceRequestMethod =requestMethod ;
    }
    return self ;
}

- (id)initWithURLString : (NSString *)urlString callType:(DC_URL_CALL_TYPE)serviceCallType headers : (NSDictionary *)headers bodyData: (NSData *)data 
               delegate : (id<HTTPServiceDelegate>)serviceDelegate requestMethod : (RequestMethod)requestMethod {
    if (self=[super init]) {
        callType = serviceCallType;
        serviceURLString =urlString ;[serviceURLString retain] ;
        headersDictionary=[headers mutableCopy] ;//[headersDictionary retain] ;
        bodyData = data ;[bodyData retain];
        delegate=serviceDelegate ;
        serviceRequestMethod =requestMethod ;
    }
    return self ;
}



- (void)startService { //setup the post request header and body and start connection
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.serviceURLString] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15];
    
    if (serviceRequestMethod == kRequestMethodPOST) { //set up request type 
       [request setHTTPMethod:@"POST"] ; 
    }
    
    if (self.headersDictionary!=nil) { //setup headers
        NSArray *headerKeys = [self.headersDictionary allKeys];
        
        for (NSString *headerKey in headerKeys) {
            [request setValue:[self.headersDictionary objectForKey:headerKey] forHTTPHeaderField:headerKey];
        }
    }

    //bodyData isn't null which means it was set by user
    //use it instead of bodyString
    if (self.bodyData) {
        [request setHTTPBody:self.bodyData];
    } else if (self.bodyString){
        [request setHTTPBody:[NSData dataWithBytes:[self.bodyString UTF8String] length:[self.bodyString length]]];
    }
    
//    //check for network reachability before connecting
//    Reachability *internetConnectionStatus = [Reachability reachabilityForInternetConnection];
//    Reachability *wifiConnectionStatus = [Reachability reachabilityForLocalWiFi];
//    Reachability *domainStatus = [Reachability reachabilityWithHostName:SERVER_DOMAIN];
//    
//    NetworkStatus currentInternetStatus = [internetConnectionStatus currentReachabilityStatus];
//    NetworkStatus currentWifiStatus = [wifiConnectionStatus currentReachabilityStatus];
//    NetworkStatus currentDomainStatus = [domainStatus currentReachabilityStatus];
//    
//    
//    NSError *error;
//    if (currentInternetStatus == NotReachable || currentWifiStatus == NotReachable) {
//        error = [NSError errorWithDomain:ERROR_DOMAIN code:kNetworkConnectionError userInfo:nil];
//        [self.delegate serviceDidFailWithError:error];
//        return;
//    }
//    
//    if (currentDomainStatus == NotReachable) {
//        error = [NSError errorWithDomain:ERROR_DOMAIN code:kServerConnectionError userInfo:nil];
//        [self.delegate serviceDidFailWithError:error];
//        return;
//    }
    
    
    
    self.connection = [[[DCURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES forCallType:self.callType] autorelease];

    if (!self.connection) {
        [self.delegate serviceDidFailWithError:nil];
    }
}

#pragma mark - NSURLConnection delegate methods

// Only accept self-signed certificates when debugging, and never present the user with a questioin about certificates

#if kDebug

- (BOOL)connection:(DCURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return YES;
}

- (void)connection:(DCURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

#endif

- (void)connection:(DCURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.receivedData==nil) {
        self.receivedData = [[[NSMutableData alloc] init] autorelease];
    }
    [self.receivedData appendData:data];
    
    
}

- (void)connectionDidFinishLoading:(DCURLConnection *)connection {
    
    [self.delegate didReceiveResponse:self.receivedData];
    if ([(UIViewController *)self.delegate respondsToSelector:@selector(storeResponse:forCallType:)]) {
        [self.delegate storeResponse:self.receivedData forCallType:connection.callType];
    }
}

- (void)connection:(DCURLConnection *)connection didFailWithError:(NSError *)error {
#if kDebug
    NSLog(@"ERROR: %@", [error description]);
#endif
    [self.delegate serviceDidFailWithError:error];
}

- (void)cancelHTTPService {
    [self.connection cancel];
}

- (void) connection:(DCURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
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
    [super dealloc]; 
}


@end
