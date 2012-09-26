package com.gslab.damageclaim;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;

import com.gslab.R;
import com.gslab.interfaces.Constants;

public class SplashActivity extends Activity {
	
	  @Override
	    protected void onCreate(Bundle savedInstanceState)
	    {
	        super.onCreate(savedInstanceState);
	        setContentView(R.layout.splash);
	        
	        
	        
	        new Handler().postDelayed(new Runnable()
            {
                public void run()
                {                    
                    SplashActivity.this.finish();                    
                    Intent mainIntent = new Intent(SplashActivity.this, Login.class);
                    SplashActivity.this.startActivity(mainIntent);
                }
            }, Constants.SPLASH_DISPLAY_LENGTH);
	        
	        
	        
	    }
	  
	  

}
