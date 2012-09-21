package com.gslab.utils;

import android.view.View;
import android.view.ViewGroup;
import android.widget.ListAdapter;
import android.widget.ListView;

import com.gslab.core.CoreComponent;

public class Utility {
    public static void setListViewHeightBasedOnChildren(ListView listView) {
        ListAdapter listAdapter = listView.getAdapter(); 
        if (listAdapter == null) {
            // pre-condition
            return;
        }

        int totalHeight = 0;
        for (int i = 0; i < listAdapter.getCount(); i++) {
            View listItem = listAdapter.getView(i, null, listView);
            listItem.measure(0, 0);
            totalHeight += listItem.getMeasuredHeight();
        }

        ViewGroup.LayoutParams params = listView.getLayoutParams();
        params.height = totalHeight + (listView.getDividerHeight() * (listAdapter.getCount() - 1));
        listView.setLayoutParams(params);
    }
    
    public static String getParsedString(String temp){
    	if(temp.contains(":"))
    	{
    		temp = temp.substring(temp.indexOf(":") + 2, temp.length());    		
    	}
    	return temp;
    }
    
    public static void waitForThread()
    {
    	try {
    		if(CoreComponent.getThread().isAlive())
			CoreComponent.getThread().join();
		} catch (InterruptedException e) {

			e.printStackTrace();
		}
    }
}

