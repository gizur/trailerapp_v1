package com.gslab.interfaces;

import com.gslab.networking.HTTPRequest;

public interface NetworkListener {

	public void onSuccessFinish(String response);

	public void onError(String status);

	public HTTPRequest createRequest();

}
