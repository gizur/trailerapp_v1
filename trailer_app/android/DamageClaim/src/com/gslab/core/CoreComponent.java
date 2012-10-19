package com.gslab.core;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;

import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.ByteArrayBody;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.preference.PreferenceManager;
import android.provider.MediaStore;
import android.text.Html;
import android.util.Log;

import com.google.gson.Gson;
import com.gslab.R.string;
import com.gslab.damageclaim.Login;
import com.gslab.helpers.UserInfo;
import com.gslab.helpers.error;
import com.gslab.interfaces.Constants;
import com.gslab.interfaces.NetworkListener;
import com.gslab.networking.HTTPRequest;
import com.gslab.networking.HTTPRequest.RequestMethod;
import com.gslab.uihelpers.ProgressDialogHelper;
import com.gslab.uihelpers.ToastUI;
import com.gslab.utils.NetworkCallRequirements;
import com.gslab.utils.URLList;
import com.gslab.utils.Utility;

public class CoreComponent {

	public static int IMAGE_MAX_SIZE = 500;
	private static UserInfo userinfo = new UserInfo();
	private static error err = new error();
	private static HTTPRequest request;
	private static String username, password, responseString;

	private static Thread thread;
	private static Runnable runnable;

	public static boolean LOGOUT_CALL = false;

	private static int DIFFERENCE = 0;

	public static boolean SENDING_IMAGES = false;
	public static String trailerid = null;

	public static MultipartEntity mpEntity;

	public static String getResponseString() {
		return responseString;
	}

	public static HTTPRequest getRequest() {
		return request;
	}

	public static Runnable getRunnable() {
		return runnable;
	}

	public static int getDIFFERENCE() {
		return DIFFERENCE;
	}

	public static void setResponseString(String responseString) {
		CoreComponent.responseString = responseString;
	}

	public static void setUsername(String username) {
		CoreComponent.username = username;
	}

	public static void setPassword(String password) {
		CoreComponent.password = password;
	}

	public static error getErr() {
		if (err == null)
			err = new error();
		return err;
	}

	public static void setRequest(HTTPRequest request) {
		CoreComponent.request = request;
	}

	public static void setErr(error err) {
		CoreComponent.err = err;
	}

	public static UserInfo getUserinfo() {
		return userinfo;
	}

	public static void setUserinfo(UserInfo userinfo) {
		CoreComponent.userinfo = userinfo;
	}

	public static void performInitialSettings() {
		request.addHeader(NetworkCallRequirements.getUsernameString(),
				CoreComponent.getUsername());

		request.addHeader(NetworkCallRequirements.getPasswordString(),
				CoreComponent.getPassword());

		request.addHeader(NetworkCallRequirements.getGizurCloudApiKeyString(),
				NetworkCallRequirements.getGizurApiKeyValue());

		request.addHeader(NetworkCallRequirements.getAcceptString(),
				NetworkCallRequirements.getAcceptValue());

		request.addHeader(NetworkCallRequirements.getAcceptLanguageString(),
				NetworkCallRequirements.getAcceptLanguageValue());

	}

	public static HTTPRequest getRequest(int url) {

		Log.i("URL", URLList.getURL(url));

		request = new HTTPRequest(URLList.getURL(url));

		performInitialSettings();

		return request;
	}

