package com.atomforce.tieba;

import android.app.Activity;
import android.os.Bundle;
import android.widget.Toast;
import androidx.annotation.Nullable;

public class TestActivity extends Activity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        Toast.makeText(this, "Test only", Toast.LENGTH_SHORT).show();
        super.onCreate(savedInstanceState);
    }
}
