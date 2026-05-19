package com.yjkj.chainup.extra_service.fresco;

import android.content.Context;
import android.net.Uri;
import com.facebook.binaryresource.FileBinaryResource;
import com.facebook.cache.common.SimpleCacheKey;
import com.facebook.cache.disk.DiskCacheConfig;
import com.facebook.common.executors.UiThreadImmediateExecutorService;
import com.facebook.common.internal.Supplier;
import com.facebook.common.references.CloseableReference;
import com.facebook.common.util.UriUtil;
import com.facebook.datasource.DataSource;
import com.facebook.datasource.DataSubscriber;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.backends.okhttp3.OkHttpImagePipelineConfigFactory;
import com.facebook.imagepipeline.cache.MemoryCacheParams;
import com.facebook.imagepipeline.common.ImageDecodeOptions;
import com.facebook.imagepipeline.core.ImagePipeline;
import com.facebook.imagepipeline.core.ImagePipelineConfig;
import com.facebook.imagepipeline.image.CloseableImage;
import com.facebook.imagepipeline.listener.RequestListener;
import com.facebook.imagepipeline.listener.RequestLoggingListener;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import okhttp3.Interceptor;
import okhttp3.OkHttpClient;
import okhttp3.Response;

import java.io.*;
import java.util.HashSet;
import java.util.Set;

public class FrescoUtil {

    private static final String baseDirectoryName = "dk_dection";
    private static final String webpSupport = "image/webp,image/apng,image/*,*/*;q=0.8";

    private static final long maxCacheSize = 100 * 1024 * 1024;

    public static void initialize(Context context) {
        //Supporting the http2.0 protocol through OKHttp Client
        /*final OkHttpClient okHttpClient = new OkHttpClient.Builder().addInterceptor(new Interceptor(){
            @Override
            public Response intercept(Chain chain) throws IOException {
                //By adding accept, inform the server that we support webp format
                return chain.proceed(chain.request().newBuilder().addHeader("accept", webpSupport).build());
            }
        }).build();

        Set<RequestListener> listeners = new HashSet<>();
        listeners.add(new RequestLoggingListener());
        ImagePipelineConfig config = OkHttpImagePipelineConfigFactory
                .newBuilder(context, okHttpClient)
                //.setDownsampleEnabled(true)
                .setRequestListeners(listeners)
                .build();*/

        //Fresco.initialize(context);
      //  Fresco.initialize(context);
    }

    public static void setDiskCache(Context context) {
        ImagePipelineConfig.Builder imagePipelineConfigBuilder = ImagePipelineConfig.newBuilder(context);
        imagePipelineConfigBuilder.setMainDiskCacheConfig(DiskCacheConfig.newBuilder(context)
                .setBaseDirectoryPath(context.getExternalCacheDir())//Set the path of the Disk buffer
                .setBaseDirectoryName(baseDirectoryName)//Set the name of the Disk buffer folder
                .setMaxCacheSize(maxCacheSize)//Set the size of the Disk buffer
                .build());
    }

    public static void setMemoryCache(Context context) {
        ImagePipelineConfig.Builder imagePipelineConfigBuilder = ImagePipelineConfig.newBuilder(context);
        imagePipelineConfigBuilder.setBitmapMemoryCacheParamsSupplier(new Supplier<MemoryCacheParams>() {
            public MemoryCacheParams get() {
                int MAX_HEAP_SIZE = (int) Runtime.getRuntime().maxMemory();
                int MAX_MEMORY_CACHE_SIZE = MAX_HEAP_SIZE / 5;//Take one fifth of the maximum memory value of the phone as the maximum available memory

                MemoryCacheParams bitmapCacheParams = new MemoryCacheParams( //
                        //Maximum available memory in bytes
                        MAX_MEMORY_CACHE_SIZE,
                        //Maximum number of images allowed in memory
                        Integer.MAX_VALUE,
                        //The maximum amount of memory available in bytes for the total number of images in memory that are ready for cleaning but have not yet been deleted
                        MAX_MEMORY_CACHE_SIZE,
                        //Maximum number of images in memory that are ready to be cleared
                        Integer.MAX_VALUE,
                        //Maximum size of a single image in memory
                        Integer.MAX_VALUE);
                return bitmapCacheParams;
            }
        });
    }

    public static void loadImg(String filePath, SimpleDraweeView imageview) {
        Uri uri = new Uri.Builder()
                .scheme(UriUtil.LOCAL_FILE_SCHEME)
                .path(filePath)
                .build();
        imageview.setImageURI(uri);
    }

    /**
     *Asynchronous
     *
     * @param context
     * @param picUrl
     * @return
     */
    public static void getBitmap(Context context, String picUrl, DataSubscriber dataSubscriber) {
        Uri uri = Uri.parse(picUrl);
        ImageDecodeOptions decodeOptions = ImageDecodeOptions.newBuilder()
                .build();
        ImageRequest imageRequest = ImageRequestBuilder
                .newBuilderWithSource(uri)
                .setImageDecodeOptions(decodeOptions)
                .setAutoRotateEnabled(true)
                .setLowestPermittedRequestLevel(ImageRequest.RequestLevel.FULL_FETCH)
                .setProgressiveRenderingEnabled(false)
                .build();
        ImagePipeline imagePipeline = Fresco.getImagePipeline();
        DataSource<CloseableReference<CloseableImage>> dataSource = imagePipeline.fetchDecodedImage(imageRequest, context);
        dataSource.subscribe(dataSubscriber, UiThreadImmediateExecutorService.getInstance());
    }

    private static void download(Context context, String url) {

        ImageRequest request = ImageRequestBuilder.
                newBuilderWithSource(Uri.parse(url))
                .setAutoRotateEnabled(true)
                .setLowestPermittedRequestLevel(ImageRequest.RequestLevel.FULL_FETCH)
                .setProgressiveRenderingEnabled(false)
                .build();
        ImagePipeline imagePipeline = Fresco.getImagePipeline();
        imagePipeline.prefetchToDiskCache(request, context);
    }

    /**
     *Image copy
     *
     * @param imgUrl
     * @param newPath
     * @param fileName
     * @return
     */
    public static boolean copyPicFile(String imgUrl, String newPath, String fileName) {
        FileBinaryResource fileBinaryResource = (FileBinaryResource) Fresco.getImagePipelineFactory()
                .getMainFileCache().getResource(new SimpleCacheKey(imgUrl));
        if (fileBinaryResource == null) {
            return false;
        }
        File oldfile = fileBinaryResource.getFile();
        boolean isok = true;
        try {
            int bytesum = 0;
            int byteread = 0;
            if (oldfile.exists()) { //When the file exists
                InputStream inStream = new FileInputStream(oldfile); //Reading in the original file
                if (!new File(newPath).exists()) {
                    new File(newPath).mkdirs();
                }
                String myPath = newPath + File.separator + fileName;
                FileOutputStream fs = new FileOutputStream(myPath);
                byte[] buffer = new byte[1024];
                int length;
                while ((byteread = inStream.read(buffer)) != -1) {
                    bytesum += byteread; //Bytes File Size
                    fs.write(buffer, 0, byteread);
                }
                fs.flush();
                fs.close();
                inStream.close();
            } else {
                isok = false;
            }
        } catch (Exception e) {
            isok = false;
        }
        return isok;
    }
}
