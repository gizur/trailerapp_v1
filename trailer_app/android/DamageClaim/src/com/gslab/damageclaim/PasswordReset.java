package com.gslab.damageclaim;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;

import com.gslab.R.id;
import com.gslab.R.layout;
import com.gslab.R.string;
import com.gslab.core.CoreComponent;
import com.gslab.interfaces.Constants;
import com.gslab.interfaces.NetworkListener;
import com.gslab.networking.HTTPRequest;
import com.gslab.uihelpers.ProgressDialogHelper;
import com.gslab.uihelpers.ToastUI;
import com.gslab.utils.NetworkCallRequirements;
import com.gslab.utils.Utility;

public class PasswordReset extends Activity implements OnClickListener,
		NetworkListener {

	private EditText oldp, newp, confirmnew;
	private Button submit;
	private Activity activity;

	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(layout.reset_password);

		activity = this;

		oldp = (EditText) findViewById(id.reset_password_edittext_oldpassword);
		newp = (EditText) findViewById(id.reset_password_edittext_newpassword);
		confirmnew = (EditText) findViewById(id.reset_password_edittext_confirmnewpassword);

		submit = (Button) findViewById(id.resetpassword_submit);
		submit.setOnClickListener(this);

	}

	private Handler handler = new Handler() {
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case Constants.DISMISS_DIALOG:
				ProgressDialogHelper.dismissProgressDialog();
				break;

			case Constants.TOAST:
				Utility.showErrorDialog(activity);

			}
		}
	};

	public void onClick(View v) {

		if (v == submit) {
			if (performChecks()) {

				ProgressDialogHelper.showProgressDialog(this, "",
						getString(string.loading));
				HTTPRequest request = createRequest();
				request.addParam("newpassword=", newp.getText().toString());
				request.addBodyText("newpassword=" + newp.getText().toString());
				CoreComponent.processRequest(Constants.PUT,
						Constants.AUTHENTICATE, this, request);
				Utility.waitForThread();

			}
		}

	}

	private boolean performChecks() {
		if (oldp.getText().toString().equalsIgnoreCase("")
				|| newp.getText().toString().equalsIgnoreCase("")
				|| confirmnew.getText().toString().equalsIgnoreCase("")) {
			ToastUI.showToast(getApplicationContext(),
					"password field cannot be blank");
			return false;
		}
		if (oldp.getText().toString().equals(CoreComponent.getPassword())) {
			if (newp.getText().toString()
					.equals(confirmnew.getText().toString()))
				return true;
			else {
				ToastUI.showToast(getApplicationContext(),
						"new password not matching");
				return false;
			}
		} else {
			ToastUI.showToast(getApplicationContext(),
					"Old password is incorrect");
			return false;
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
		}

		return true;
	}

	public void onSuccessFinish(String response) {

		Log.i(getClass().getSimpleName(), "success");
		handler.sendEmptyMessage(Constants.DISMISS_DIALOG);
		finish();
	}

	public void onError(String status) {
		Log.i(getClass().getSimpleName(), "error");
		handler.sendEmptyMessage(Constants.DISMISS_DIALOG);
		handler.sendEmptyMessage(Constants.TOAST);
	}

	public HTTPRequest createRequest() {
		HTTPRequest request = CoreComponent.getRequest(Constants.CHANGE_PWD);
		request.addBodyText("newpassword=" + newp.getText().toString());
		request.addParam("newpassword=", newp.getText().toString());
		return request;

	}

}
