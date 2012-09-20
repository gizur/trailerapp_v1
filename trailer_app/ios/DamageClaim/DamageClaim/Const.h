//
//  Const.h
//  Plunk
//
//  Created by GS LAB on 21/05/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.

#import <Foundation/Foundation.h>

#define kDebug FALSE

#define kLocalServer FALSE

#define kBuildDate 20120805 //(yyyymmdd)

#define kTestingAPI FALSE

typedef enum {
SIGNUP_URL_CALL_TYPE,
CREATE_HIVE_URL_CALL_TYPE,
RECOMMENDATIONS_URL_CALL_TYPE,
REVIEW_RECOMMENDATIONS_URL_CALL_TYPE,
GET_CATEGORIES_URL_CALL_TYPE,
SUBMIT_REVIEW_URL_CALL_TYPE,
UPDATE_SETTINGS_URL_CALL_TYPE,
INVITE_CONTACT_URL_CALL_TYPE,
GET_MY_PLUNKS_URL_CALL_TYPE,
ADD_RECOMMENDATION_URL_CALL_TYPE,
UPDATE_PLUNK_URL_CALL_TYPE,
SEARCH_WEB_URL_CALL_TYPE,
GET_HIVE_URL_CALL_TYPE
} DC_URL_CALL_TYPE;

#define HTTP_URL @"http://gizurtrailerapp-env.elasticbeanstalk.com/api/index.php/api"


#pragma mark - Keys to share data across the app

#define DAMAGE_DETAIL_MODEL @"DAMAGE_DETAIL_MODEL"
#define NUMBER_OF_IMAGES @"NUMBER_OF_IMAGES"

#define DAMAGE_IMAGE_NAME @"IMAGE"
#define DAMAGE_THUMBNAIL_IMAGE_NAME @"THUMBNAILIMAGE"
#define SURVEY_MODEL @"SURVEY_MODEL"


#define DAMAGE_POSITION_LABEL_DICTIONARY @"DAMAGE_POSITION_LABEL_DICTIONARY"
#define DAMAGE_POSITION_VALUE_DICTIONARY @"DAMAGE_POSITION_VALUE_DICTIONARY"

#define TIME_DIFFERENCE @"TIME_DIFFERENCE"


#define CONTACT_NAME @"CONTACT_NAME"
#define ACCOUNT_NAME @"ACCOUNT_NAME"

#define UNIQUE_SALT @"UNIQUE_SALT"

/////////////////////////////////////////////////////////////////////////////////
enum ADD_PHOTO_ACTION {
    ADD_PHOTO_CAMERA = 0,
    ADD_PHOTO_ALBUM = 1,
    ADD_PHOTO_LIBRARY = 2,
    ADD_PHOTO_CANCEL = 3
};


//layout file tags
enum LOGIN_CELL_TEXT_FIELD_TAGS{
    LOGIN_USERNAME_TEXTFIELD_TAG = -1,
    LOGIN_PASSWORD_TEXTFIELD_TAG = -2
};

enum LOGIN_CUSTOM_CELL_TAGS{
    LOGIN_CUSTOM_CELL_TEXT_FIELD_TAG = -1
};


enum CUSTOM_CELL_SEGMENTED_VIEW_TAGS {
    CUSTOM_CELL_SEGMENTED_TITE_LABEL_TAG = -1,
    CUSTOM_CELL_SEGMENTED_SEGMENTED_VIEW_TAG = -2
};

enum CUSTOM_CELL_TEXTFIELD_TAGS {
    CUSTOM_CELL_TEXTFIELD_TEXTFIELD_TAG = -1
};

enum CUSTOM_CELL_NEW_IMAGE_DAMAGE_TAGS {
    CUSTOM_CELL_TEXT_FIELD_NEW_IMAGE_DAMAGE_TAG = -1,
    CUSTOM_CELL_IMAGE_NEW_IMAGE_DAMAGE_TAG = -2,
    CUSTOM_CELL_LOADING_IMAGE_NEW_IMAGE_TAG = -3,
    };

