package com.gslab.helpers;

import java.util.ArrayList;

import android.net.Uri;
import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;



public class DamageInfo implements Parcelable {

	private String what_is_damaged;
	private String location_of_damage;
	private ArrayList<Uri> imagepaths;
	
	public DamageInfo()
	{
		this.what_is_damaged = null;
				this.location_of_damage = null;
		this.imagepaths = null;
	}
	
	public void setType(String what_is_damaged)
	{
		this.what_is_damaged = what_is_damaged;
	}
	
	public void setLocation(String location_of_damage)
	{
		this.location_of_damage = location_of_damage;
	}
	
	public DamageInfo(String what_is_damaged, String location_of_damage, ArrayList<Uri> uri){
		this.what_is_damaged = what_is_damaged;
		this.location_of_damage = location_of_damage;		
		this.imagepaths = uri;
	}
	
	public DamageInfo(String what_is_damaged, String location_of_damage){
		this.what_is_damaged = what_is_damaged;
		this.location_of_damage = location_of_damage;		
		
	}
	
	
	public DamageInfo(Parcel source) {
		super();
		this.what_is_damaged = source.readString();
		this.location_of_damage = source.readString();
		if(this.imagepaths == null){
			imagepaths = new ArrayList<Uri>();
		}
		source.readTypedList(imagepaths, Uri.CREATOR);
		Log.i("Imagepaths", ""+imagepaths.size());
	}

	public String getWhatIsDamaged()
	{
		return what_is_damaged;
	}
	
	public String getLocationOfDamage()
	{
		return location_of_damage;
	}
	
	public ArrayList<Uri> getImagePaths()
	{
		return imagepaths;
	}
	
	
	public void setImagePaths(ArrayList<Uri> imagepaths)
	{
		this.imagepaths = imagepaths;
	}
	

	@Override
	public int describeContents() {
		
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		
		dest.writeString(what_is_damaged);
		dest.writeString(location_of_damage);
		dest.writeTypedList(imagepaths);
		
	}
	
	
	
	public static final Parcelable.Creator<DamageInfo> CREATOR = new Creator<DamageInfo>() {
		
		@Override
		public DamageInfo[] newArray(int size) {
			
			Log.i(getClass().getSimpleName(), "Came in newArray, parcelable!");
			return new DamageInfo[size];
		}
		
		@Override
		public DamageInfo createFromParcel(Parcel source) {
			
			return new DamageInfo(source);
		}
	};
	
	
	
}
