package com.gslab.networking;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URLEncoder;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.util.ArrayList;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.conn.scheme.Scheme;
import org.apache.http.entity.BufferedHttpEntity;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;

import android.graphics.drawable.Drawable;
import android.util.Log;

import com.gslab.core.CoreComponent;

public class HTTPRequest {
	private ArrayList<NameValuePair> params;
	private ArrayList<NameValuePair> headers;
	private String url;
	private int responseCode;
	private String message;
	private String responseString;
	private Drawable responseDrawable;
	private String body;

	public enum RequestMethod {
		GET, POST, PUT
	}

	public HTTPRequest(String url) {
		this.url = url;
		params = new ArrayList<NameValuePair>();
		headers = new ArrayList<NameValuePair>();
	}

	public void addParam(String name, String value) {
		params.add(new BasicNameValuePair(name, value));
	}

	public void addHeader(String name, String value) {
		headers.add(new BasicNameValuePair(name, value));
	}

	public void addBodyText(String body) {
		this.body = body;
	}

	public void execute(RequestMethod method) throws Exception {
		switch (method) {
		case GET: {
			// Add parameters
			String combinedParams = "";
			if (!params.isEmpty()) {
				combinedParams += "?";
				for (NameValuePair p : params) {

					String paramString = p.getName() + "="
							+ URLEncoder.encode(p.getValue(), "UTF-8");
					if (combinedParams.length() > 1)
						combinedParams += "&" + paramString;
					else
						combinedParams += paramString;
				}
			}

			HttpGet request = new HttpGet(url + combinedParams);

			// Add headers
			for (NameValuePair h : headers) {
				Log.i("header info:", h.getName() + ":" + h.getValue());
				request.addHeader(h.getName(), h.getValue());
			}

			executeRequest(request, url);
			break;
		}
		case POST: {
			HttpPost request = new HttpPost(url);
			// Add headers
			for (NameValuePair h : headers) {
				request.addHeader(h.getName(), h.getValue());
				Log.i("header info:", h.getName() + ":" + h.getValue());
			}

			if (!params.isEmpty())
				request.setEntity(new UrlEncodedFormEntity(params, HTTP.UTF_8));

			for (int i = 0; i < params.size(); i++) {
				Log.i("Param info", params.get(i).getName() + " : "
						+ params.get(i).getValue());
			}
			if (CoreComponent.SENDING_IMAGES) {

				request.setEntity(CoreComponent.mpEntity);
				Log.i("HTTPRequest", "inside image condition");
			}

			if (body != null) {
				StringEntity entity = new StringEntity(body, HTTP.UTF_8);
				entity.setContentType("application/json");
				request.setEntity(entity);
			}
			executeRequest(request, url);
			break;
		}

		case PUT: {
			HttpPut request = new HttpPut(url);
			for (NameValuePair h : headers) {
				request.addHeader(h.getName(), h.getValue());
				Log.i("header info : ", h.getName() + " : " + h.getValue());
			}

			if (!params.isEmpty())
				request.setEntity(new UrlEncodedFormEntity(params, HTTP.UTF_8));
			if (body != null) {
				StringEntity entity = new StringEntity(body, HTTP.UTF_8);
				entity.setContentType("application/json");
				request.setEntity(entity);
			}
			executeRequest(request, url);
		}

		}
	}

	private void executeRequest(HttpUriRequest request, String url) {

		HttpClient client = new DefaultHttpClient();
		HttpResponse httpResponse;
		
		/*----------------To be removed---------------------------*/
		
		try {
			client.getConnectionManager().getSchemeRegistry().register(new Scheme("https", TrustAllSSLSocketFactory.getDefault(), 443));
		} catch (KeyManagementException e1) {
			
			e1.printStackTrace();
		} catch (UnrecoverableKeyException e1) {
			
			e1.printStackTrace();
		} catch (NoSuchAlgorithmException e1) {
			
			e1.printStackTrace();
		} catch (KeyStoreException e1) {
			
			e1.printStackTrace();
		}
		
		/*----------------To be removed---------------------------*/

		try {
			httpResponse = client.execute(request);
			responseCode = httpResponse.getStatusLine().getStatusCode();
			message = httpResponse.getStatusLine().getReasonPhrase();
			HttpEntity entity = httpResponse.getEntity();

			if (entity != null) {
				InputStream instream;

				if (entity.getContentType().getValue().contains("image")) {
					BufferedHttpEntity bufferedHttpEntity = new BufferedHttpEntity(
							entity);
					instream = bufferedHttpEntity.getContent();
					responseDrawable = convertStreamToDrawable(instream);
					responseString = null;
				} else {
					instream = entity.getContent();
					responseString = convertStreamToString(instream);
					responseDrawable = null;
				}

				// Closing the input stream will trigger connection release
				instream.close();
			}

		} catch (ClientProtocolException e) {
			client.getConnectionManager().shutdown();
			e.printStackTrace();
		} catch (IOException e) {
			client.getConnectionManager().shutdown();
			e.printStackTrace();
		} catch (Exception e) {
			client.getConnectionManager().shutdown();
			e.printStackTrace();
		}
	}

	private static String convertStreamToString(InputStream is) {
		BufferedReader reader = new BufferedReader(new InputStreamReader(is));
		StringBuilder sb = new StringBuilder();

		String line = null;
		try {
			while ((line = reader.readLine()) != null)
				sb.append(line + "\n");
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				is.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return sb.toString();
	}

	private static Drawable convertStreamToDrawable(InputStream is) {
		return Drawable.createFromStream(is, null);
	}

	public String getResponseString() {
		return responseString;
	}

	public Drawable getResponseDrawable() {
		return responseDrawable;
	}

	public String getErrorMessage() {
		return message;
	}

	public int getResponseCode() {
		return responseCode;
	}
}