enum TEXT_FIELD_TAGS {
    TEXT_FIELD_ID_TAG = -1,
    TEXT_FIELD_PLACE_TAG = -2,
    TEXT_FIELD_PLATES_TAG = -3,
    TEXT_FIELD_STRAPS_TAG = -4
};


enum CUSTOM_CELL_PICK_LIST_VIEW_TAGS {
    CUSTOM_CELL_NAME_PICK_LIST_VIEW_TAG = -1,
    CUSTOM_CELL_IMAGE_PICK_LIST_VIEW_TAG = -2
};

enum CUSTOM_CELL_ADD_NEW_ITEM_TAGS {
    CUSTOM_CELL_LABEL_ADD_NEW_ITEM_TAG = -1
    };

enum DCPickListItemTypes {
    DCPickListItemSurveyTrailerId = 1,
    DCPickListItemSurveyPlace,
    DCPickListItemSurveyPlates,
    DCPickListItemSurveyStraps,
    DCPickListItemTypeDamageType,
    DCPickListItemTypeDamagePosition
    
    };


#pragma mark - Other Constants
#define THUMBNAIL_IMAGE_SIZE 80
#define LOADING_IMAGE_SIZE 40
#define GET @"GET"
#define POST @"POST"

#define USER_NAME @"USER_NAME"
#define PASSWORD @"PASSWORD"

#define SUCCESS @"success"
#define ERROR @"error"
#define TRUE_STATUS @"true"
#define FALSE_STATUS @"false"

#define GIZURCLOUD_SECRET_KEY @"GIZURCLOUD_SECRET_KEY"
#define GIZURCLOUD_API_KEY @"GIZURCLOUD_API_KEY"

#define ASSETS_LIST @"ASSETS_LIST"
#define DAMAGE_TYPE_LIST @"DAMAGE_TYPE_LIST"
#define DAMAGE_POSITION_LIST @"DAMAGE_POSITION_LIST"

#define TIME_NOT_IN_SYNC @"TIME_NOT_IN_SYNC"

#define USER_LOGGED_IN @"USER_LOGGED_IN"

#pragma mark - List of all the models
//List of all the models
#define ASSETS @"Assets"
#define HELPDESK @"HelpDesk"
#define AUTHENTICATE @"Authenticate"
#define DOCUMENTATTACHMENTS @"DocumentAttachments"

#pragma mark - header keys
//header strings
#define HOST @"Host"
#define X_SIGNATURE @"x_signature"
#define X_USERNAME @"x_username"
#define X_PASSWORD @"x_password"
#define X_TIMESTAMP @"x_timestamp"
#define X_GIZUR_API_KEY @"x_gizurcloud_api_key"
#define X_UNIQUE_SALT @"x_unique_salt"

#pragma mark - URL identifiers
//URLS identifiers
#define AUTHENTICATE_LOGIN @"Authenticate/login"
#define AUTHENTICATE_LOGOUT @"Authenticate/logout"
#define HELPDESK @"HelpDesk"
#define HELPDESK_ID @"HelpDesk/%@"
#define HELPDESK_DAMAGETYPE @"HelpDesk/damagetype"
#define HELPDESK_DAMAGEPOSITION @"HelpDesk/damageposition"
#define HELPDESK_DAMAGED @"HelpDesk/damaged"
#define ASSETS @"Assets"
#define HELPDESK_TICKETSTATUS @"HelpDesk/ticketstatus"
#define HELPDESK_REPORTDAMAGE @"HelpDesk/reportdamage"
#define HELPDESK_SEALED @"HelpDesk/sealed"
#define HELPDESK_TICKETTITLE @"HelpDesk/ticket_title"
#define DOCUMENTATTACHMENTS_ID @"DocumentAttachments/%@"


