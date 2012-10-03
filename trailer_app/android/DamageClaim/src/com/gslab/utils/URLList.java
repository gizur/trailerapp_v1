package com.gslab.utils;

import android.util.Log;

import com.gslab.interfaces.Constants;

public class URLList {

	private static String PARENT = "http://gizurtrailerapp-env.elasticbeanstalk.com/api/index.php/api";

	public static void setPARENT(String pARENT) {
		PARENT = pARENT;
	}

	private final static String LOGIN = "/Authenticate/login";
	private final static String ASSETS = "/Assets";
	private final static String SEALED_PICKLIST = "/HelpDesk/sealed";
	private final static String DAMAGE_TYPE = "/HelpDesk/damagetype";
	private final static String HELPDESKURL = "/HelpDesk";
	private final static String PREVIOUS_DAMAGES = "/HelpDesk/damaged";
	private final static String DAMAGE_CAUSED_BY = "/HelpDesk/drivercauseddamage";
	private final static String LOGOUT = "/Authenticate/logout";
	private final static String DOCUMENT_ATTACHMENT = "/DocumentAttachments";
	private final static String ABOUT_URL = "/About";
	private final static String CHANGE_PWD = "/Authentication/changepw";

	public static String getURL(final int which) {

		switch (which) {

		case Constants.LOGIN:
			return (PARENT + LOGIN);

		case Constants.PARENT:
			return PARENT;

		case Constants.ASSETS_DATA:
			return (PARENT + ASSETS);

		case Constants.SEALED:
			return (PARENT + SEALED_PICKLIST);

		case Constants.HELPDESK_URL:
			return (PARENT + HELPDESKURL);

		case Constants.PREVIOUS_DAMAGES:
			return (PARENT + PREVIOUS_DAMAGES);

		case Constants.DAMAGE_TYPE:
			return (PARENT + DAMAGE_TYPE);

		case Constants.CAUSED_DAMAGE:
			return (PARENT + DAMAGE_CAUSED_BY);

		case Constants.LOGOUT:
			return (PARENT + LOGOUT);

		case Constants.DOCUMENT_ATTACHMENT:
			return (PARENT + DOCUMENT_ATTACHMENT);

		case Constants.ABOUT_URL:
			return (PARENT + ABOUT_URL);

		case Constants.CHANGE_PWD:
			return (PARENT + CHANGE_PWD);

		default:
			Log.i("URLList.java", "in default case");
			return null;

		}

	}

}
