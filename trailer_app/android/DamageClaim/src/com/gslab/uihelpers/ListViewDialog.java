package com.gslab.uihelpers;

import java.util.ArrayList;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.gslab.R;
import com.gslab.damageclaim.HomePage;
import com.gslab.damageclaim.ReportNewDamage;
import com.gslab.interfaces.Constants;

public class ListViewDialog implements OnItemClickListener {

	private Dialog d;
	private int activityID;
	private Activity activity;;

	public ListViewDialog(Activity activity, int layoutid, String title,
			ArrayList<String> values, int activityID) {
		this.activityID = activityID;
		this.activity = activity;
		try {
			d = new Dialog(activity);
			LayoutInflater li = (LayoutInflater) activity
					.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			d.setContentView(li.inflate(layoutid, null, false));

			ListView list = (ListView) d.findViewById(R.id.listviewdialog);
			list.setOnItemClickListener(this);

			ArrayAdapter<String> adapter = new ArrayAdapter<String>(activity,
					android.R.layout.simple_list_item_single_choice, values);

			list.setAdapter(adapter);
			d.setTitle(title);
			d.show();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void dismissDialog(long id) {
		d.dismiss();
		switch (activityID) {
		case Constants.HOMEPAGE:
			HomePage homepage = (HomePage) activity;
			homepage.setListSelectedItemId(id);
			break;
		case Constants.REPORT_NEW_DAMAGE:
			ReportNewDamage reportnewdamage = (ReportNewDamage) activity;
			reportnewdamage.setListSelectedItemId(id);
			break;

		default:
			Log.i("In default case", "Listviewdialog");
		}
	}

	public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
		dismissDialog(arg3);
	}
}
