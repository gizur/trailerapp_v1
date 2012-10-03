package com.gslab.damageclaim;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.Gallery;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.gslab.R;
import com.gslab.R.layout;
import com.gslab.R.string;
import com.gslab.adapters.ListImageAdapter;
import com.gslab.core.CoreComponent;
import com.gslab.helpers.DamageInfo;
import com.gslab.interfaces.Constants;
import com.gslab.interfaces.NetworkListener;
import com.gslab.networking.HTTPRequest;
import com.gslab.uihelpers.ProgressDialogHelper;
import com.gslab.uihelpers.ToastUI;
import com.gslab.utils.Base64;
import com.gslab.utils.NetworkCallRequirements;
import com.gslab.utils.URLList;
import com.gslab.utils.Utility;

@SuppressLint({ "HandlerLeak", "HandlerLeak" })
@SuppressWarnings("deprecation")
public class PreviouslyReportedDamagesInfo extends Activity implements
		NetworkListener, OnItemClickListener {

	private Button toremoveAddNewImages, done;
	private DamageInfo info;
	private TextView type, position, drivercauseddamage;

	private JSONObject object;
	private JSONArray array;

	private Bitmap temp;

	private String id[];
	private String trouble_ticket_id, response, image_id;

	private Context context;

	private static String error;

	private boolean FETCH_IMAGES;

	private ArrayList<Bitmap> damaged_images;

	private Gallery gallery;

	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(layout.reportnewdamage);

		context = getApplicationContext();

		FETCH_IMAGES = false;

		toremoveAddNewImages = (Button) findViewById(R.id.reportnewdamage_button_damageimages);
		done = (Button) findViewById(R.id.reportnewdamage_button_done);

		toremoveAddNewImages.setVisibility(Button.GONE);
		done.setVisibility(LinearLayout.GONE);

		info = getIntent().getParcelableExtra("previous_data");

		type = (TextView) findViewById(R.id.reportnewdamage_textview_type);
		type.setCompoundDrawables(null, null, null, null);

		position = (TextView) findViewById(R.id.reportnewdamage_textview_position);
		position.setCompoundDrawables(null, null, null, null);

		drivercauseddamage = (TextView) findViewById(R.id.reportnewdamage_textview_damagecaused);
		drivercauseddamage.setCompoundDrawables(null, null, null, null);

		gallery = (Gallery) findViewById(R.id.reportnewdamage_listview_damageimages);
		gallery.setOnItemClickListener(this);

		damaged_images = new ArrayList<Bitmap>();

		type.setText(type.getText() + " " + info.getWhatIsDamaged());
		position.setText(position.getText() + " " + info.getLocationOfDamage());
		if (info.getDriver_caused_damage().equalsIgnoreCase("yes"))
			drivercauseddamage.setText(drivercauseddamage.getText().toString()
					+ " " + "Driver");
		else
			drivercauseddamage.setText(drivercauseddamage.getText().toString()
					+ " " + "Other");

		new Thread() {
			public void run() {
				try {
					object = new JSONObject(getIntent().getStringExtra(
							"json_info"));
					if (object != null) {
						trouble_ticket_id = object.getString("id");
						getTroubleTicket(trouble_ticket_id);
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}.start();
	}

	private Handler handler = new Handler() {
		public void handleMessage(Message msg) {
			switch (msg.what) {

			case Constants.DISMISS_DIALOG:
				ProgressDialogHelper.dismissProgressDialog();
				break;

			case Constants.LISTVIEW:
				setGalleryAdapter();
				break;

			case Constants.TOAST:
				errordialog();
				break;
			}
		}

	};
	
	private void errordialog()
	{
		Utility.showErrorDialog(this);
	}

	private void setGalleryAdapter() {

		gallery.setAdapter(new ListImageAdapter(this, damaged_images));

	}

	private void getTroubleTicket(String id2) {

		if (!NetworkCallRequirements.isNetworkAvailable(this)) {
			Log.i("got it", "the network info");
			ToastUI.showToast(getApplicationContext(), getString(string.networkunavailable));
			return;
		}

		ProgressDialogHelper.showProgressDialog(this, "",
				getString(string.loading));

		id = null;

		HTTPRequest request = createRequest();
		CoreComponent.processRequest(Constants.GET, Constants.HELPDESK, this,
				request);

		Utility.waitForThread();

		if (this.response != null) {
			try {
				object = new JSONObject(response);
				object = object.getJSONObject("result");
				array = object.getJSONArray("documents");
				id = new String[array.length()];
				for (int i = 0; i < array.length(); i++) {
					id[i] = array.getJSONObject(i).getString("id");
				}
				FETCH_IMAGES = true;
				fetchImages();
				FETCH_IMAGES = false;
			} catch (JSONException e) {
				e.printStackTrace();
				ToastUI.showToast(context, getString(string.noimages));
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

	}

	private void fetchImages() {

		damaged_images.clear();

		for (int i = 0; i < id.length; i++) {
			temp = BitmapFactory.decodeResource(getResources(),
					R.drawable.loading);
			damaged_images.add(temp);
			Log.i(getClass().getSimpleName(), id[i]);
		}

		handler.sendEmptyMessage(Constants.LISTVIEW);

		int failures = 0;
		for (int i = 0; i < id.length; i++) {
			image_id = id[i];
			HTTPRequest request = createRequest();
			CoreComponent.processRequest(Constants.GET,
					Constants.DOCUMENT_ATTACHMENTS, this, request);
			Utility.waitForThread();
			try {
				object = new JSONObject(response);
				object = object.getJSONObject("result");
				String imageString = object.getString("filecontent");

				final int IMAGE_MAX_SIZE = 250;
				BitmapFactory.Options o = new BitmapFactory.Options();
				o.inJustDecodeBounds = true;

				int scale = 1;
				if (o.outHeight > IMAGE_MAX_SIZE || o.outWidth > IMAGE_MAX_SIZE) {
					scale = (int) Math.pow(
							2,
							(int) Math.round(Math.log(IMAGE_MAX_SIZE
									/ (double) Math
											.max(o.outHeight, o.outWidth))
									/ Math.log(0.5)));
				}

				// Decode with inSampleSize
				BitmapFactory.Options o2 = new BitmapFactory.Options();
				o2.inSampleSize = scale;

				byte[] img = Base64.decode(imageString);
				Bitmap bitmap = BitmapFactory.decodeByteArray(img, 0,
						img.length, o2);
				Log.i(getClass().getSimpleName(), "successfully decoded");

				damaged_images.remove(i - failures);
				damaged_images.add(0, bitmap);

				handler.sendEmptyMessage(Constants.LISTVIEW);

			} catch (NullPointerException e) {
				damaged_images.remove(i - failures);
				failures++;
				handler.sendEmptyMessage(Constants.LISTVIEW);
				e.printStackTrace();
			} catch (Exception e) {
				damaged_images.remove(i - failures);
				handler.sendEmptyMessage(Constants.LISTVIEW);
				e.printStackTrace();
			}
		}

	}

	public boolean onCreateOptionsMenu(Menu menu) {

		
		//menu.add(Menu.NONE, 2, Menu.NONE, getString(string.resetpassword));
		menu.add(Menu.NONE, Constants.LOGOUT, Menu.NONE,
				getString(string.logout));

		return super.onCreateOptionsMenu(menu);
	}

	public void onSuccessFinish(String response) {
		this.response = response;
		if (!FETCH_IMAGES)
			handler.sendEmptyMessage(Constants.DISMISS_DIALOG);
	}

	public void onError(String status) {
		this.response = null;
		handler.sendEmptyMessage(Constants.DISMISS_DIALOG);
		error = status;
		handler.sendEmptyMessage(Constants.TOAST);

	}

	public HTTPRequest createRequest() {

		if (CoreComponent.LOGOUT_CALL) {
			return CoreComponent.getRequest(Constants.LOGOUT);
		}

		if (!FETCH_IMAGES) {

			HTTPRequest request = new HTTPRequest(
					URLList.getURL(Constants.HELPDESK_URL) + "/"
							+ trouble_ticket_id);
			Log.i("URL to be hit : ", URLList.getURL(Constants.HELPDESK_URL)
					+ "/" + trouble_ticket_id);
			CoreComponent.setRequest(request);
			CoreComponent.performInitialSettings();

			return request;
		} else {
			HTTPRequest request = new HTTPRequest(
					URLList.getURL(Constants.DOCUMENT_ATTACHMENT) + "/"
							+ image_id);
			CoreComponent.setRequest(request);
			CoreComponent.performInitialSettings();
			return request;
		}

	}

	public boolean onOptionsItemSelected(MenuItem item) {

		super.onOptionsItemSelected(item);

		switch (item.getItemId()) {

		case Constants.LOGOUT:
			CoreComponent.LOGOUT_CALL = true;
			if (!NetworkCallRequirements.isNetworkAvailable(this)) {
				Log.i("got it", "the network info");
				ToastUI.showToast(getApplicationContext(),
						getString(string.networkunavailable));

			} else {
				ProgressDialogHelper.showProgressDialog(this, "",
						getString(string.loading));
				CoreComponent.logout(this);
			}
			break;
			
		case 2 : Intent intent = new Intent(getApplicationContext(), PasswordReset.class);
		startActivity(intent);
		break;
		}

		return true;
	}

	public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {

		if (arg0 == gallery) {
			Intent intent = new Intent(getApplicationContext(),
					DisplayDamageClaimImage.class);

			intent.putExtra("report_damage", false);
			Utility.BITMAP = damaged_images.get((int) arg3);
			startActivity(intent);
		}

	}

}
