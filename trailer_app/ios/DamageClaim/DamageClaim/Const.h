//
//  Const.h
//  Plunk
//
//  Created by GS LAB on 21/05/12.
//  Copyright (c) 2012 developer.gslab@gmail.com. All rights reserved.

#import <Foundation/Foundation.h>

#define kDebug TRUE

#define kLocalServer FALSE

#define kBuildDate 20120805 //(yyyymmdd)

#define kTestingAPI TRUE

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


//Keys to share data across the app
#define DAMAGE_DETAIL_MODEL @"DAMAGE_DETAIL_MODEL"

#define DAMAGE_IMAGE_NAME @"IMAGE"
#define DAMAGE_THUMBNAIL_IMAGE_NAME @"THUMBNAILIMAGE"

#define THUMBNAIL_IMAGE_SIZE 80

enum ADD_PHOTO_ACTION {
    ADD_PHOTO_CAMERA = 0,
    ADD_PHOTO_ALBUM = 1,
    ADD_PHOTO_LIBRARY = 2,
    ADD_PHOTO_CANCEL = 3
};


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
    CUSTOM_CELL_IMAGE_NEW_IMAGE_DAMAGE_TAG = -2
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
    DCPickListItemSurveyTrailerId,
    DCPickListItemSurveyPlace,
    DCPickListItemSurveyPlates,
    DCPickListItemSurveyStraps,
    DCPickListItemTypeDamageType,
    DCPickListItemTypeDamagePosition
    
    };

#define GET @"GET"
#define POST @"POST"

#define USER_NAME @"USER_NAME"
#define PASSWORD @"PASSWORD"

#define GIZURCLOUD_SECRET_KEY @"GIZURCLOUD_SECRET_KEY"
#define GIZURCLOUD_API_KEY @"GIZURCLOUD_API_KEY"

//List of all the models
#define ASSETS @"Assets"
#define HELPDESK @"HelpDesk"
#define AUTHENTICATE @"Authenticate"
#define DOCUMENTS_ATTACHMENT @"DocumentsAttachment"


//header strings
#define HOST @"Host"
#define X_SIGNATURE @"x_signature"
#define X_USERNAME @"x_username"
#define X_PASSWORD @"x_password"
#define X_TIMESTAMP @"x_timestamp"
#define X_GIZUR_API_KEY @"x_gizurcloud_api_key"


//URLS identifiers
#define AUTHENTICATE_LOGIN @"Authenticate/login"


