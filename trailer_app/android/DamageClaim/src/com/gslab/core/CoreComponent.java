package com.gslab.core;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;

import org.apache.http.HttpResponse;
import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.FileBody;
import org.json.JSONException;
import org.json.JSONObject;

import android.net.Uri;
import android.util.Log;

import com.google.gson.Gson;
import com.gslab.helpers.UserInfo;
import com.gslab.helpers.error;
import com.gslab.interfaces.Constants;
import com.gslab.interfaces.NetworkListener;
import com.gslab.networking.HTTPRequest;
import com.gslab.networking.HTTPRequest.RequestMethod;
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
	public static String trailerid;

	
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

	public static HTTPRequest getRequest(int url) {

		Log.i("URL", URLList.getURL(url));

		request = new HTTPRequest(URLList.getURL(url));

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

		return request;
	}

	public synchronized static void processRequest(final String requestType,
			final String model, final NetworkListener listener,
			final HTTPRequest request) {

		runnable = new Runnable() {

			@Override
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

					Log.i("Response string:", request.getResponseString());
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

	public static void processRequestForImages(String requestType, String model,
			NetworkListener listener, HTTPRequest request,
			ArrayList<Uri> imagePaths) {

		File [] file = new File[imagePaths.size()];
		
		mpEntity = new MultipartEntity(HttpMultipartMode.BROWSER_COMPATIBLE);
		
		for(int i = 0;i < imagePaths.size();i++)
		{
			if(imagePaths.get(i).getPath() != null)
			file[i] = new File(imagePaths.get(i).getPath());
			
			Log.i("upload file data", "UPLOAD: file length = " + file[i].length());
		    Log.i("does it exist", "UPLOAD: file exist = " + file[i].exists());
		
		    try {
	        mpEntity.addPart("image", new FileBody(file[i]));	      
	    } catch (Exception e1) {
	        Log.i(e1.getClass().getSimpleName(), "UPLOAD: UnsupportedEncodingException");
	        e1.printStackTrace();
	    }
		}
	      HttpResponse response;
//	    try {
//	        Log.d(TAG, "UPLOAD: about to execute");
//	        response = httpclient.execute(httppost);
//	        Log.d(TAG, "UPLOAD: executed");
//	        HttpEntity resEntity = response.getEntity();
//	        Log.d(TAG, "UPLOAD: respose code: " + response.getStatusLine().toString());
//	        if (resEntity != null) {
//	            Log.d(TAG, "UPLOAD: " + EntityUtils.toString(resEntity));
//	        }
//	        if (resEntity != null) {
//	            resEntity.consumeContent();
//	        }
//	    } catch (ClientProtocolException e) {
//	        e.printStackTrace();
//	    } catch (IOException e) {
//	        e.printStackTrace();
//	    }

		
	}
}
