package com.gslab.damageclaim;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.gslab.R.id;
import com.gslab.R.layout;
import com.gslab.helpers.DamageInfo;

public class PreviouslyReportedDamagesInfo extends Activity {
	
	private Button toremoveAddNewImages, done;	
	private DamageInfo info;
	private TextView type, position;
	
	public void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);
		setContentView(layout.reportnewdamage);
		
		toremoveAddNewImages = (Button) findViewById(id.reportnewdamage_button_damageimages);
		done = (Button) findViewById(id.reportnewdamage_button_done);
		
		
		toremoveAddNewImages.setVisibility(Button.GONE);
		done.setVisibility(LinearLayout.GONE);
		
		info = getIntent().getParcelableExtra("previous_data");
		
		type = (TextView) findViewById(id.reportnewdamage_textview_type);
		type.setCompoundDrawables(null, null, null, null);
		position = (TextView) findViewById(id.reportnewdamage_textview_position);
		position.setCompoundDrawables(null, null, null, null);
		
		type.setText(type.getText() + " " + info.getWhatIsDamaged());
		position.setText(position.getText() + " " + info.getLocationOfDamage());
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		
		menu.add(Menu.NONE, 1, Menu.NONE, "Logout");
		
		return super.onCreateOptionsMenu(menu);
	}
	
	

}
