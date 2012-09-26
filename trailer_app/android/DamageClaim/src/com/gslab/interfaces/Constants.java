package com.gslab.interfaces;

import android.graphics.Bitmap;

public interface Constants {
	public static final int TRAILER_TYPE = 1;
	public static final int ID = 2;
	public static final int PLACE = 3;
	public static final int SEALED = 4;
	public static final int PLATES = 5;
	public static final int STRAPS = 6;

	public static final int HOMEPAGE = 11;
	public static final int REPORT_NEW_DAMAGE = 12;

	public static final int YES = 0;
	public static final int NO = 1;

	public static final int REPORT_DAMAGE = 1;
	public static final int LOGOUT = 2;
	
	public static final int TYPE = 31;
	public static final int POSITION = 32;
	public static final int CAUSED_DAMAGE = 33;
	
	public static final int LISTVIEW = 9;
	public static final int CAMERA = 10;

	public static final int INTENT_DATA = 100;
	public static final int DELETE = 1;

	public static final int LOGIN = 51;
	public static final int PARENT = 50;
	public static final int ASSETS_DATA = 52;
	public static final int HELPDESK_URL = 53;
	public static final int PREVIOUS_DAMAGES = 54;
	public static final int DAMAGE_TYPE = 55;
	public static final int DOCUMENT_ATTACHMENT = 56;
	
	public static final int TOAST = 72;

	public static final String POST = "POST";
	public static final String GET = "GET";
	
	public static final int DISMISS_DIALOG = 71;

	public static final int HTTP_STATUS_OK = 200;
	public static final int HTTP_BAD_REQUEST = 400;
	public static final int HTTP_FORBIDDEN = 403;
	public static final int HTTP_NOT_FOUND = 404;
	public static final int HTTP_METHOD_NOT_ALLOWED = 405;

	/*-----Strings required for signature-------*/

	public static final String KEYID = "KeyID";
	public static final String MODEL = "Model";
	public static final String VERSION = "Version";
	public static final String TIMESTAMP = "Timestamp";
	public static final String VERB = "Verb";
	public static final String UNIQUESALT = "UniqueSalt";
	
	/*------------------------------------------*/

	/*-----Strings required for model-----------*/
	
	public static final String ASSETS = "Assets";
	public static final String HELPDESK = "HelpDesk";
	public static final String AUTHENTICATE = "Authenticate";
	public static final String DOCUMENT_ATTACHMENTS = "DocumentAttachments";
	public static final String ABOUT = "About";
	
	
	/*----------------Model fields - helpdesk------------*/
	
	public static final int MAX = 2147483647;			//maximum value that an integer can take
	public static final String TIME_NO_IN_SYNC = "TIME_NOT_IN_SYNC";
	public static final int SPLASH_DISPLAY_LENGTH = 3000;
	public static Bitmap BITMAP = null;
	
}
