//
//  HttpService.h
//  Plunk
//
//  Created by GS LAB on 21/05/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCURLConnection.h"
#import "MBProgressHUD.h"
#import "Const.h"

@protocol HTTPServiceDelegate
- (void)responseCode:(int)code;
-(void) storeResponse:(NSData *)data forCallType:(DC_URL_CALL_TYPE)callType;

@required
- (void)didReceiveResponse :(NSData *)data ;
@required
- (void)serviceDidFailWithError : (NSError *)error ;


@end

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

#define ERROR_DOMAIN @"error.networkstatus.plunk"

@interface HTTPService : NSObject

@property(nonatomic, retain) NSMutableData *receivedData;
@property(nonatomic, retain) DCURLConnection *connection;
@property(nonatomic, assign) id<HTTPServiceDelegate>delegate;
@property(nonatomic, retain) NSString *serviceURLString;
@property(nonatomic, retain) NSMutableDictionary *headersDictionary;
@property(nonatomic, retain) NSString *bodyString;
//the bodyString when converted to NSData is stored here.
//The dev can also set the data directly
@property (nonatomic, retain) NSData *bodyData;
@property(nonatomic) BOOL isPOST;
@property(nonatomic) RequestMethod serviceRequestMethod;
@property(nonatomic) DC_URL_CALL_TYPE callType;

- (id)initWithURLString : (NSString *)urlString headers : (NSDictionary *)headers body : (NSString *)body 
               delegate : (id<HTTPServiceDelegate>)serviceDelegate requestMethod : (RequestMethod)requestMethod;

- (id)initWithURLString : (NSString *)urlString callType:(DC_URL_CALL_TYPE)serviceCallType headers : (NSDictionary *)headers body : (NSString *)body 
               delegate : (id<HTTPServiceDelegate>)serviceDelegate requestMethod : (RequestMethod)requestMethod;

- (id)initWithURLString : (NSString *)urlString headers : (NSDictionary *)headers bodyData : (NSData *)data 
               delegate : (id<HTTPServiceDelegate>)serviceDelegate requestMethod : (RequestMethod)requestMethod;

- (id)initWithURLString : (NSString *)urlString callType:(DC_URL_CALL_TYPE)serviceCallType headers : (NSDictionary *)headers bodyData : (NSData *)data 
               delegate : (id<HTTPServiceDelegate>)serviceDelegate requestMethod : (RequestMethod)requestMethod;

- (void)startService;
- (void)cancelHTTPService ;

@end