	public synchronized static void processRequest(final String requestType,
			final String model, final NetworkListener listener,
			final HTTPRequest request) {

		if (!NetworkCallRequirements.isNetworkAvailable((Activity) listener)) {
			Log.i("got it", "the network info");
			ToastUI.showToast(((Activity) listener).getApplicationContext(),
					((Activity) listener).getString(string.networkunavailable));
			listener.onError("Please check your network connection and retry");
			return;
		}

		runnable = new Runnable() {

			public void run() {

				String timestamp = NetworkCallRequirements.getTimeStampValue();

				request.addHeader(NetworkCallRequirements.getTimestampString(),
						timestamp);

				request.addHeader(NetworkCallRequirements.getSignatureString(),
						NetworkCallRequirements.getSignatureValue(timestamp,
								requestType, model));

				request.addHeader(NetworkCallRequirements.getUniquesalt(),
						NetworkCallRequirements.getRandomNumber() + "");

				try {
					if (requestType.equalsIgnoreCase("post"))
						request.execute(RequestMethod.POST);
					if (requestType.equalsIgnoreCase("get"))
						request.execute(RequestMethod.GET);
					if (requestType.equalsIgnoreCase("PUT"))
						request.execute(RequestMethod.PUT);

					responseString = request.getResponseString();
					responseString = Html.fromHtml(responseString).toString();

					if (responseString == null) {
						if (listener != null)
							Utility.showErrorDialog((Activity) listener);
						Log.i("Corecomponent response string", "its null!");
						return;

					}

					Log.i("Response string:", responseString + "---");
					Log.i("Response code:", request.getResponseCode() + "");

					switch (request.getResponseCode()) {
					case Constants.HTTP_STATUS_OK:
						CoreComponent.setErr(null);
						if (null != listener) {
							listener.onSuccessFinish(responseString);
						}
						if (new JSONObject(responseString).getString("success")
								.equalsIgnoreCase("false") && listener != null)
							listener.onError(responseString);
						break;

					case Constants.HTTP_FORBIDDEN:
						Log.i("HTTP Stauts", "FORBIDDEN");
						if (checkForTIME_NO_IN_SYNC()) {
							Log.i("time difference", "making a call again");
							processRequest(requestType, model, listener,
									listener.createRequest());
							Utility.waitForThread();
						} else if (listener != null)
							listener.onError(responseString);
						break;

					default:
						CoreComponent.setErr(new Gson().fromJson(
								new JSONObject(responseString).getJSONObject(
										"error").toString(), error.class));
						Log.i("Network Call Response", responseString);
						if (listener != null)
							listener.onError(CoreComponent.getErr()
									.getMessage());

						Log.i("Error message : ", request.getResponseCode()
								+ "");
						Log.i("Response in exception", responseString);
					}
				} catch (Exception e) {
					if (listener != null) {
						listener.onError(responseString);
					}
					e.printStackTrace();
				}
			}
		};
		thread = new Thread(runnable);
		thread.start();

	}

	public static String getUsername() {
		return username;
	}

	public static String getPassword() {
		return password;
	}

	public static Thread getThread() {
		return thread;
	}

