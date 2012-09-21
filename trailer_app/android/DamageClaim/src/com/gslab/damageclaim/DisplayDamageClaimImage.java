package com.gslab.damageclaim;

import android.app.Activity;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.widget.ImageView;

import com.gslab.R.id;
import com.gslab.R.layout;

public class DisplayDamageClaimImage extends Activity {
	
	ImageView imageview;
	Bitmap bitmap;
	Uri uri;
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(layout.displaydamageimage);
		
		uri = (Uri) getIntent().getExtras().getParcelable("uri");
		
		imageview = (ImageView) findViewById(id.damage_claim_imageview_image);
		imageview.setImageURI(uri);
		
	}

}
