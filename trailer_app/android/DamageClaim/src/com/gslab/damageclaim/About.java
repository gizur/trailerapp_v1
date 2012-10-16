package com.gslab.damageclaim;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebView;

import com.gslab.R.id;
import com.gslab.R.layout;
import com.gslab.R.string;
import com.gslab.uihelpers.ProgressDialogHelper;
import com.gslab.utils.Utility;

public class About extends Activity {

	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(layout.about);

		ProgressDialogHelper.showProgressDialog(getApplicationContext(), "",
				getString(string.loading));
		
		try {

		WebView webview = (WebView) findViewById(id.about);
		String response = getIntent().getStringExtra("about");
		webview.loadData(response, "text/html", "UTF-8");
		}
		catch(Exception e){
			Utility.showErrorDialog(this);
		}
	}

}
