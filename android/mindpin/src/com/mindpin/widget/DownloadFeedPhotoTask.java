package com.mindpin.widget;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import org.apache.commons.io.FileUtils;
import com.mindpin.base.utils.FileDirs;
import com.mindpin.database.Feed;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.widget.ImageView;

public class DownloadFeedPhotoTask extends AsyncTask<String, Integer, Bitmap>{
	private ImageView view;
	private Feed feed;
	private String photo_url;

	public DownloadFeedPhotoTask(Feed feed,String photo_url,ImageView view) {
		this.view = view;
		this.feed = feed;
		this.photo_url = photo_url;
	}

	protected Bitmap doInBackground(String... arg0) {
		return get_bitmap();
	}

	private Bitmap get_bitmap() {
		Bitmap mBitmap = null;
		try {
			File cache_file = get_cache_file();
			if(cache_file != null && cache_file.exists()){
				FileInputStream is = new FileInputStream(cache_file);
				mBitmap = BitmapFactory.decodeStream(is);
			}else{
				
				URL url = new URL(photo_url);
				HttpURLConnection conn = (HttpURLConnection) url.openConnection();
				InputStream is = conn.getInputStream();
				
				if(cache_file != null){
					FileUtils.copyInputStreamToFile(is, cache_file);
					FileInputStream fis = new FileInputStream(get_cache_file());
					mBitmap = BitmapFactory.decodeStream(fis);
				}else{
					mBitmap = BitmapFactory.decodeStream(is);
				}
			}
		} catch (MalformedURLException e) {
			e.printStackTrace();
			return mBitmap;
		} catch (IOException e) {
			e.printStackTrace();
			return mBitmap;
		}
		return mBitmap;
	}

	@Override
	protected void onPostExecute(Bitmap result) {
		super.onPostExecute(result);
		view.setImageBitmap(result);
	}
	
	private File get_cache_file(){
		try {
			URI uri = new URI(photo_url);
			String path = uri.getPath();
			String[] arr = path.split("/");
			String file_name = arr[4] + "_" + arr[5];
			File file = FileDirs.feed_data_dir(feed);
			File cache_file = new File(file,file_name);
		return cache_file;
		} catch (URISyntaxException e) {
			e.printStackTrace();
			return null;
		}
	}
}
