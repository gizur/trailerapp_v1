package com.gslab.core;

import java.util.ArrayList;
import java.util.HashMap;

import android.app.Application;

public class DamageClaimApp extends Application {

	public static String about_Response = null;
	public static ArrayList<String> sealed_labels = null, sealed_values = null;
	public static String report_damage_value_no = null;
	public static String report_damage_value_yes = null;
	public static ArrayList<String> id_values = null, id_names = null;
	public static String closed_ticket_status_value = null;
	public static String open_ticket_status_value = null;

	public static HashMap<String, String> typevalues = null;
	public static HashMap<String, ArrayList<String>> hashmap = null;

	public static ArrayList<String> damage_caused_by = null;
	
	public static ArrayList<String> places_values = null;
	public static ArrayList<String> straps_values = null;
	public static ArrayList<String> plates_values = null;
}
