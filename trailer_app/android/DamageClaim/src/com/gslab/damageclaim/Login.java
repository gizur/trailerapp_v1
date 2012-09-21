package com.gslab.damageclaim;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;

import com.google.gson.Gson;
import com.gslab.R;
import com.gslab.R.id;
import com.gslab.R.string;
import com.gslab.core.CoreComponent;
import com.gslab.helpers.UserInfo;
import com.gslab.interfaces.Constants;
import com.gslab.interfaces.NetworkListener;
import com.gslab.networking.HTTPRequest;
import com.gslab.uihelpers.ProgressDialogHelper;
import com.gslab.uihelpers.ToastUI;
import com.gslab.utils.NetworkCallRequirements;
import com.gslab.utils.Utility;

public class Login extends Activity implements OnClickListener, NetworkListener {

	private Button loginButton;
	private EditText username, password;
	private static Context context;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.login);

		context = getApplicationContext();

		loginButton = (Button) findViewById(id.login_button_login);
		loginButton.setOnClickListener(this);

		username = (EditText) findViewById(id.login_edittext_username);
		username.setSelected(true);

		password = (EditText) findViewById(id.login_edittext_password);
	}

	private static Handler handler = new Handler() {

		@Override
		public void handleMessage(Message msg) {

			super.handleMessage(msg);

			switch (msg.what) {
			case Constants.DISMISS_DIALOG:
				ProgressDialogHelper.dismissProgressDialog();
				break;

			case Constants.TOAST:
				ToastUI.showToast(context, CoreComponent.getErr().getMessage());
				break;
				
			case 2 : 
				ToastUI.showToast(context, "There seems to be an error.\nPlease report this to the developers");
				break;

			default:
				Log.i("Login.java", "in default case - handler");
				ToastUI.showToast(context, "There seems to be an error.\nPlease report this to the developers");
			}
		}

	};

	private void login() {

		String uname = username.getText().toString();
		String pwd = password.getText().toString();

		CoreComponent.setUsername(uname);
		CoreComponent.setPassword(pwd);

		CoreComponent.processRequest(Constants.POST,
				Constants.AUTHENTICATE, this, createRequest());	
	
		Utility.waitForThread();
	}

	private boolean performChecks() {
		if (!NetworkCallRequirements.isNetworkAvailable(this)) {
			Log.i("got it", "the network info");
			ProgressDialogHelper.dismissProgressDialog();
			ToastUI.showToast(getApplicationContext(), "Network unavailable");
			return false;
		}
		return true;
	}

	@Override
	public void onClick(View v) {

		if (v == loginButton) {

			ProgressDialogHelper.showProgressDialog(this, "",
					getString(string.login_pd));

			if (performChecks()) {
				login();
			}

		}

	}

	@Override
	public void onSuccessFinish(String response) {

		CoreComponent
				.setUserinfo(new Gson().fromJson(response, UserInfo.class));

		Intent intent = new Intent(getApplicationContext(), HomePage.class);
		startActivity(intent);

		handler.sendEmptyMessage(Constants.DISMISS_DIALOG);

	}

	@Override
	public void onError(String status) {
		handler.sendEmptyMessage(Constants.DISMISS_DIALOG);
		if (CoreComponent.getErr() != null)
			handler.sendEmptyMessage(Constants.TOAST);
		else
			handler.sendEmptyMessage(2);

	}

	@Override
	public HTTPRequest createRequest() {
		
		return CoreComponent.getRequest(Constants.LOGIN);
	}

}
