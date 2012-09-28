package com.gslab.uihelpers;

import android.content.Context;
import android.os.Looper;
import android.widget.Toast;

public class ToastUI {

	public static void showToast(final Context context, final String message) {
		new Thread() {
			public void run() {
				Looper.prepare();
				Toast.makeText(context, message, Toast.LENGTH_LONG).show();
				Looper.loop();
			}
		}.start();
	}

}
