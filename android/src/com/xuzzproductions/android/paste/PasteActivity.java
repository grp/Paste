package com.xuzzproductions.android.paste;

import android.os.*;
import android.app.*;
import android.view.*;
import android.graphics.*;
import android.widget.*;
import android.text.*;
import android.content.*;
import android.net.*;
import android.view.inputmethod.*;
import android.text.method.*;
import android.view.ViewGroup.*;
import android.text.style.*;
import android.util.*;
import java.util.*;
import java.io.*;
import org.apache.http.*;
import org.apache.http.client.*;
import org.apache.http.impl.client.*;
import org.apache.http.entity.*;
import org.apache.http.protocol.*;
import org.apache.http.client.methods.*;
import com.jakewharton.android.actionbarsherlock.*;

public class PasteActivity extends ActionBarSherlock.Activity
{
    private class PastieTask extends AsyncTask<Object, Void, String> {
        private ProgressDialog progress;
        private Activity activity;

        public PastieTask(Activity act) {
            super();
            activity = act;
        }
        
        @Override
        protected void onPreExecute() {
            progress = new ProgressDialog(activity);
            progress.setProgressStyle(ProgressDialog.STYLE_SPINNER);
            progress.setMessage("Submitting to Pastie...");
            progress.setCancelable(false);
            progress.setOwnerActivity(activity);
            progress.setIndeterminate(true);
            progress.show();
        }

        @Override
        protected String doInBackground(Object... params) {
            try {
                String text = (String) params[0];
                boolean priv = (Boolean) params[1];

                String boundary = "_xuzz_productions_paste";
               String body = "";

                Map<String, String> parameters = new HashMap<String, String>();
                parameters.put("paste[body]", text);
                parameters.put("paste[authorization]", "burger");
                parameters.put("paste[restricted]", priv ? "1" : "0");
                parameters.put("paste[parser_id]", "6");

                for (Map.Entry<String, String> entry : parameters.entrySet()) {
                    String key = entry.getKey();
                    String value = entry.getValue();
                    
                    body += "--" + boundary + "\r\n";
                    body += "Content-Disposition: form-data; name=\"" + key + "\"\r\n\r\n";
                    body += value + "\r\n";
                }
    
                body += "--" + boundary + "--\r\n";
    
                HttpClient client = new DefaultHttpClient();
                HttpContext context = new BasicHttpContext();
                HttpPost post = new HttpPost("http://xuzz.net/apps/paste.php"); //("http://pastie.org/pastes");
                post.setHeader("User-Agent", "Paste/Android");
                post.setHeader("Content-Type", "multipart/form-data; boundary=" + boundary);
                try { post.setEntity(new StringEntity(body)); } catch (UnsupportedEncodingException e) { return null; }
    
                HttpResponse response = client.execute(post, context);
    
                HttpEntity entity = response.getEntity();
                BufferedReader in = new BufferedReader(new InputStreamReader(entity.getContent()));
                StringBuffer sb = new StringBuffer("");
                String line = "";
                while ((line = in.readLine()) != null) {
                    sb.append(line + "\n");
                }
                in.close();
                return sb.toString();
    
                /*HttpUriRequest req = (HttpUriRequest) context.getAttribute(ExecutionContext.HTTP_REQUEST);
                HttpHost host = (HttpHost) context.getAttribute(ExecutionContext.HTTP_TARGET_HOST);
                String url = host.toURI() + req.getURI();
                return url;*/
            } catch (IOException e) {
                return null;
            }
        }

        @Override
        protected void onPostExecute(String result) {
            if (result == null) {
                Toast toast = Toast.makeText(activity, "Submission failed.", Toast.LENGTH_SHORT);
                toast.show();
            } else {
                Object clipboardManager = getSystemService(Context.CLIPBOARD_SERVICE);
                
                if (PasteActivity.hasModernClipboardManager()) {
                    android.content.ClipboardManager manager = (android.content.ClipboardManager) clipboardManager; 
                    ClipData.Item item = new ClipData.Item(Uri.parse(result));
                    ClipData clip = new ClipData(new ClipDescription("Pastie URL", new String[] { ClipDescription.MIMETYPE_TEXT_URILIST }), item);
                    manager.setPrimaryClip(clip);
                } else {
                    android.text.ClipboardManager manager = (android.text.ClipboardManager) clipboardManager;
                    manager.setText(result);
                }

                Toast toast = Toast.makeText(activity, "Pastie URL copied to clipboard.", Toast.LENGTH_SHORT);
                toast.show();
            }

            progress.dismiss();
            progress = null;
        }
    }

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

    static  boolean hasModernClipboardManager() {
        try {
            Class.forName("android.content.ClipboardManager", false, null);
            return true;
        } catch (ClassNotFoundException e) {
            return false;
        }
    }

    protected void updateTextFromClipboard() {
        Object clipboardManager = getSystemService(Context.CLIPBOARD_SERVICE);
        CharSequence text = null;

        if (clipboardManager == null) return;

        if (PasteActivity.hasModernClipboardManager()) {
            android.content.ClipboardManager manager = (android.content.ClipboardManager) clipboardManager; 
            ClipData clip = manager.getPrimaryClip();
            if (clip != null && clip.getItemCount() > 0)
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
                PastieTask task = new PastieTask(this);
                task.execute(textView.getText().toString(), true);
                return true;
            default:
                return false;
        }
    }
}

