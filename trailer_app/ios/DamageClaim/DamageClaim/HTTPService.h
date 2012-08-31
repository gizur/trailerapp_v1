//
//  HttpService.h
//  Plunk
//
//  Created by GS LAB on 21/05/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Const.h"

@protocol HTTPServiceDelegate
- (void)responseCode:(int)code;
-(void) storeResponse:(NSData *)data forIdentifier:(NSString *) identifier;

@required
- (void)didReceiveResponse :(NSData *)data forIdentifier:(NSString *) identifier;
@required
- (void)serviceDidFailWithError : (NSError *)error forIdentifier:(NSString *) identifier;


@end

#define TIMEOUT_INTERVAL 45

typedef enum {
    kRequestMethodGET,
    kRequestMethodPOST,
    kRequestMethodNone
} RequestMethod;

typedef enum {
    kNetworkConnectionError = -1004,
    kServerTimeOutError = -1001,
    kServerConnectionError
}ConnectionError;

@interface HTTPService : NSObject

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) id<HTTPServiceDelegate>delegate;
@property (nonatomic, retain) NSString *serviceURLString;
@property (nonatomic, retain) NSMutableDictionary *headersDictionary;
@property (nonatomic, retain) NSString *bodyString;
@property (nonatomic, retain) NSMutableURLRequest *request;
@property (nonatomic, retain) NSString *identifier;

//the bodyString when converted to NSData is stored here.
//The dev can also set the data directly
@property (nonatomic, retain) NSData *bodyData;

@property(nonatomic) BOOL isPOST;
@property(nonatomic) RequestMethod serviceRequestMethod;

- (id)initWithURLString : (NSString *)urlString headers : (NSDictionary *)headers body : (NSString *)body 
               delegate : (id<HTTPServiceDelegate>)serviceDelegate requestMethod : (RequestMethod)requestMethod;

- (id)initWithURLString : (NSString *)urlString headers : (NSDictionary *)headers body : (NSString *)body 
               delegate : (id<HTTPServiceDelegate>)serviceDelegate requestMethod : (RequestMethod)requestMethod identifier:(NSString *)iden;


- (void)startService;
- (void)cancelHTTPService ;

@end
