package com.xuzzproductions.android.paste;

import android.os.*;
import android.app.*;
import android.view.*;
import android.graphics.*;
import android.widget.*;
import android.text.*;
import android.content.*;
import android.view.inputmethod.*;
import android.text.method.*;
import android.view.ViewGroup.*;
import android.text.style.*;
import android.util.*;
import com.jakewharton.android.actionbarsherlock.*;

public class PasteActivity extends ActionBarSherlock.Activity
{
    private static final String TAG = "PasteActivity";
    private EditText textView;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ActionBarSherlock sh = ActionBarSherlock.from(this);
        sh.with(savedInstanceState);
        sh.handleCustom(ActionBarForAndroidActionBar.Handler.class);
        sh.title("Paste");
        sh.menu(R.menu.menu);
        sh.useLogo(false);
        sh.layout(R.layout.paste);
        sh.attach();
        
        textView = (EditText) this.findViewById(R.id.main_text);
    }

    protected boolean hasModernClipboardManager() {
        try {
            Class.forName("android.content.ClipboardManager", false, null);
            Log.i(TAG, "Using modern clipboard.");
            return true;
        } catch (ClassNotFoundException e) {
            Log.i(TAG, "Using ancient clipboard.");
            return false;
        }
    }

    protected void updateTextFromClipboard() {
        Object clipboardManager = getSystemService(Context.CLIPBOARD_SERVICE);
        CharSequence text = null;

        if (hasModernClipboardManager()) {
            android.content.ClipboardManager manager = (android.content.ClipboardManager) clipboardManager; 
            ClipData clip = manager.getPrimaryClip();
            if (clip.getItemCount() > 0)
                text = clip.getItemAt(0).getText();
        } else {
            android.text.ClipboardManager manager = (android.text.ClipboardManager) clipboardManager;
            text = manager.getText();
        }

        textView.setText("");
        if (text != null) textView.append(text);
    }

    @Override
    public void onResume() {
        super.onResume();
        updateTextFromClipboard();
        textView.requestFocus();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.menu_clear:
                textView.setText("");
                return true;
            case R.id.menu_submit:
                Toast.makeText(this, "Submitting...", Toast.LENGTH_SHORT).show();
                return true;
            default:
                return false;
        }
    }
}
