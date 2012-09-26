package com.gslab.adapters;

import java.util.ArrayList;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.gslab.R.id;
import com.gslab.R.layout;
import com.gslab.helpers.DamageInfo;

public class DamageListAdapter extends BaseAdapter {

	LayoutInflater inflater;
	TextView what_is_damaged, location_of_damage;
	ArrayList<DamageInfo> damageInfoList;
	Activity activity;
	
	public DamageListAdapter(Activity activity, ArrayList<DamageInfo> damageInfoList)
	{
		this.activity = activity;
		this.damageInfoList = damageInfoList;
		inflater = (LayoutInflater) activity.getSystemService(Activity.LAYOUT_INFLATER_SERVICE);
	}
	
	
	public int getCount() {
		return damageInfoList.size();
		
	}

	
	public DamageInfo getItem(int position) {
		
		return damageInfoList.get(position);
	}

	
	public long getItemId(int position) {
		
		return position;
	}

	
	public View getView(int position, View convertView, ViewGroup parent) {
		
		if(convertView == null)
		{
			convertView = inflater.inflate(layout.damage_list_adapter_layout, null);
			what_is_damaged = (TextView) convertView.findViewById(id.damage_list_adapter_what_is_damaged);
			location_of_damage = (TextView) convertView.findViewById(id.damage_list_adapter_location_of_damaged);
		}
		
		what_is_damaged.setText(damageInfoList.get(position).getWhatIsDamaged());
		location_of_damage.setText(damageInfoList.get(position).getLocationOfDamage());
		
		return convertView;
		
	}

	
	
}
