package com.gslab.damageclaim;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.webkit.WebView;

import com.gslab.R.id;
import com.gslab.R.layout;
import com.gslab.R.string;
import com.gslab.interfaces.Constants;
import com.gslab.uihelpers.ProgressDialogHelper;

public class About extends Activity {
	
	
	
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(layout.about);
		
		ProgressDialogHelper.showProgressDialog(getApplicationContext(), "", getString(string.loading));
		
		WebView webview = (WebView) findViewById(id.about);
		String response = getIntent().getStringExtra("about");
		webview.loadData(response, "text/html", "UTF-8");
	}
	
	
}
