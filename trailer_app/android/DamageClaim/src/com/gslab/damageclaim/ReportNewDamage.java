package com.gslab.damageclaim;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.util.Log;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.AdapterContextMenuInfo;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.Gallery;
import android.widget.TextView;
import android.widget.Toast;

import com.gslab.R.id;
import com.gslab.R.layout;
import com.gslab.R.string;
import com.gslab.adapters.ListImageAdapter;
import com.gslab.core.CoreComponent;
import com.gslab.helpers.DamageInfo;
import com.gslab.interfaces.Constants;
import com.gslab.interfaces.NetworkListener;
import com.gslab.networking.HTTPRequest;
import com.gslab.uihelpers.ListViewDialog;
import com.gslab.uihelpers.ProgressDialogHelper;
import com.gslab.uihelpers.ToastUI;
import com.gslab.utils.Utility;

@SuppressWarnings("deprecation")
public class ReportNewDamage extends Activity implements OnClickListener,
		OnItemClickListener, NetworkListener {

	private TextView type, position;

	private ArrayList<String> values;
	private ArrayList<Uri> images; // Contains the uri of the original image
									// selected by the user
	private ArrayList<Bitmap> thumbnails; // Contains the thumbnail version of
											// the image selected by the user

	private DamageInfo previous_data;

	private Button done;

	private int selection;

	private Button addnewimage;

	private Uri uri;

	private int selectedID;

	private JSONObject object;

	private JSONArray array;

	private Gallery gallery;

	private String response;

	private HashMap<String, ArrayList<String>> hashmap;
	private HashMap<String, String> typevalues;

	private static Context context;

	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(layout.reportnewdamage);

		context = getApplicationContext();

		hashmap = new HashMap<String, ArrayList<String>>();
		typevalues = new HashMap<String, String>();

		type = (TextView) findViewById(id.reportnewdamage_textview_type);
		type.setOnClickListener(this);

		position = (TextView) findViewById(id.reportnewdamage_textview_position);
		position.setOnClickListener(this);

		values = new ArrayList<String>();

		thumbnails = new ArrayList<Bitmap>();

		addnewimage = (Button) findViewById(id.reportnewdamage_button_damageimages);
		addnewimage.setOnClickListener(this);

		gallery = (Gallery) findViewById(id.reportnewdamage_listview_damageimages);
		gallery.setOnItemClickListener(this);

		done = (Button) findViewById(id.reportnewdamage_button_done);
		done.setOnClickListener(this);

		done.setEnabled(false);

		if (getIntent().getParcelableExtra("previous_data") != null) {

			previous_data = (DamageInfo) getIntent().getParcelableExtra(
					"previous_data");
			new Thread(){
				public void run(){
			getTypeValues();
				}
			}.start();
			loadPreviousData();
		} else {
			images = new ArrayList<Uri>();
			previous_data = new DamageInfo();			
		}
		checkDoneButtonStatus();		
	}

	private static Handler handler = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case Constants.DISMISS_DIALOG:
				ProgressDialogHelper.dismissProgressDialog();
				break;

			case Constants.TOAST:
				ToastUI.showToast(context, CoreComponent.getErr().getMessage());
				break;
			}
		}
	};

	private void loadPreviousData() {
		type.setText(getString(string.reportnewdamage_textview_type)
				+ " " + previous_data.getWhatIsDamaged());
		position.setText(getString(string.reportnewdamage_textview_position) + " " 
				+ previous_data.getLocationOfDamage());
		Log.i("position:", previous_data.getLocationOfDamage());
		images = previous_data.getImagePaths();
		if (images == null) {
			Toast.makeText(getApplicationContext(), "No images fetched",
					Toast.LENGTH_LONG).show();
		}
		for (int i = 0; i < images.size(); i++) {
			thumbnails.add(getBitmapFromUri(images.get(i)));
			// Log.i("uri path", "" + images.get(i).getPath());
		}
		setImageListViewAdapter();
	}

	@SuppressWarnings("unchecked")
	private void getTypeValues() // To be fetched from URL
	{
		values = new ArrayList<String>();

		ProgressDialogHelper.showProgressDialog(this, "", "Loading");

		CoreComponent.processRequest(Constants.GET, Constants.HELPDESK, this,
				createRequest());
		Utility.waitForThread();
		if (this.response != null) {
			try {
				JSONObject temp;
				JSONArray position_array = new JSONArray();
				ArrayList<String> position_values = new ArrayList<String>();
				object = new JSONObject(response);
				array = object.getJSONArray("result");
				for (int i = 0; i < array.length(); i++) {
					position_values.clear();
					temp = array.getJSONObject(i);
					typevalues.put(temp.getString("label"),
							temp.getString("value"));
					values.add(temp.getString("value"));
					Log.i("found", temp.getString("value"));
					temp = temp.getJSONObject("dependency");
					position_array = temp.getJSONArray("damageposition");
					for (int j = 0; j < position_array.length(); j++) {
						position_values.add(position_array.getJSONObject(j)
								.getString("value"));
						Log.i("---",
								position_array.getJSONObject(j).getString(
										"value"));
					}
					Log.i("putting in hashmap", values.get(i));
					hashmap.put(values.get(i), (ArrayList<String>)position_values.clone());
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

	}

	@SuppressWarnings("unchecked")
	private void getPositionValues() // To be fetched from URL
	{
		values.clear();
		Log.i("Getting values for : ",
				Utility.getParsedString(type.getText().toString()));
		values = (ArrayList<String>) hashmap
				.get(Utility.getParsedString(type.getText().toString())).clone();
		if (values == null)
			ToastUI.showToast(
					context,
					"values = null in getting position values : "
							+ Utility
									.getParsedString(type.getText().toString()));
		for(int i = 0;i < values.size();i++){
			Log.i("Showing", values.get(i));
		}
	}

	public void setListSelectedItemId(long id) {
		switch (selection) {
		case Constants.TYPE:
			type.setText(getString(string.reportnewdamage_textview_type) + " "
					+ values.get((int) id));
			position.setText(getString(string.reportnewdamage_textview_position));
			break;

		case Constants.POSITION:
			position.setText(getString(string.reportnewdamage_textview_position)
					+ " " + values.get((int) id));
			break;

		default:
			Toast.makeText(this, getString(string.toast_no_list_item_selected),
					Toast.LENGTH_LONG).show();
		}
		checkDoneButtonStatus();
	}

	private void checkDoneButtonStatus() {
		if (!type
				.getText()
				.toString()
				.equalsIgnoreCase(
						getString(string.reportnewdamage_textview_type))
				&& !position
						.getText()
						.toString()
						.equalsIgnoreCase(
								getString(string.reportnewdamage_textview_position)))
			done.setEnabled(true);
	}

	@Override
	public void onCreateContextMenu(ContextMenu menu, View v,
			ContextMenuInfo menuInfo) {

		super.onCreateContextMenu(menu, v, menuInfo);

		if (v == gallery) {
			selectedID = -1;
			menu.setHeaderTitle(getString(string.report_damage_menu_title));
			menu.add(Menu.NONE, Constants.DELETE, Menu.NONE,
					getString(string.report_damage_menu_item_delete));
			selectedID = ((AdapterContextMenuInfo) menuInfo).position;
		}

	}

	@Override
	public boolean onContextItemSelected(MenuItem item) {

		super.onContextItemSelected(item);

		switch (item.getItemId()) {
		case Constants.DELETE:
			thumbnails.remove(selectedID);
			images.remove(selectedID);
			setImageListViewAdapter();
			break;

		default:
			Toast.makeText(getApplicationContext(),
					"default option is selected in item id", Toast.LENGTH_LONG)
					.show();
		}

		return true;
	}

	@Override
	public void onClick(View v) {

		if (v == type) {
			selection = Constants.TYPE;
			getTypeValues();
			new ListViewDialog(this, layout.listviewdialog,
					getString(string.reportnewdamage_select_type), values,
					Constants.REPORT_NEW_DAMAGE);
		}

		if (v == position) {
			if (type.getText()
					.toString()
					.equalsIgnoreCase(
							getString(string.reportnewdamage_textview_type))) {
				ToastUI.showToast(getApplicationContext(), "Select type first");
				return;
			}
			selection = Constants.POSITION;
			getPositionValues();
			new ListViewDialog(this, layout.listviewdialog,
					getString(string.reportnewdamage_select_position), values,
					Constants.REPORT_NEW_DAMAGE);
		}

		if (v == addnewimage) {
			Intent intent = new Intent(
					Intent.ACTION_PICK,
					android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
			// Intent intent = new Intent(
			// MediaStore.ACTION_IMAGE_CAPTURE
			// );
			startActivityForResult(intent, Constants.INTENT_DATA);
		}

		if (v == done) {
			prepareResult();
		}

	}

	private void prepareResult() {

		Bundle bundle = new Bundle();
		Intent intent = null;
		if (previous_data != null) {
			intent = new Intent();
			previous_data.setImagePaths(images);
			previous_data.setType(Utility.getParsedString(type.getText()
					.toString()));
			previous_data.setLocation(Utility.getParsedString(position
					.getText().toString()));

			bundle.putParcelable("updated_value", previous_data);
			intent.putExtras(bundle);
		}
		setResult(Constants.INTENT_DATA, intent);
		finish();
	}

	private Bitmap getBitmapFromUri(Uri uri) {
		String[] projection = { MediaStore.Images.ImageColumns._ID };
		Cursor cursor = getContentResolver().query(uri, projection, null, null,
				null);
		cursor.moveToPosition(0);

		Bitmap bitmap = MediaStore.Images.Thumbnails.getThumbnail(
				getContentResolver(), cursor.getInt(0),
				MediaStore.Images.Thumbnails.MINI_KIND, null);

		/*
		 * 
		 * thumbnail arraylist = contains a list of the thumbnails to be
		 * displayed in the list images arraylist = contains a list of the image
		 * uri required for the next intent
		 * 
		 * 
		 * The bitmap (above object) contains the thumbnail version of the
		 * image. Add it to the "thumbnails" arraylist To display the full
		 * screen image, the "bitmap" object of the "thumbnail" arraylist cannot
		 * be passed (because it is a thumbnail version of the image) The user
		 * should be able to view the original image with proper height and
		 * width
		 * 
		 * So also store the URI of the selected image from the gallery in the
		 * "images" arraylist
		 * 
		 * When the user clicks on the entry in the imagelistview, pass the URI
		 * of the image to the next intent
		 * 
		 * One approach could have been: 1. When the user selects the image from
		 * the gallery, get the thumbnail version of the image, as well as store
		 * the original image in another bitmap object 2. Pass the another
		 * bitmap object to the next intent to display it full screen
		 * 
		 * We cannot use this approach as there is a common buffer that the
		 * entire application uses to pass any data from one intent to another
		 * intent The buffer size is very less hence it is advised to only pass
		 * data having minimum size (eg. string, int, float, double, etc.)
		 * 
		 * The size of the bitmap object may even be in MBs
		 * 
		 * So bitmap cannot be passed
		 * 
		 * Therefore pass the URI object to the next intent The uri object
		 * contains the path of the original image whose thumbnail is being
		 * selected by the user
		 * 
		 * In the next intent, just use the path of the image and set the bitmap
		 */

		cursor.close();
		return bitmap;
	}

	private void setImageListViewAdapter() {
		Collections.reverse(thumbnails);
		gallery.setAdapter(new ListImageAdapter(this, thumbnails));
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {

		super.onActivityResult(requestCode, resultCode, data);

		if (resultCode == RESULT_OK && data != null) {
			uri = null;
			uri = data.getData();

			if (uri != null) {

				thumbnails.add(getBitmapFromUri(uri));
				images.add(uri);
				setImageListViewAdapter();
			} else
				Toast.makeText(getApplicationContext(), "Uri is null",
						Toast.LENGTH_LONG).show();
		} else {
			// Toast.makeText(getApplicationContext(),
			// "Request code not matching or data is null",
			// Toast.LENGTH_LONG).show();
		}
	}

	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {

		int clickedId = ((int) arg3);
		Intent intent = new Intent(getApplicationContext(),
				DisplayDamageClaimImage.class);
		intent.putExtra("uri", images.get(clickedId));

		startActivity(intent);

	}

	@Override
	public void onBackPressed() {

		previous_data = null;
		prepareResult();

	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {

		menu.add(Menu.NONE, 1, Menu.NONE, "Logout");

		return super.onCreateOptionsMenu(menu);
	}

	@Override
	public void onSuccessFinish(String response) {
		this.response = response;
		handler.sendEmptyMessage(Constants.DISMISS_DIALOG);

	}

	@Override
	public void onError(String status) {
		this.response = null;
		handler.sendEmptyMessage(Constants.DISMISS_DIALOG);
		if (CoreComponent.getErr() != null)
			handler.sendEmptyMessage(Constants.TOAST);

	}

	@Override
	public HTTPRequest createRequest() {

		return CoreComponent.getRequest(Constants.DAMAGE_TYPE);

	}

}