	private static boolean checkForTIME_NO_IN_SYNC() {
		JSONObject object;
		try {
			object = new JSONObject(request.getResponseString());

			object = object.getJSONObject("error");
			if (object.getString("code").equalsIgnoreCase(
					Constants.TIME_NO_IN_SYNC)) {
				DIFFERENCE = object.getInt("time_difference");
				Log.i("got some difference", DIFFERENCE + "");
				return true;
			}
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		return false;
	}

	@SuppressWarnings("deprecation")
	public static void processRequestForImages(String requestType,
			String model, NetworkListener listener, HTTPRequest request,
			ArrayList<Uri> imagePaths, Activity activity) {

		try {

			for (int i = 0; i < imagePaths.size(); i++) {

				String[] projection = { MediaStore.Images.Media.DATA };
				Cursor cursor = activity.managedQuery(imagePaths.get(i),
						projection, null, null, null);
				int column_index = cursor
						.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
				cursor.moveToFirst();
				String path = cursor.getString(column_index);

				// File file = new File(path);
				// Log.i("File status", "" + file.exists());

				//
				//
				// //Decode image size
				// final int IMAGE_MAX_SIZE=500;
				// BitmapFactory.Options o = new BitmapFactory.Options();
				// o.inJustDecodeBounds = true;
				//
				// FileInputStream fis = new FileInputStream(file);
				// BitmapFactory.decodeStream(fis, null, o);
				// fis.close();
				//
				// int scale = 1;
				// if (o.outHeight > IMAGE_MAX_SIZE || o.outWidth >
				// IMAGE_MAX_SIZE) {
				// scale = (int)Math.pow(2, (int)
				// Math.round(Math.log(IMAGE_MAX_SIZE / (double)
				// Math.max(o.outHeight, o.outWidth)) / Math.log(0.5)));
				// }
				//
				// //Decode with inSampleSize
				// BitmapFactory.Options o2 = new BitmapFactory.Options();
				// o2.inSampleSize = scale;
				// fis = new FileInputStream(file);
				// Bitmap bmp = BitmapFactory.decodeStream(fis, null, o2);
				// fis.close();
				//
				//
				// Bitmap bitmap = BitmapFactory.decodeFile(path);
				//
				// // you can change the format of you image compressed for what
				// do
				// // you want;
				// // now it is set up to 640 x 480;
				//
				// Bitmap bmpCompressed = Bitmap.createScaledBitmap(bitmap, 480,
				// 640, true);

				/*--------------------------------------------------------------------------*/

				//
				// Bitmap b = null;
				//
				// //Decode image size
				// BitmapFactory.Options o = new BitmapFactory.Options();
				// o.inJustDecodeBounds = true;
				// // o.inDither=false; //Disable Dithering mode
				// // o.inPurgeable=true; //Tell to gc that whether it needs
				// free memory, the Bitmap can be cleared
				// // o.inInputShareable=true;
				//
				// FileInputStream fis = new FileInputStream(file);
				// b = BitmapFactory.decodeStream(fis, null, o);
				// if(b == null)
				// Log.i("First bitmap decode", "null");
				// fis.close();
				//
				// int scale = 1;
				// if (o.outHeight > 320 || o.outWidth > 240) {
				// scale = (int)Math.pow(2, (int) Math.round(Math.log(320 /
				// (double) Math.max(o.outHeight, o.outWidth)) /
				// Math.log(0.5)));
				// }
				//
				// //Decode with inSampleSize
				// BitmapFactory.Options o2 = new BitmapFactory.Options();
				// o2.inJustDecodeBounds = true;
				// // o2.inDither = false;
				// // o2.inPurgeable = true;
				// // o2.inInputShareable = true;
				// o2.inSampleSize = scale;
				// fis = new FileInputStream(file);
				// b = BitmapFactory.decodeStream(fis, null, o2);
				// fis.close();

				Bitmap b = null;
				try {
					File file = new File(path);

					// Decode image size

					BitmapFactory.Options o = new BitmapFactory.Options();
					o.inJustDecodeBounds = true;

					FileInputStream fis = new FileInputStream(file);
					BitmapFactory.decodeStream(fis, null, o);

					fis.close();

					int scale = 1;
					if (o.outHeight > IMAGE_MAX_SIZE
							|| o.outWidth > IMAGE_MAX_SIZE) {
						scale = (int) Math.pow(
								2,
								(int) Math.round(Math.log(IMAGE_MAX_SIZE
										/ (double) Math.max(o.outHeight,
												o.outWidth))
										/ Math.log(0.5)));
					}

					// Decode with inSampleSize
					BitmapFactory.Options o2 = new BitmapFactory.Options();
					o2.inSampleSize = scale;
					fis = new FileInputStream(file);
					b = BitmapFactory.decodeStream(fis, null, o2);

					fis.close();
				} catch (Exception e) {
				}

				if (b == null) {
					Log.i("bitmap", "null");
					return;
				}

				/*------------------------------------------------------------------------------*/

				ByteArrayOutputStream bos = new ByteArrayOutputStream();

				// CompressFormat set up to JPG, you can change to PNG or
				// whatever you want;

				// bmpCompressed.compress(CompressFormat.JPEG, 100, bos);
				b.compress(CompressFormat.JPEG, 100, bos);

				byte[] data = bos.toByteArray();

				// sending a Image;
				// note here, that you can send more than one image, just add
				// another param, same rule to the String;
				Log.i("Core Component", i + " added image");
				mpEntity.addPart("image" + i, new ByteArrayBody(data,
						"DamageImage" + i + ".jpg"));
				Log.i("added to mpEntity", path);

			}
			CoreComponent.processRequest(requestType, model, listener, request);

		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	public static MultipartEntity getMpEntity() {
		mpEntity = new MultipartEntity(HttpMultipartMode.BROWSER_COMPATIBLE);
		return mpEntity;
	}

	public static void setMpEntity(MultipartEntity mpEntity) {
		CoreComponent.mpEntity = mpEntity;
	}

	public static void logout(Activity activity) {

		HTTPRequest request = getRequest(Constants.LOGOUT);

		ProgressDialogHelper.showProgressDialog(activity, "",
				activity.getString(string.loading));

		CoreComponent.processRequest(Constants.POST, Constants.AUTHENTICATE,
				(NetworkListener) activity, request);

		Utility.waitForThread();

		ProgressDialogHelper.dismissProgressDialog();

		SharedPreferences preferences = PreferenceManager
				.getDefaultSharedPreferences(activity.getApplicationContext());
		SharedPreferences.Editor editor = preferences.edit();

		editor.putBoolean("credentials", false);
		editor.commit();
		Intent intent = new Intent(activity.getApplicationContext(),
				Login.class);
		intent.setFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS);
		activity.startActivity(intent);

		activity.finish();

		CoreComponent.LOGOUT_CALL = false;
	}

}
