package com.gslab.adapters;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

import com.gslab.R.id;
import com.gslab.R.layout;
import com.gslab.damageclaim.ReportNewDamage;

public class ListImageAdapter extends BaseAdapter {

	ArrayList<Bitmap> imagelist;						//Contains the thumbnail version of the original image in bitmap form
	ImageView imageview;
	LayoutInflater inflater;
	ReportNewDamage reportnewdamage;
	
	public ListImageAdapter(ReportNewDamage reportnewdamage, ArrayList<Bitmap> imagelist)
	{
		inflater = (LayoutInflater) reportnewdamage
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.imagelist = imagelist;
		this.reportnewdamage = reportnewdamage;
	}
	
	@Override
	public int getCount() {
		return imagelist.size();	
	}

	@Override
	public Bitmap getItem(int position) {
		
		return imagelist.get(position);
	}

	@Override
	public long getItemId(int position) {
		
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		
		
		if(convertView == null)
		{
			convertView = inflater.inflate(layout.listimageadapterlayout, null);
		}
		imageview = (ImageView) convertView.findViewById(id.listimage_adapter_image);
		imageview.setImageBitmap(imagelist.get(position));
		
		return convertView;
		
	}

}
