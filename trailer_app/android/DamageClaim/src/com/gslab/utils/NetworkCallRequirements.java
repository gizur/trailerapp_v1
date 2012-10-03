package com.gslab.utils;

import java.security.Key;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Random;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import android.app.Activity;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

import com.gslab.core.CoreComponent;
import com.gslab.interfaces.Constants;

public class NetworkCallRequirements {

	private final static String TIMESTAMP_STRING = "x_timestamp";
	private final static String USERNAME_STRING = "x_username";
	private final static String PASSWORD_STRING = "x_password";
	private final static String GIZUR_CLOUD_API_KEY_STRING = "x_gizurcloud_api_key";
	private final static String SIGNATURE_STRING = "x_signature";
	private final static String UNIQUESALT = "x_unique_salt";
	private final static String ACCEPT_STRING = "Accept";
	private final static String ACCEPT_LANGUAGE_STRING = "Accept-Language";

	private final static String ACCEPT_VALUE = "text/json";
	private final static String ACCEPT_LANGUAGE_VALUE = "sv,en-us,en;q=0.5";

	public static void setGIZUR_API_KEY_VALUE(String gIZUR_API_KEY_VALUE) {
		GIZUR_API_KEY_VALUE = gIZUR_API_KEY_VALUE;
	}

	public static void setGIZUR_CLOUD_SECRET_KEY(String gIZUR_CLOUD_SECRET_KEY) {
		GIZUR_CLOUD_SECRET_KEY = gIZUR_CLOUD_SECRET_KEY;
	}

	private static String GIZUR_API_KEY_VALUE = "";
	private static String GIZUR_CLOUD_SECRET_KEY = "";

	private static int randomNumber;

	public static String getGizurCloudSecretKey() {
		return GIZUR_CLOUD_SECRET_KEY;
	}

	public static String getTimestampString() {
		return TIMESTAMP_STRING;
	}

	public static String getUsernameString() {
		return USERNAME_STRING;
	}

	public static String getPasswordString() {
		return PASSWORD_STRING;
	}

	public static String getGizurCloudApiKeyString() {
		return GIZUR_CLOUD_API_KEY_STRING;
	}

	public static String getSignatureString() {
		return SIGNATURE_STRING;
	}

	public static String getAcceptString() {
		return ACCEPT_STRING;
	}

	public static String getAcceptLanguageString() {
		return ACCEPT_LANGUAGE_STRING;
	}

	public static String getAcceptValue() {
		return ACCEPT_VALUE;
	}

	public static String getAcceptLanguageValue() {
		return ACCEPT_LANGUAGE_VALUE;
	}

	public static String getGizurApiKeyValue() {
		return GIZUR_API_KEY_VALUE;
	}

	@SuppressWarnings("deprecation")
	public static String getTimeStampValue() {
		SimpleDateFormat date = new SimpleDateFormat("yyyyMMdd'T'HH:mm:ssZ");
		// Date d = new Date();
		// Log.i("before adding", d.toGMTString());
		// d.setSeconds(d.getSeconds() + CoreComponent.getDIFFERENCE());
		// Log.i("after adding", d.toGMTString());
		// String format = date.format(d);

		Calendar calendar = Calendar.getInstance();
		Log.i("before adding", calendar.getTime().toGMTString());
		calendar.set(Calendar.SECOND,
				calendar.SECOND + CoreComponent.getDIFFERENCE());
		Log.i("Calculating time stamp value", CoreComponent.getDIFFERENCE() + "");
		Log.i("after adding", calendar.getTime().toGMTString());
		String format = date.format(calendar.getTime());
		Log.i("Timestamp", format);
		return format;
	}

	public static String getTimeStampValue(int difference) {
		return null;
	}

	private static int generateRandomNumber() {
		return new Random().nextInt(Constants.MAX);
	}

	public static int getRandomNumber() {
		return randomNumber;
	}

	public static String getUniquesalt() {
		return UNIQUESALT;
	}

	public static String getSignatureValue(String timestamp, String type,
			String model) {
		
		Log.i("-------------------------", "Coming and generating signature");
		
		String toencode = "";
		randomNumber = generateRandomNumber();
		Log.i("Random number", randomNumber + "");
		toencode = Constants.KEYID + getGizurApiKeyValue() + Constants.MODEL
				+ model + Constants.TIMESTAMP + timestamp
				+ Constants.UNIQUESALT + randomNumber + Constants.VERB + type
				+ Constants.VERSION + "0.1";

		Log.i("to encode string : ", toencode);
		String afterBase64;

		try {
			afterBase64 = Base64.encodeToString(calculateSHA(toencode), false);
			Log.i("After base64 encoding", afterBase64);
			return afterBase64;
		}

		catch (Exception e) {
			Log.i("*****EXCEPTION******", "Exception while encrypting");
			return null;
		}
	}

	private static byte[] calculateSHA(String text) {
		try {
			Key key = new SecretKeySpec(getGizurCloudSecretKey().getBytes(),
					"HmacSHA256");
			Mac mac = Mac.getInstance(key.getAlgorithm());
			mac.init(key);
			byte[] b = mac.doFinal(text.getBytes());

			Log.i("sha output", new String(b, "UTF8"));
			return b;
		} catch (Exception e) {
			Log.i("exception", "calculating sha");
			return null;
		}
	}

	public static boolean isNetworkAvailable(Activity activity) {
		ConnectivityManager connectivityManager = (ConnectivityManager) activity
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo activeNetworkInfo = connectivityManager
				.getActiveNetworkInfo();
		return activeNetworkInfo != null;
	}

}
