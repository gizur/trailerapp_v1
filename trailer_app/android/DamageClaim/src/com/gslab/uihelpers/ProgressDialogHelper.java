package com.gslab.uihelpers;

import android.app.ProgressDialog;
import android.content.Context;
import android.os.Looper;

public class ProgressDialogHelper {
	
	private static ProgressDialog pd;
	
	public static void showProgressDialog(final Context context, final String title, final String message)
	{
		new Thread(){
		public void run(){
			Looper.prepare();
			dismissProgressDialog();
			pd = ProgressDialog.show(context, title, message);
			Looper.loop();
		}
		}.start();
	}
	
	public static void dismissProgressDialog()
	{
		if(pd != null && pd.isShowing())
			pd.dismiss();
	}

}
