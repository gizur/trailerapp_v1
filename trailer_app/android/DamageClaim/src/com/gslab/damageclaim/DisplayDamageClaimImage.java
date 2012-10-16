package com.gslab.damageclaim;

import android.app.Activity;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;

import com.gslab.R.id;
import com.gslab.R.layout;
import com.gslab.uihelpers.TouchImageView;
import com.gslab.utils.Utility;

public class DisplayDamageClaimImage extends Activity {

	TouchImageView imageview;
	Bitmap bitmap;
	Uri uri;

	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(layout.displaydamageimage);

		imageview = (TouchImageView) findViewById(id.damage_claim_imageview_image);
		

		if (getIntent().getBooleanExtra("report_damage", true)) {
			uri = (Uri) getIntent().getExtras().getParcelable("uri");
			imageview.setImageURI(uri);
		} else {
			imageview.setImageBitmap(Utility.BITMAP);
		}

	}

}
