package com.gslab.core;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;

import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.ByteArrayBody;
import org.json.JSONException;
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
import android.util.Log;

import com.google.gson.Gson;
import com.gslab.damageclaim.Login;
import com.gslab.helpers.UserInfo;
import com.gslab.helpers.error;
import com.gslab.interfaces.Constants;
import com.gslab.interfaces.NetworkListener;
import com.gslab.networking.HTTPRequest;
import com.gslab.networking.HTTPRequest.RequestMethod;
import com.gslab.uihelpers.ToastUI;
import com.gslab.utils.NetworkCallRequirements;
import com.gslab.utils.URLList;
import com.gslab.utils.Utility;

public class CoreComponent {

	private static UserInfo userinfo;
	private static error err;
	private static HTTPRequest request;
	private static String username, password, responseString;

	private static Thread thread;
	private static Runnable runnable;
	
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
	
	public static void performInitialSettings()
	{
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
			ToastUI.showToast( ((Activity) listener).getApplicationContext() , "Network unavailable");	
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

					Log.i("Response string:", request.getResponseString() + "---");
					Log.i("Response code:", request.getResponseCode() + "");

					switch (request.getResponseCode()) {
					case Constants.HTTP_STATUS_OK:
						CoreComponent.setErr(null);
						if (null != listener) {							
							listener.onSuccessFinish(request
									.getResponseString());
						}
						break;

					case Constants.HTTP_FORBIDDEN:
						Log.i("HTTP Stauts", "FORBIDDEN");						
						if(checkForTIME_NO_IN_SYNC()){				
							Log.i("time difference", "making a call again");							
						processRequest(requestType, model, listener, listener.createRequest());		
						Utility.waitForThread();
						}
						else
							listener.onError(request.getResponseString());
						break;

					default:
						CoreComponent.setErr(new Gson().fromJson(
								new JSONObject(request.getResponseString())
										.getJSONObject("error").toString(),
								error.class));
						//DIFFERENCE = 0;
						responseString = request.getResponseString();
						Log.i("Network Call Response", responseString);
						listener.onError(request.getResponseString());
					}
				} catch (Exception e) {
					Log.i("Error message : ", request.getResponseCode() + "");
					listener.onError(request.getResponseString());
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
		} catch (JSONException e) {
			e.printStackTrace();
			return false;
		}
		return false;		
	}

	
	@SuppressWarnings("deprecation")
	public static void processRequestForImages(String requestType, String model,
			NetworkListener listener, HTTPRequest request,
			ArrayList<Uri> imagePaths, Activity activity) {

	
		
		
		  try {
			    
		        for(int i = 0;i < imagePaths.size();i++){
		        
		        String[] projection = { MediaStore.Images.Media.DATA };
		        Cursor cursor = activity.managedQuery(imagePaths.get(i), projection, null, null, null);
		        int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
		        cursor.moveToFirst();
		        String path =  cursor.getString(column_index);		  		          
		          
		        Bitmap bitmap = BitmapFactory.decodeFile(path);  
		  
		        // you can change the format of you image compressed for what do you want;  
		        //now it is set up to 640 x 480;  
		  
		        Bitmap bmpCompressed = Bitmap.createScaledBitmap(bitmap, 640, 480, true);  
		        ByteArrayOutputStream bos = new ByteArrayOutputStream();  
		  
		        // CompressFormat set up to JPG, you can change to PNG or whatever you want;  
		  
		        bmpCompressed.compress(CompressFormat.JPEG, 100, bos);  
		        byte[] data = bos.toByteArray(); 
		        
		        // sending a Image;  
		        // note here, that you can send more than one image, just add another param, same rule to the String;  
		        Log.i("Core Component", i + " added image");
		        mpEntity.addPart("image"+i, new ByteArrayBody(data, "DamageImage"+i+".jpg"));		        
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
		CoreComponent.processRequest(Constants.POST,
				Constants.AUTHENTICATE, (NetworkListener)activity, request);	
	
		Utility.waitForThread();
		SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(activity.getApplicationContext());
		SharedPreferences.Editor editor = preferences.edit();
		editor.putBoolean("credentials", false);
		editor.commit();
		Intent intent = new Intent(activity.getApplicationContext(), Login.class);		
		intent.setFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS);
		activity.startActivity(intent);
		activity.finish();
		
	}
	
}