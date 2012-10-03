package com.gslab.damageclaim;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
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
import android.widget.ImageView;

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
	private static String error;
	private ImageView imageview;
	private boolean login_req = true;
	private String response;

	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.login);

		imageview = (ImageView) findViewById(id.info_image);
		imageview.setOnClickListener(this);

		preferences = PreferenceManager.getDefaultSharedPreferences(this);
		editor = preferences.edit();

		Log.i(getClass().getSimpleName(), "App Started");

		if (preferences.getBoolean("credentials", false)) {
			uname = preferences.getString("username", "username");
			pwd = preferences.getString("password", "password");
			// Log.i("login", "here");
			// new Thread(){
			// public void run(){
			// login();
			// }
			// }.start();
			if (!preferences.getString("accountname", "").equals(""))
				;
			CoreComponent.getUserinfo().setAccountname(
					preferences.getString("accountname", ""));
			if (!preferences.getString("contactname", "").equals(""))
				;
			CoreComponent.getUserinfo().setContactname(
					preferences.getString("contactname", ""));
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

	private Handler handler = new Handler() {

		public void handleMessage(Message msg) {

			super.handleMessage(msg);

			switch (msg.what) {
			case Constants.DISMISS_DIALOG:
				ProgressDialogHelper.dismissProgressDialog();
				break;

			case Constants.TOAST:
				//ToastUI.showToast(context, context.getString(string.problem));
				showErrorDialog();
				break;

			default:
				Log.i("Login.java", "in default case - handler");
				ToastUI.showToast(context, context.getString(string.problem));
			}
		}

	};
	
	private void showErrorDialog()
	{
		final Activity act = this;
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setMessage(getString(string.invalidlogin))
				.setCancelable(false)
				.setPositiveButton(getString(string.resetpassword),
						new DialogInterface.OnClickListener() {
							public void onClick(DialogInterface dialog,
									int id) {
								
//								Intent intent = new Intent(act.getApplicationContext(), PasswordReset.class);
//								startActivity(intent);
								
							}
						})
				.setNegativeButton(getString(string.cancel),
						new DialogInterface.OnClickListener() {
							public void onClick(DialogInterface dialog,
									int id) {
								dialog.cancel();
							}
						});
		AlertDialog alert = builder.create();
		alert.show();
	}

	private void login() {

		ProgressDialogHelper.showProgressDialog(this, "",
				getString(string.loading));

		CoreComponent.setUsername(uname);
		CoreComponent.setPassword(pwd);

		CoreComponent.processRequest(Constants.POST, Constants.AUTHENTICATE,
				this, createRequest());

		Utility.waitForThread();
	}

	private boolean performChecks() {
		if (!NetworkCallRequirements.isNetworkAvailable(this)) {
			Log.i("got it", "the network info");
			ToastUI.showToast(getApplicationContext(),
					getString(string.networkunavailable));
			return false;
		}

		if (!Utility.isEmailValid(username.getText().toString())) {
			ToastUI.showToast(context, getString(string.validemail));
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

		if (v == imageview) {
			login_req = false;

			ProgressDialogHelper.showProgressDialog(this,
					"", getString(string.loading));

			CoreComponent.processRequest(Constants.GET, Constants.ABOUT, this,
					createRequest());
			Utility.waitForThread();
			
			//ProgressDialogHelper.dismissProgressDialog();

			Intent intent = new Intent(getApplicationContext(), About.class);
			intent.putExtra("about", response);
			startActivity(intent);

			login_req = true;

		}

	}

	public void onSuccessFinish(String response) {

		if (login_req) {
			CoreComponent.setUserinfo(new Gson().fromJson(response,
					UserInfo.class));

			editor.putBoolean("credentials", true);
			editor.putString("username", uname);
			editor.putString("password", pwd);
			editor.putString("contactname", CoreComponent.getUserinfo()
					.getContactname());
			editor.putString("accountname", CoreComponent.getUserinfo()
					.getAccountname());
			editor.commit();

			Intent intent = new Intent(getApplicationContext(), HomePage.class);
			startActivity(intent);
			handler.sendEmptyMessage(Constants.DISMISS_DIALOG);
			finish();
		} else{
			this.response = response;
			handler.sendEmptyMessage(Constants.DISMISS_DIALOG);
		}

		

	}

	public void onError(String status) {
		if (login_req) {
			handler.sendEmptyMessage(Constants.DISMISS_DIALOG);
			status = error;
			handler.sendEmptyMessage(Constants.TOAST);
		}
		else{
		this.response = status;
		handler.sendEmptyMessage(Constants.DISMISS_DIALOG);
		}
		
	}

	public HTTPRequest createRequest() {
		if (login_req)
			return CoreComponent.getRequest(Constants.LOGIN);
		else
			return CoreComponent.getRequest(Constants.ABOUT_URL);
	}

}
