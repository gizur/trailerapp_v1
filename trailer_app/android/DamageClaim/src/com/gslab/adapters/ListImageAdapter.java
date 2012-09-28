package com.gslab.adapters;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

import com.gslab.R.id;
import com.gslab.R.layout;

public class ListImageAdapter extends BaseAdapter {

	ArrayList<Bitmap> imagelist; // Contains the thumbnail version of the
									// original image in bitmap form
	ImageView imageview;
	LayoutInflater inflater;
	Activity activity;

	public ListImageAdapter(Activity activity, ArrayList<Bitmap> imagelist) {
		inflater = (LayoutInflater) activity
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.imagelist = imagelist;
		this.activity = activity;
	}

	public int getCount() {
		return imagelist.size();
	}

	public Bitmap getItem(int position) {

		return imagelist.get(position);
	}

	public long getItemId(int position) {

		return position;
	}

	public View getView(int position, View convertView, ViewGroup parent) {

		if (convertView == null) {
			convertView = inflater.inflate(layout.listimageadapterlayout, null);
		}
		imageview = (ImageView) convertView
				.findViewById(id.listimage_adapter_image);
		imageview.setImageBitmap(imagelist.get(position));

		return convertView;

	}

}
