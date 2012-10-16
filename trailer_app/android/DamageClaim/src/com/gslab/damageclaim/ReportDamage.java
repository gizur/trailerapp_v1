package com.gslab.damageclaim;

import java.io.Serializable;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Collections;

import org.apache.http.entity.mime.content.StringBody;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
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
import com.gslab.core.DamageClaimApp;
import com.gslab.helpers.DamageInfo;
import com.gslab.interfaces.Constants;
import com.gslab.interfaces.NetworkListener;
import com.gslab.networking.HTTPRequest;
import com.gslab.uihelpers.ProgressDialogHelper;
import com.gslab.uihelpers.ToastUI;
import com.gslab.utils.NetworkCallRequirements;
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

	private Activity activity;

	private int selectedID, reporting_entry;

	private JSONObject object;
	private JSONArray array;

	private Thread thread;

	private String response;

	private boolean which_request;

	private ScrollView scrollview;

	private int failures = 0, picklist1 = 0, picklist2 = 0;

	private ProgressDialog dialog;

	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(layout.report_damage);

		scrollview = (ScrollView) findViewById(id.reportdamage_scrollview);

		which_request = true;

		dialog = new ProgressDialog(ReportDamage.this);

		getApplicationContext();

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

		if (!NetworkCallRequirements.isNetworkAvailable(this)) {
			Log.i("got it", "the network info");
			ToastUI.showToast(getApplicationContext(),
					getString(string.networkunavailable));

		} else {
			ProgressDialogHelper.showProgressDialog(this, "",
					getString(string.loading));
			thread = new Thread(this);
			thread.start();
		}

	}

	private void createPreviouslyReportedDamagesList() {

		if (this.response != null) {

			try {
				object = new JSONObject(response);

				array = object.getJSONArray("result");

				for (int i = 0; i < array.length(); i++) {
					object = array.getJSONObject(i);
					previously_reported_damage_list
							.add(createDamageInfoWithoutImages(
									object.getString("damagetype"),
									object.getString("damageposition"),
									object.getString("drivercauseddamage")));
					Log.i(object.getString("damagetype"),
							object.getString("damageposition"));

				}
			} catch (JSONException e) {
				e.printStackTrace();
				handler.sendEmptyMessage(Constants.TOAST);
			}

		} else
			ToastUI.showToast(getApplicationContext(),
					getString(string.problem));

	}

	@SuppressLint("HandlerLeak")
	private Handler handler = new Handler() {

		public void handleMessage(Message msg) {
			switch (msg.what) {
			case Constants.DISMISS_DIALOG:
				ProgressDialogHelper.dismissProgressDialog();
				break;

			case 2:
				setPreviouslyReportedDamagesListAdapter();
				break;

			case Constants.TOAST:

				errordialog();
				break;
			}
		}
	};

	private void errordialog() {
		Utility.showErrorDialog(this);
	}

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

	public void onBackPressed() {

		if (reporting_damage_list.size() != 0) {
			final Activity activity = this;
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.setMessage(getString(string.unclaimeddamages))
					.setCancelable(false)
					.setPositiveButton(getString(string.sealed_yes),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int id) {
									activity.finish();
								}
							})
					.setNegativeButton(getString(string.sealed_no),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int id) {
									dialog.cancel();
								}
							});
			AlertDialog alert = builder.create();
			alert.show();
		} else
			finish();
	}

	private void addToReportingDamageList(DamageInfo info) {
		if (!checkDuplication(info)) {
			reporting_damage_list.add(info);
			setReportingDamageListAdapter();
		}
		Log.i(getClass().getSimpleName(), "checking visibility");
		checkVisibility();
	}

	private boolean checkDuplication(DamageInfo info) {

		for (int i = 0; i < reporting_damage_list.size(); i++) {
			if (info.getDriver_caused_damage().equalsIgnoreCase(
					reporting_damage_list.get(i).getDriver_caused_damage())
					&& info.getLocationOfDamage().equalsIgnoreCase(
							reporting_damage_list.get(i).getLocationOfDamage())
					&& info.getWhatIsDamaged().equalsIgnoreCase(
							reporting_damage_list.get(i).getWhatIsDamaged())) {
				ArrayList<Uri> temp = reporting_damage_list.get(i)
						.getImagePaths();
				for (int j = 0; j < info.getImagePaths().size(); j++) {
					temp.add(info.getImagePaths().get(j));
				}
				return true;
			}
		}

		return false;
	}

	private void removeFromReportingDamageList(int id) {
		reporting_damage_list.remove(id);
		setReportingDamageListAdapter();
		checkVisibility();
	}

	private DamageInfo createDamageInfoWithoutImages(String what_is_damaged,
			String location_of_damage, String drivercauseddamage) /*--------------To be edited---------*/
	{
		return (new DamageInfo(what_is_damaged, location_of_damage,
				drivercauseddamage));
	}

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

	private String getReportDamageValueYes() {

		if (DamageClaimApp.report_damage_value_yes != null) {
			return DamageClaimApp.report_damage_value_yes;
		}

		picklist2 = 1;
		HTTPRequest request = createRequest();
		CoreComponent.processRequest(Constants.GET, Constants.HELPDESK, this,
				request);
		Utility.waitForThread();
		picklist2 = 0;
		if (this.response != null) {
			try {
				JSONObject obj = new JSONObject(response);
				JSONArray arr = obj.getJSONArray("result");
				for (int i = 0; i < arr.length(); i++) {
					if (arr.getJSONObject(i).getString("label")
							.equalsIgnoreCase("yes")) {
						Log.i(getClass().getSimpleName(), arr.getJSONObject(i)
								.getString("value"));
						DamageClaimApp.report_damage_value_yes = new String(arr
								.getJSONObject(i).getString("value"));
						return arr.getJSONObject(i).getString("value");
					}
				}
				handler.sendEmptyMessage(Constants.TOAST);
			} catch (Exception e) {
				handler.sendEmptyMessage(Constants.TOAST);
				Log.i(getClass().getSimpleName(),
						"getclosedticketstatusvalue... exception");
			}
		}

		return null;
	}

	private String getOpenTicketStatusValue() {

		if (DamageClaimApp.open_ticket_status_value != null) {
			return DamageClaimApp.open_ticket_status_value;
		}

		picklist1 = 1;
		HTTPRequest request = createRequest();

		CoreComponent.processRequest(Constants.GET, Constants.HELPDESK, this,
				request);
		Utility.waitForThread();
		picklist1 = 0;
		if (this.response != null) {
			try {
				JSONObject obj = new JSONObject(response);
				JSONArray arr = obj.getJSONArray("result");
				for (int i = 0; i < arr.length(); i++) {
					if (arr.getJSONObject(i).getString("label")
							.equalsIgnoreCase("open")) {
						Log.i(getClass().getSimpleName(), arr.getJSONObject(i)
								.getString("value"));
						DamageClaimApp.open_ticket_status_value = new String(
								arr.getJSONObject(i).getString("value"));
						return arr.getJSONObject(i).getString("value");
					}
				}
				handler.sendEmptyMessage(Constants.TOAST);
			} catch (Exception e) {
				handler.sendEmptyMessage(Constants.TOAST);
				Log.i(getClass().getSimpleName(), "damage report... exception");
			}
		}

		return null;
	}

	public void onClick(View v) {

		if (v == report_new_damage) {
			if (CoreComponent.trailerid == null) {
				ToastUI.showToast(getApplicationContext(),
						getString(string.selectid));
				return;
			}
			reporting_entry = -1;
			Intent intent = new Intent(this, ReportNewDamage.class);
			startActivityForResult(intent, Constants.INTENT_DATA);
		}

		if (v == submit) {

			reportdamages();

			// getReportedDamagesList();
		}
	}

	@SuppressWarnings("unchecked")
	private void reportdamages() {
		if (!NetworkCallRequirements.isNetworkAvailable(this)) {
			Log.i("got it", "the network info");
			ToastUI.showToast(getApplicationContext(),
					getString(string.networkunavailable));
			return;
		}

		which_request = false;

		failures = 0;

		activity = this;
		if (null != dialog && dialog.isShowing()) {
			dialog.dismiss();
		}
		dialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
		dialog.setMax(reporting_damage_list.size());
		CoreComponent.SENDING_IMAGES = true;

		startAsyncTask();

	}

	@SuppressWarnings("unchecked")
	private void startAsyncTask() {
		ReportOperation op = new ReportOperation();
		Log.i("size", reporting_damage_list.size() + "");
		op.execute(reporting_damage_list);
	}

	private void checkForErrors() {

		Log.i(getClass().getSimpleName(), "after asynctask size = "
				+ reporting_damage_list.size());
		checkVisibility();
		setReportingDamageListAdapter();
		if (failures == 0) {
			reporting_damage_list.clear();
			ToastUI.showToast(getApplicationContext(),
					getString(string.damagessubmitted));
			CoreComponent.trailerid = null;
			finish();
		} else {
			final Activity activity = this;
			AlertDialog.Builder builder = new AlertDialog.Builder(activity);
			builder.setMessage(activity.getString(string.reportdamageproblem))
					.setCancelable(false)
					.setPositiveButton(activity.getString(string.sealed_yes),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int id) {
									dialog.cancel();
									reportdamages();

								}
							})
					.setNegativeButton(activity.getString(string.sealed_no),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int id) {
									dialog.cancel();
								}
							});
			AlertDialog alert = builder.create();
			alert.show();
		}

		CoreComponent.SENDING_IMAGES = false;
		which_request = true;

	}

	class ReportOperation extends
			AsyncTask<ArrayList<DamageInfo>, String, String> {

		@Override
		protected void onPreExecute() {
			Log.i("Asynchtask", "preexecute");
			dialog.show();
		}

		int i;

		@Override
		protected String doInBackground(ArrayList<DamageInfo>... info) {
			Log.i("Asynctask", "doinbackground---" + info[0].size());
			ArrayList<DamageInfo> list = info[0];

			int success = 0, total = 0;

			total = list.size();

			do {

				try {

					HTTPRequest request = createRequest();

					Log.i("trailer id", CoreComponent.trailerid);

					CoreComponent.processRequestForImages(Constants.POST,
							Constants.HELPDESK, (NetworkListener) activity,
							request, list.get(0 + failures).getImagePaths(),
							activity);

					publishProgress("");
					Utility.waitForThread();

					if (response == null) {
						Log.i("Failure", "in loop");
						failures++;
						continue;
					}
					list.remove(0);
					success++;

				} catch (Exception e) {
					e.printStackTrace();
					Log.i(getClass().getSimpleName(), e.getClass()
							.getSimpleName());
				}
			} while (success + failures != total);
			return null;
		}

		@Override
		protected void onProgressUpdate(String... values) {
			Log.i("Asynchtask", "progress");
			dialog.setProgress(i + 1);

		}

		@Override
		protected void onPostExecute(String result) {

			Log.i("Asynchtask", "postexecute");
			dialog.dismiss();

			checkForErrors();

		}

	}

	protected void onActivityResult(int requestCode, int resultCode, Intent data) {

		super.onActivityResult(requestCode, resultCode, data);

		if (resultCode == RESULT_OK) {
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
	}

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
			try {
				intent.putExtra("json_info", array.getJSONObject((int) arg3)
						.toString());
				Log.i("sending intent data : ", array.getJSONObject((int) arg3)
						.toString());
			} catch (Exception e) {
				e.printStackTrace();
			}
			startActivity(intent);
		}

	}

	public boolean onCreateOptionsMenu(Menu menu) {

		menu.add(Menu.NONE, 2, Menu.NONE, getString(string.changepassword));
		menu.add(Menu.NONE, Constants.LOGOUT, Menu.NONE,
				getString(string.logout));

		return super.onCreateOptionsMenu(menu);
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
		case 2:
			Intent intent = new Intent(getApplicationContext(),
					PasswordReset.class);
			startActivity(intent);
			break;
		}

		return true;
	}

	public void run() {
		getReportedDamagesList();

	}

	private void getReportedDamagesList() {
		previously_reported_damage_list.clear();
		CoreComponent.processRequest(Constants.GET, Constants.HELPDESK, this,
				createRequest());
		Utility.waitForThread();
		scrollview.scrollTo(0, scrollview.getTop());
		handler.sendEmptyMessage(Constants.DISMISS_DIALOG);
		handler.sendEmptyMessage(1);
	}

	public void onSuccessFinish(String response) {
		this.response = response;
		if (which_request) {
			createPreviouslyReportedDamagesList();
			handler.sendEmptyMessage(2);
			handler.sendEmptyMessage(Constants.DISMISS_DIALOG);

		}

	}

	public void onError(String status) {
		this.response = null;
		if (!CoreComponent.SENDING_IMAGES) {
			handler.sendEmptyMessage(Constants.TOAST);
		}

		handler.sendEmptyMessage(Constants.DISMISS_DIALOG);

	}

	public HTTPRequest createRequest() {

		if (picklist1 == 1) {
			return CoreComponent.getRequest(Constants.TICKETSTATUS);
		}

		if (picklist2 == 1) {
			return CoreComponent.getRequest(Constants.REPORTDAMAGE);
		}

		if (CoreComponent.LOGOUT_CALL) {
			return CoreComponent.getRequest(Constants.LOGOUT);
		}

		if (which_request) {
			return CoreComponent.getRequest(Constants.PREVIOUS_DAMAGES);
		} else {

			try {

				HTTPRequest request = CoreComponent
						.getRequest(Constants.HELPDESK_URL);

				CoreComponent.mpEntity = CoreComponent.getMpEntity();

				CoreComponent.mpEntity.addPart("trailerid", new StringBody(
						CoreComponent.trailerid, Charset.forName("UTF-8")));

				CoreComponent.mpEntity.addPart("ticketstatus", new StringBody(
						getOpenTicketStatusValue(), Charset.forName("UTF-8")));

				CoreComponent.mpEntity.addPart("ticket_title",
						new StringBody(CoreComponent.getUserinfo()
								.getContactname(), Charset.forName("UTF-8")));

				CoreComponent.mpEntity.addPart("reportdamage", new StringBody(
						getReportDamageValueYes(), Charset.forName("UTF-8")));

				CoreComponent.mpEntity.addPart("damagetype", new StringBody(
						reporting_damage_list.get(0 + failures)
								.getWhatIsDamaged(), Charset.forName("UTF-8")));

				CoreComponent.mpEntity.addPart(
						"damageposition",
						new StringBody(reporting_damage_list.get(0 + failures)
								.getLocationOfDamage(), Charset
								.forName("UTF-8")));

				CoreComponent.mpEntity.addPart(
						"drivercauseddamage",
						new StringBody(reporting_damage_list.get(0 + failures)
								.getDriver_caused_damage(), Charset
								.forName("UTF-8")));

				/*
				 * need to check the sealed condition what about trailer type?
				 */

				if (DamageClaimApp.place != null)
					CoreComponent.mpEntity.addPart(
							"damagereportlocation",
							new StringBody(DamageClaimApp.place, Charset
									.forName("UTF-8")));

				if (DamageClaimApp.sealed != null)
					CoreComponent.mpEntity.addPart("sealed", new StringBody(
							DamageClaimApp.sealed, Charset.forName("UTF-8")));

				if (DamageClaimApp.sealed
						.equalsIgnoreCase(getString(string.sealed_no))) {
					if (DamageClaimApp.straps != null)
						CoreComponent.mpEntity.addPart("straps",
								new StringBody(DamageClaimApp.straps, Charset.forName("UTF-8")));
					if (DamageClaimApp.plates != null)
						CoreComponent.mpEntity.addPart("plates",
								new StringBody(DamageClaimApp.plates, Charset.forName("UTF-8")));

				}

				return request;
			} catch (Exception e) {
				e.printStackTrace();
			}

		}
		return null;
	}
}
