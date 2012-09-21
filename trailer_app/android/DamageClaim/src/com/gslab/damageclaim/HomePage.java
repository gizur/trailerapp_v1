package com.gslab.damageclaim;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.gslab.R;
import com.gslab.R.layout;
import com.gslab.R.string;
import com.gslab.core.CoreComponent;
import com.gslab.interfaces.Constants;
import com.gslab.interfaces.NetworkListener;
import com.gslab.networking.HTTPRequest;
import com.gslab.uihelpers.ListViewDialog;
import com.gslab.uihelpers.ProgressDialogHelper;
import com.gslab.uihelpers.ToastUI;
import com.gslab.utils.Utility;

public class HomePage extends Activity implements OnClickListener,
		NetworkListener, Runnable {

	private TextView trailertype, id, place, sealed, plates, straps;
	private ArrayList<String> values, sealed_labels;

	private RelativeLayout trailerinventory;

	private Button submit, damages;

	private int selection;
	
	private String response;
	
	private JSONObject object;
	private JSONArray array;
	
	private Thread thread;
	
	private Context context;

		
	public void onCreate(Bundle savedInstanceState) {
		
			
		super.onCreate(savedInstanceState);				
		setContentView(R.layout.homepage);
		
		context = getApplicationContext();
				
		values = new ArrayList<String>();
		sealed_labels = new ArrayList<String>();
		
		trailerinventory = (RelativeLayout) findViewById(R.id.trailer_inventory);

		trailertype = (TextView) findViewById(R.id.homepage_textview_trailertype);
		trailertype.setText(getString(string.homepage_textview_trailertype)
				+ " " + getString(string.trailer_type_own));
		trailertype.setOnClickListener(this);

		id = (TextView) findViewById(R.id.homepage_textview_id);
		id.setOnClickListener(this);

		place = (TextView) findViewById(R.id.homepage_textview_place);
		place.setOnClickListener(this);
		
		sealed = (TextView) findViewById(R.id.homepage_textview_sealed);	
		sealed.setOnClickListener(this);

		plates = (TextView) findViewById(R.id.homepage_textview_plates);
		plates.setOnClickListener(this);

		straps = (TextView) findViewById(R.id.homepage_textview_straps);
		straps.setOnClickListener(this);

		submit = (Button) findViewById(R.id.homepage_button_submit);
		submit.setEnabled(false);
		submit.setOnClickListener(this);

		damages = (Button) findViewById(R.id.homepage_button_damages);
		damages.setOnClickListener(this);
		selection = Constants.SEALED;
		thread = new Thread(this);
		thread.start();
		
		addTrailerInventory();		
	
	}
	
	
	private  Handler handler = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			
			switch(msg.what){
			case Constants.DISMISS_DIALOG : ProgressDialogHelper.dismissProgressDialog();
			break;
			case 1 : setSealedValue();
			break;
			
			case Constants.TOAST:
				ToastUI.showToast(context, CoreComponent.getErr().getMessage());
				break;
				
			
			}

		}
	};
	
	private void setSealedValue()
	{
		sealed.setText(
				getString(string.homepage_textview_sealed) + " " +				
				values.get(sealed_labels.indexOf(getString(string.sealed_no)))  				
				);
	}

	private void getPlateValues() {
		values.clear();
		values.add("1");
		values.add("2");
		values.add("3");
		values.add("4");
		
	}

	private void getStrapsValues() {
		values.clear();
		values.add("1");
		values.add("2");
		values.add("3");
		values.add("4");
	}

	private void getTrailerTypeValues() {
		values.clear();
		values.add(getString(string.trailer_type_own));
		values.add(getString(string.trailer_type_rented));
	}

	private void getIDValues() // To be fetched from URL
	{

		values.clear();

		ProgressDialogHelper.showProgressDialog(this, "", "Fetching data");
		
		CoreComponent.processRequest(Constants.GET,
				Constants.ASSETS, this, createRequest());
		Utility.waitForThread();
		if(this.response != null){
		try{
			object = new JSONObject(response);
			array = object.getJSONArray("result");
			for(int i = 0;i < array.length();i++)
			{
				values.add(array.getJSONObject(i).getString("id"));				
			}
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}
		}	
		
	}

	private void getPlaceValues() // To be fetched from URL
	{
		values.clear();
		values.add("Place 1");
		values.add("Place 2");
		values.add("Place 3");
		values.add("Place 4");
	}

	private void getSealedValues() {
		values.clear();
		sealed_labels.clear();
//		values.add(getString(string.sealed_yes));
//		values.add(getString(string.sealed_no));
		
		
		ProgressDialogHelper.showProgressDialog(this, "", "Fetching data");
				
		CoreComponent.processRequest(Constants.GET,
				Constants.HELPDESK, this, createRequest());
		Utility.waitForThread();
		if(this.response != null){
		try{
			object = new JSONObject(response);
			array = object.getJSONArray("result");
			for(int i = 0;i < array.length();i++)
			{
				values.add(array.getJSONObject(i).getString("value"));
				sealed_labels.add(array.getJSONObject(i).getString("label"));
				Log.i("sealed label", sealed_labels.get(i));
				
			}
		}
			catch(Exception e)
			{
				e.printStackTrace();
			}
		}
		
	}

	public void setListSelectedItemId(long id) {
		switch (selection) {
		case Constants.TRAILER_TYPE:
			trailertype.setText(getString(string.homepage_textview_trailertype)
					+ " " + values.get((int) id));
			break;

		case Constants.ID:
			this.id.setText(getString(string.homepage_textview_ID) + " "
					+ values.get((int) id));
			checkSubmitButtonStatus();
			break;

		case Constants.PLACE:
			place.setText(getString(string.homepage_textview_place) + " "
					+ values.get((int) id));
			break;

		case Constants.SEALED:
			sealed.setText(getString(string.homepage_textview_sealed) + " "
					+ values.get((int) id));
			if (((int) id) == Constants.YES)
				removeTrailerInventory();
			else
				addTrailerInventory();
			break;

		case Constants.PLATES:
			plates.setText(getString(string.homepage_textview_plates) + " "
					+ values.get((int) id));
			break;

		case Constants.STRAPS:
			straps.setText(getString(string.homepage_textview_straps) + " "
					+ values.get((int) id));
			break;

		default:
			Toast.makeText(this, getString(string.toast_no_list_item_selected),
					Toast.LENGTH_LONG).show();
		}		
	}

	private void checkSubmitButtonStatus() {

		if (id.getText().toString()
				.equalsIgnoreCase(getString(string.homepage_textview_ID)))
		{
			submit.setEnabled(false);			
		}
		else
		{
			submit.setEnabled(true);			
		}

	}

	private void removeTrailerInventory() {
		trailerinventory.setVisibility(RelativeLayout.GONE);
	}

	private void addTrailerInventory() {
		trailerinventory.setVisibility(RelativeLayout.VISIBLE);
	}

	private void setDefaultValues() {
		trailertype.setText(getString(string.homepage_textview_trailertype)
				+ " " + getString(string.trailer_type_own));
		id.setText(getString(string.homepage_textview_ID));
		place.setText(getString(string.homepage_textview_place));
		sealed.setText(getString(string.homepage_textview_sealed) + " "
				+ getString(string.sealed_no));
		plates.setText(getString(string.homepage_textview_plates));
		straps.setText(getString(string.homepage_textview_straps));
		trailerinventory.setVisibility(RelativeLayout.VISIBLE);
	}


	@Override
	public void onClick(View v) {

		if (v == trailertype) {
			selection = Constants.TRAILER_TYPE;
			getTrailerTypeValues();			
			new ListViewDialog(this, layout.listviewdialog,
					getString(string.trailer_type_dialog_title), values,
					Constants.HOMEPAGE);
		}

		if (v == id) {
			selection = Constants.ID;
			getIDValues();			
			new ListViewDialog(this, layout.listviewdialog,
					getString(string.id_dialog_title), values,
					Constants.HOMEPAGE);
		}

		if (v == place) {			
			selection = Constants.PLACE;
			getPlaceValues();
			new ListViewDialog(this, layout.listviewdialog,
					getString(string.id_dialog_title), values,
					Constants.HOMEPAGE);
		}

		if (v == sealed) {			
			selection = Constants.SEALED;
			getSealedValues();
			new ListViewDialog(this, layout.listviewdialog,
					getString(string.id_dialog_title), values,
					Constants.HOMEPAGE);
		}

		if (v == plates) {			
			selection = Constants.PLATES;
			getPlateValues();
			new ListViewDialog(this, layout.listviewdialog,
					getString(string.dialog_title), values, Constants.HOMEPAGE);
		}

		if (v == straps) {
			selection = Constants.STRAPS;
			getStrapsValues();			
			new ListViewDialog(this, layout.listviewdialog,
					getString(string.dialog_title), values, Constants.HOMEPAGE);
		}

		if (v == damages) {
			if(id.getText().toString().equalsIgnoreCase(getString(string.homepage_textview_ID))){
				ToastUI.showToast(getApplicationContext(), "Please select id first");
				return;
			}
			
			CoreComponent.trailerid = id.getText().toString();
			
			Intent intent = new Intent(getApplicationContext(), ReportDamage.class);
			startActivity(intent);
			
		}
		
		if(v == submit) {
			
			if(id.getText().toString().equalsIgnoreCase(getString(string.homepage_textview_ID))){
				ToastUI.showToast(getApplicationContext(), "Please select id first");
				return;
			}
			
			ProgressDialogHelper.showProgressDialog(this, "", "Submitting");
			
			HTTPRequest request = CoreComponent.getRequest(Constants.HELPDESK_URL);
			request.addParam("ticket_title", CoreComponent.getUserinfo().getContactname());
			request.addParam("ticketstatus", "closed");
			request.addParam("trailerid", id.getText().toString());
			request.addParam("reportdamage", "no");
			CoreComponent.processRequest(Constants.POST, Constants.HELPDESK, this, request);
			
			Utility.waitForThread();
			CoreComponent.trailerid = id.getText().toString();
			Log.i("trailer id stored value", id.getText().toString());
			if(this.response != null)
			{
				ToastUI.showToast(getApplicationContext(), getString(string.submit_survey));
			}
			
		}

	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu)
	{
		
		menu.add(Menu.NONE, 1, Menu.NONE, "Reset");
		menu.add(Menu.NONE, 2, Menu.NONE, "Logout");
		return super.onCreateOptionsMenu(menu);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {

		super.onOptionsItemSelected(item);

		switch (item.getItemId()) {
		case 1:
			setDefaultValues();
			break;

		case Constants.LOGOUT:
			break;
		}

		return true;
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
	public void run() {
		getSealedValues();
		if(sealed_labels.contains(getString(string.sealed_no))){
			handler.sendEmptyMessage(1);
			
		}
			else
				ToastUI.showToast(getApplicationContext(), "Cannot get default value for sealed option");
			
		
		
	}

	@Override
	public HTTPRequest createRequest() {
		
		HTTPRequest request = null;
		Log.i("selection", selection + "");
		switch(selection){
		
		case Constants.ID : 
		request = CoreComponent.getRequest(Constants.ASSETS_DATA);
		break;
		
		case Constants.SEALED : request = CoreComponent.getRequest(Constants.SEALED);
		break;
		}
		return request;
		
	}

}
