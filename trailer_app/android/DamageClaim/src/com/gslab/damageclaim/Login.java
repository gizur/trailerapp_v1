package com.gslab.damageclaim;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.preference.PreferenceManager;
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
	private SharedPreferences preferences;
	private SharedPreferences.Editor editor;
	private String uname, pwd;

	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.login);

		preferences = PreferenceManager.getDefaultSharedPreferences(this);
		editor = preferences.edit();

		Log.i(getClass().getSimpleName(), "App Started");

		if (preferences.getBoolean("credentials", false)) {
			uname = preferences.getString("username", "username");
			pwd = preferences.getString("password", "password");
//			Log.i("login", "here");
//			new Thread(){
//				public void run(){
//			login();
//				}
//			}.start();
			CoreComponent.setUsername(uname);
			CoreComponent.setPassword(pwd);
			Intent intent = new Intent(getApplicationContext(), HomePage.class);
			startActivity(intent);
			finish();
		}

		else {

			Log.i("login", "no username and password found");
			context = getApplicationContext();

			loginButton = (Button) findViewById(id.login_button_login);
			loginButton.setOnClickListener(this);

			username = (EditText) findViewById(id.login_edittext_username);
			username.setSelected(true);

			password = (EditText) findViewById(id.login_edittext_password);
		}
	}

	private static Handler handler = new Handler() {

		public void handleMessage(Message msg) {

			super.handleMessage(msg);

			switch (msg.what) {
			case Constants.DISMISS_DIALOG:
				ProgressDialogHelper.dismissProgressDialog();
				break;

			case Constants.TOAST:
				ToastUI.showToast(context, CoreComponent.getErr().getMessage());
				break;

			case 2:
				ToastUI.showToast(context,
						"There seems to be an error.\nPlease report this to the developers");
				break;

			default:
				Log.i("Login.java", "in default case - handler");
				ToastUI.showToast(context,
						"There seems to be an error. Restart your connection.\n If problem exists, please report this to the developers");
			}
		}

	};

	private void login() {

		ProgressDialogHelper.showProgressDialog(this, "",
				getString(string.login_pd));
		
		CoreComponent.setUsername(uname);
		CoreComponent.setPassword(pwd);

		CoreComponent.processRequest(Constants.POST, Constants.AUTHENTICATE,
				this, createRequest());

		Utility.waitForThread();
	}

	private boolean performChecks() {
		if (!NetworkCallRequirements.isNetworkAvailable(this)) {
			Log.i("got it", "the network info");
			ToastUI.showToast(getApplicationContext(), "Network unavailable");
			return false;
		}

		if (!Utility.isEmailValid(username.getText().toString())) {
			ToastUI.showToast(context, "Enter a valid email id");
			return false;
		}

		return true;
	}

	public void onClick(View v) {

		if (v == loginButton) {

			if (performChecks()) {
			

				uname = username.getText().toString();
				pwd = password.getText().toString();

				Log.i(getClass().getSimpleName(), "coming here");
				login();
			}

		}

	}

	public void onSuccessFinish(String response) {

		CoreComponent
				.setUserinfo(new Gson().fromJson(response, UserInfo.class));

		editor.putBoolean("credentials", true);
		editor.putString("username", uname);
		editor.putString("password", pwd);
		editor.commit();

		Intent intent = new Intent(getApplicationContext(), HomePage.class);
		startActivity(intent);

		handler.sendEmptyMessage(Constants.DISMISS_DIALOG);
		finish();

	}

	public void onError(String status) {
		handler.sendEmptyMessage(Constants.DISMISS_DIALOG);
		if (CoreComponent.getErr() != null)
			handler.sendEmptyMessage(Constants.TOAST);
		else
			handler.sendEmptyMessage(2);

	}

	public HTTPRequest createRequest() {

		return CoreComponent.getRequest(Constants.LOGIN);
	}

}
