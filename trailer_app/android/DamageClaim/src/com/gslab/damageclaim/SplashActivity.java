package com.gslab.damageclaim;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.util.Log;

import com.gslab.R;
import com.gslab.core.DamageClaimApp;
import com.gslab.interfaces.Constants;
import com.gslab.utils.NetworkCallRequirements;
import com.gslab.utils.URLList;

public class SplashActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.splash);

		DamageClaimApp.about_Response = null;
		DamageClaimApp.sealed_labels = null;
		DamageClaimApp.sealed_values = null;
		DamageClaimApp.report_damage_value_no = null;
		DamageClaimApp.report_damage_value_yes = null;
		DamageClaimApp.id_own = null;
		DamageClaimApp.id_rented = null;
		DamageClaimApp.closed_ticket_status_value = null;
		DamageClaimApp.open_ticket_status_value = null;

		DamageClaimApp.typevalues = null;
		DamageClaimApp.hashmap = null;

		DamageClaimApp.damage_caused_by = null;

		DamageClaimApp.places_values = null;
		DamageClaimApp.straps_values = null;
		DamageClaimApp.plates_values = null;

		new Handler().postDelayed(new Runnable() {
			public void run() {
				SplashActivity.this.finish();
				Intent mainIntent = new Intent(SplashActivity.this, Login.class);
				SplashActivity.this.startActivity(mainIntent);
			}
		}, Constants.SPLASH_DISPLAY_LENGTH);

		try {
			Uri uri = getIntent().getData();
			if (uri != null) {

				SharedPreferences prefs = PreferenceManager
						.getDefaultSharedPreferences(getApplicationContext());
				SharedPreferences.Editor editor = prefs.edit();
				editor.putBoolean("credentials", false);
				editor.commit();

				Log.i(getClass().getSimpleName(), "gizur cloud api key : "
						+ uri.getQueryParameter("GIZURCLOUD_API_KEY").trim());
				Log.i(getClass().getSimpleName(), "gizur cloud secret key : "
						+ uri.getQueryParameter("GIZURCLOUD_SECRET_KEY").trim());

				if (uri.getQueryParameter("GIZURCLOUD_API_KEY") != null) {
					NetworkCallRequirements.setGIZUR_API_KEY_VALUE(uri
							.getQueryParameter("GIZURCLOUD_API_KEY").trim());
					Log.i(getClass().getSimpleName(),
							"Got the gizur cloud api key : "
									+ uri.getQueryParameter(
											"GIZURCLOUD_API_KEY").trim());
				}
				if (uri.getQueryParameter("GIZURCLOUD_SECRET_KEY") != null) {
					Log.i(getClass().getSimpleName(),
							"Got the gizur cloud secret key : "
									+ uri.getQueryParameter(
											"GIZURCLOUD_SECRET_KEY").trim());
					NetworkCallRequirements.setGIZUR_CLOUD_SECRET_KEY(uri
							.getQueryParameter("GIZURCLOUD_SECRET_KEY").trim());

				}
				if (uri.getQueryParameter("GIZURCLOUD_API_URL") != null) {
					URLList.setPARENT(uri.getQueryParameter(
							"GIZURCLOUD_API_URL").trim());
					Log.i(getClass().getSimpleName(),
							"Got the gizur cloud api url : "
									+ uri.getQueryParameter(
											"GIZURCLOUD_API_URL").trim());
					Log.i(getClass().getSimpleName(), "Parent value set : --"
							+ URLList.getURL(Constants.PARENT) + "--");
				} else {
					URLList.setPARENT("https://api.gizur.com/api/index.php/api");
				}
				if (uri.getQueryParameter("GIZURCLOUD_HTTP_SCHEME") != null
						&& uri.getQueryParameter("GIZURCLOUD_API_URL") != null) {
					URLList.setPARENT(uri
							.getQueryParameter("GIZURCLOUD_HTTP_SCHEME")
							+ "://" + URLList.getURL(Constants.PARENT));
				}
			}
		} catch (Exception ex) {
			Log.i(" URL exception ", ex.getMessage() + ", "
					+ ex.getClass().getSimpleName());
		}

	}

}
