package com.gslab.damageclaim;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
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
import android.widget.ListView;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.gslab.R.id;
import com.gslab.R.layout;
import com.gslab.R.string;
import com.gslab.adapters.DamageListAdapter;
import com.gslab.core.CoreComponent;
import com.gslab.helpers.DamageInfo;
import com.gslab.interfaces.Constants;
import com.gslab.interfaces.NetworkListener;
import com.gslab.networking.HTTPRequest;
import com.gslab.uihelpers.ProgressDialogHelper;
import com.gslab.uihelpers.ToastUI;
import com.gslab.utils.Utility;

@SuppressWarnings("serial")
public class ReportDamage extends Activity implements OnClickListener,
		OnItemClickListener, Serializable, Runnable, NetworkListener {

	private Button report_new_damage, submit;
	private ListView reporting_damage_listview,
			previously_reported_damages_listview;

	private ArrayList<DamageInfo> reporting_damage_list;
	private ArrayList<DamageInfo> previously_reported_damage_list;

	private TextView reporting_damage_textview;

	private int selectedID, reporting_entry;
	
	private Thread thread;
	
	private String response;
	
	private Context context;
	
	private boolean which_request;

	private ScrollView scrollview;
	
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(layout.report_damage);
		
		scrollview = (ScrollView) findViewById(id.reportdamage_scrollview);
		
		which_request = true;
		
		context = getApplicationContext();

		report_new_damage = (Button) findViewById(id.report_damage_button_report_new_damage);		
		report_new_damage.setOnClickListener(this);

		reporting_damage_listview = (ListView) findViewById(id.report_damage_listview_reporting_damage);
		reporting_damage_listview.setOnItemClickListener(this);

		previously_reported_damages_listview = (ListView) findViewById(id.report_damage_listview_previously_reported_damages);
		previously_reported_damages_listview.setOnItemClickListener(this);

		reporting_damage_textview = (TextView) findViewById(id.report_damage_textview_reporting_damage);

		submit = (Button) findViewById(id.report_damage_button_submit);
		submit.setOnClickListener(this);

		reporting_damage_list = new ArrayList<DamageInfo>();
		registerForContextMenu(reporting_damage_listview);

		previously_reported_damage_list = new ArrayList<DamageInfo>();

		checkVisibility();

		ProgressDialogHelper.showProgressDialog(this, "", "Loading");
		thread = new Thread(this);
		thread.start();		
		
	}

		
	private void createPreviouslyReportedDamagesList()
	{
		ProgressDialogHelper.showProgressDialog(this, "", "Loading");
		if(this.response != null)
		{
			JSONObject object;
			JSONArray array;
			try {
				object = new JSONObject(response);
			
			array = object.getJSONArray("result");
			
			for(int i = 0;i < array.length();i++)
			{
				object = array.getJSONObject(i);
				previously_reported_damage_list.add(createDamageInfoWithoutImages(object.getString("damagetype"), object.getString("damageposition")));
				Log.i(object.getString("damagetype"), object.getString("damageposition"));
			}
			} catch (JSONException e) {
				e.printStackTrace();
			}
			setPreviouslyReportedDamagesListAdapter();
			handler.sendEmptyMessage(Constants.DISMISS_DIALOG);
		}
		else
			ToastUI.showToast(getApplicationContext(), "could not retrieve previously reported damages");
	}
	
	private Handler handler = new Handler(){
		@Override
		public void handleMessage(Message msg)
		{
			switch(msg.what)
			{
			case Constants.DISMISS_DIALOG : ProgressDialogHelper.dismissProgressDialog();
			break;
			case 1 : createPreviouslyReportedDamagesList();
			break;
			
			case Constants.TOAST:
				ToastUI.showToast(context, CoreComponent.getErr().getMessage());
				break;
			
			}
		}
	};
	
	private void checkVisibility() {
		if (reporting_damage_list.size() == 0) {
			reporting_damage_listview.setVisibility(ListView.GONE);
			reporting_damage_textview.setVisibility(TextView.GONE);
			submit.setVisibility(Button.GONE);
		} else {
			reporting_damage_listview.setVisibility(ListView.VISIBLE);
			reporting_damage_textview.setVisibility(TextView.VISIBLE);
			submit.setVisibility(Button.VISIBLE);
		}
	}

	private void setListViewHeight() {
		Utility.setListViewHeightBasedOnChildren(previously_reported_damages_listview);
		Utility.setListViewHeightBasedOnChildren(reporting_damage_listview);
	}

	private void setPreviouslyReportedDamagesListAdapter() {
		previously_reported_damages_listview.setAdapter(new DamageListAdapter(
				this, previously_reported_damage_list));
		setListViewHeight();
	}

	private void setReportingDamageListAdapter() {
		Collections.reverse(reporting_damage_list);
		reporting_damage_listview.setAdapter(new DamageListAdapter(this,
				reporting_damage_list));
		setListViewHeight();
	}

	@Override
	public void onBackPressed() {

		if (reporting_damage_list.size() != 0) {
			final Activity activity = this;
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.setMessage(
					"Unclaimed damages will not be saved.\nAre you sure you want to exit?")
					.setCancelable(false)
					.setPositiveButton("Yes",
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int id) {
									activity.finish();
								}
							})
					.setNegativeButton("No",
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int id) {
									dialog.cancel();
								}
							});
			AlertDialog alert = builder.create();
			alert.show();
		} else
			super.onBackPressed();
	}

	private void addToReportingDamageList(DamageInfo info) {
		reporting_damage_list.add(info);
		setReportingDamageListAdapter();
		checkVisibility();
	}

	private void removeFromReportingDamageList(int id) {
		reporting_damage_list.remove(id);
		setReportingDamageListAdapter();
		checkVisibility();
	}

	private DamageInfo createDamageInfoWithoutImages(String what_is_damaged,
			String location_of_damage) /*--------------To be edited---------*/
	{
		return (new DamageInfo(what_is_damaged, location_of_damage));
	}

	@Override
	public boolean onContextItemSelected(MenuItem item) {

		super.onContextItemSelected(item);

		switch (item.getItemId()) {
		case Constants.DELETE:
			removeFromReportingDamageList(selectedID);
			setReportingDamageListAdapter();
			break;

		default:
			Toast.makeText(getApplicationContext(),
					"default option is selected in item id", Toast.LENGTH_LONG)
					.show();
		}

		return true;
	}

	@Override
	public void onCreateContextMenu(ContextMenu menu, View v,
			ContextMenuInfo menuInfo) {

		super.onCreateContextMenu(menu, v, menuInfo);

		if (v == reporting_damage_listview) {
			selectedID = -1;
			menu.setHeaderTitle(getString(string.report_damage_menu_title));
			menu.add(Menu.NONE, Constants.DELETE, Menu.NONE,
					getString(string.report_damage_menu_item_delete));
			selectedID = ((AdapterContextMenuInfo) menuInfo).position;
		}

	}

	@Override
	public void onClick(View v) {

		if (v == report_new_damage) {
			reporting_entry = -1;
			Intent intent = new Intent(this, ReportNewDamage.class);
			startActivityForResult(intent, Constants.INTENT_DATA);
		}

		if (v == submit) {

			ProgressDialogHelper.showProgressDialog(this, "", "Submitting");
			which_request = false;
			HTTPRequest request = createRequest();
			
			int failures = 0;
			
			for(int i = 0;i < reporting_damage_list.size();i++){

				
				request.addParam("ticket_title", CoreComponent.getUserinfo().getContactname());
				request.addParam("ticketstatus", "open");
				request.addParam("trailerid", CoreComponent.trailerid);
				request.addParam("reportdamage", "yes");
								
			request.addParam("damagetype", reporting_damage_list.get(0 + failures).getWhatIsDamaged());
			request.addParam("damageposition", reporting_damage_list.get(0 + failures).getLocationOfDamage());
			request.addParam("trailerid", CoreComponent.trailerid);
			
			CoreComponent.processRequestForImages(Constants.POST, Constants.HELPDESK, this, request, reporting_damage_list.get(0 + failures).getImagePaths());
			
			Utility.waitForThread();
				if(this.response == null)
				{
					failures++;
					continue;
				}
				reporting_damage_list.remove(0);
				setReportingDamageListAdapter();
			}
			if(failures == 0){
				reporting_damage_list.clear();
				ToastUI.showToast(getApplicationContext(), "Damages successfully submitted");
			}
			else
				ToastUI.showToast(getApplicationContext(), "Some damages could not be reported");
			
			checkVisibility();
			CoreComponent.SENDING_IMAGES = false;
			which_request = true;
			getReportedDamagesList();
		}
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {

		super.onActivityResult(requestCode, resultCode, data);

		if (data != null) {
			DamageInfo info = (DamageInfo) data.getExtras().getParcelable(
					"updated_value");
			if (info != null) {
				if (reporting_entry >= 0)
					removeFromReportingDamageList((reporting_entry));
				addToReportingDamageList(info);
			}
		}
	}

	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {

		if (arg0 == reporting_damage_listview) {

			Intent intent = new Intent(getApplicationContext(),
					ReportNewDamage.class);
			intent.putExtra("previous_data",
					reporting_damage_list.get((int) arg3));
			reporting_entry = ((int) arg3);
			startActivityForResult(intent, (int) arg3);
		}

		if (arg0 == previously_reported_damages_listview) {
			Intent intent = new Intent(getApplicationContext(),
					PreviouslyReportedDamagesInfo.class);
			intent.putExtra("previous_data",
					previously_reported_damage_list.get((int) arg3));
			startActivity(intent);
		}

	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {

		menu.add(Menu.NONE, 1, Menu.NONE, "Logout");

		return super.onCreateOptionsMenu(menu);
	}

	@Override
	public void run() {
		getReportedDamagesList();
	}
	
	private void getReportedDamagesList()
	{
		previously_reported_damage_list.clear();
		CoreComponent.processRequest(Constants.GET, Constants.HELPDESK, this, createRequest());
		Utility.waitForThread();	
		scrollview.scrollTo(0, scrollview.getTop());
		handler.sendEmptyMessage(1);
	}

	@Override
	public void onSuccessFinish(String response) {
		this.response = response;
		if(which_request)
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
		
		
		if(which_request){
			return CoreComponent.getRequest(Constants.PREVIOUS_DAMAGES);
		}
		else{
		HTTPRequest request = CoreComponent.getRequest(Constants.HELPDESK_URL);
		request.addParam("ticket_title", CoreComponent.getUserinfo().getContactname());
		request.addParam("ticketstatus", "open");			
		request.addParam("reportdamage", "yes");
		CoreComponent.SENDING_IMAGES = true;		
		return request;
		}
	}
}
