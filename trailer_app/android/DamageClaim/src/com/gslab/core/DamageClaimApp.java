package com.gslab.core;

import java.util.ArrayList;
import java.util.HashMap;

import android.app.Application;

import com.gslab.damageclaim.HomePage;
import com.gslab.damageclaim.PreviouslyReportedDamagesInfo;
import com.gslab.damageclaim.ReportDamage;
import com.gslab.damageclaim.ReportNewDamage;

public class DamageClaimApp extends Application {

	public static String about_Response = null;
	public static ArrayList<String> sealed_labels = null, sealed_values = null;
	public static String report_damage_value_no = null;
	public static String report_damage_value_yes = null;
	public static ArrayList<String> id_own = null, id_rented = null;
	public static String closed_ticket_status_value = null;
	public static String open_ticket_status_value = null;

	public static HashMap<String, String> typevalues = null;
	public static HashMap<String, ArrayList<String>> hashmap = null;

	public static ArrayList<String> damage_caused_by = null;

	public static ArrayList<String> places_values = null;
	public static ArrayList<String> straps_values = null;
	public static ArrayList<String> plates_values = null;

	public static String trailer_type = null;
	public static String place = null;
	public static String plates = null;
	public static String straps = null;
	public static String sealed = null;

	public static HomePage homepage = null;
	public static PreviouslyReportedDamagesInfo previousdamages = null;
	public static ReportNewDamage reportnewdamage = null;
	public static ReportDamage reportdamage = null;
	
	public static boolean shouldErase = false;

}
