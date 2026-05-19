package com.yjkj.chainup.new_version.activity.asset;

import android.Manifest;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;

import com.bilibili.boxing.Boxing;
import com.bilibili.boxing.model.config.BoxingConfig;
import com.bilibili.boxing.model.entity.BaseMedia;
import com.bilibili.boxing_impl.ui.BoxingActivity;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.ChecksumException;
import com.google.zxing.DecodeHintType;
import com.google.zxing.FormatException;
import com.google.zxing.NotFoundException;
import com.google.zxing.RGBLuminanceSource;
import com.google.zxing.Result;
import com.google.zxing.ResultPoint;
import com.google.zxing.client.android.DecodeHintManager;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.qrcode.QRCodeReader;
import com.jaeger.library.StatusBarUtil;
import com.tbruyelle.rxpermissions2.Permission;
import com.tbruyelle.rxpermissions2.RxPermissions;
import com.yjkj.chainup.R;
import com.yjkj.chainup.base.NBaseActivity;
import com.yjkj.chainup.db.constant.ParamConstant;
import com.yjkj.chainup.db.constant.RoutePath;
import com.yjkj.chainup.db.constant.ScanIntentEnum;
import com.yjkj.chainup.extra_service.arouter.ArouterUtil;
import com.yjkj.chainup.manager.LanguageUtil;
import com.yjkj.chainup.net.HttpClient;
import com.yjkj.chainup.net.api.HttpResult;
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver;
import com.yjkj.chainup.new_version.bean.QRInfo;
import com.yjkj.chainup.new_version.dialog.DialogUtil;
import com.yjkj.chainup.util.ImageTools;
import com.yjkj.chainup.util.QRCodeUtil;
import com.yjkj.chainup.util.QRCodeUtils;
import com.yjkj.chainup.util.ToastUtils;
import com.yjkj.chainup.wedegit.ChainHeaderView;
import com.yjkj.chainup.wedegit.ViewfinderViewV2;
import com.yjkj.chainup.zxing.camera.CameraManager;

import org.jetbrains.annotations.Nullable;
import org.json.JSONObject;

import java.io.IOException;
import java.util.Collection;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import io.reactivex.Observer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;
import io.reactivex.observers.DisposableObserver;
import io.reactivex.schedulers.Schedulers;

/**
 * @Author lianshangljl
 * @Date 2023/11/16-5:28 PM
 * @Email buptjinlong@163.com
 * @description
 */
public class CaptureActivity extends NBaseActivity implements SurfaceHolder.Callback {
    public static final String SCAN_INTENT = "SCAN_INTENT";
    private int scanIntent;
    private static final String TAG = CaptureActivity.class.getSimpleName();
    public static final String SCAN_RESULT = "SCAN_RESULT";

    private CameraManager cameraManager;
    private CaptureActivityHandler handler;
    private Result savedResultToShow;
    private ViewfinderViewV2 viewfinderView;
    private boolean hasSurface;
    private IntentSource source;
    private Collection<BarcodeFormat> decodeFormats;
    private Map<DecodeHintType, ?> decodeHints;
    private String characterSet;
    private InactivityTimer inactivityTimer;
    private TextView tvAlbum;

    private boolean hasFlashLight = false;
    private boolean flashStatus;
    private ImageTools imageTool;
    ViewfinderViewV2 getViewfinderView() {
        return viewfinderView;
    }

    public Handler getHandler() {
        return handler;
    }

    CameraManager getCameraManager() {
        return cameraManager;
    }

    private int getCurrentOrientation() {
        int rotation = getWindowManager().getDefaultDisplay().getRotation();
        switch (rotation) {
            case Surface.ROTATION_0:
            case Surface.ROTATION_270:
                return ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
            default:
                return ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT;//reverse-mounted cameras on devices like the Nexus 5X
        }
    }


    @Override
    public void onInit(@Nullable Bundle savedInstanceState) {
        super.onInit(savedInstanceState);

        getLayoutView().setFitsSystemWindows(false);
        StatusBarUtil.setTranslucentForImageViewInFragment(this,0, findViewById(R.id.headerView));
        StatusBarUtil.setDarkMode(this);

        Intent intent = getIntent();
        scanIntent = intent.getIntExtra(SCAN_INTENT,ScanIntentEnum.LOGIN.getValue());

        if(ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED){
            //No permission
            new RxPermissions(this)
                    .request(Manifest.permission.CAMERA)
                    .subscribe(aBoolean -> {
                        if(!aBoolean){
                            finish();
                        }else{
                            recreate();
                        }
                    });

        }
        tvAlbum = findViewById(R.id.btn_add_pic);
        tvAlbum.setText(LanguageUtil.getString(this,"scan_text_album"));

        hasSurface = false;
        inactivityTimer = new InactivityTimer(this);
        imageTool = new ImageTools(this);
        hasFlashLight = getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH);

        ImageView back = findViewById(R.id.ic_back);
        back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });
    }

    @Override
    public boolean onSupportNavigateUp() {
        onBackPressed();
        return true;
    }

    @Override
    public void finish() {
        super.finish();
    }

    @Override
    protected void onResume() {
        super.onResume();

        // CameraManager must be initialized here, not in onCreate(). This is necessary because we don't
        // want to open the camera driver and measure the screen size if we're going to show the help on
        // first launch. That led to bugs where the scanning rectangle was the wrong size and partially
        // off screen.
        cameraManager = new CameraManager(getApplication());

        viewfinderView = findViewById(R.id.viewfinder_view);
        viewfinderView.setCameraManager(cameraManager);

        handler = null;
        resetStatusView();

        SurfaceView surfaceView = findViewById(R.id.preview_view);
        SurfaceHolder surfaceHolder = surfaceView.getHolder();
        if (hasSurface) {
            // The activity was paused but not stopped, so the surface still exists. Therefore
            // surfaceCreated() won't be called, so init the camera here.
            initCamera(surfaceHolder);
        } else {
            // Install the callback and wait for surfaceCreated() to init the camera.
            surfaceHolder.addCallback(this);
        }

        inactivityTimer.onResume();

        Intent intent = getIntent();

        source = IntentSource.NONE;
        decodeFormats = null;
        characterSet = null;

        if (intent != null) {

            String action = intent.getAction();

            if (Intents.Scan.ACTION.equals(action)) {

                // Scan the formats the intent requested, and return the result to the calling activity.
                source = IntentSource.NATIVE_APP_INTENT;
                decodeFormats = DecodeFormatManager.parseDecodeFormats(intent);
                decodeHints = DecodeHintManager.parseDecodeHints(intent);

                if (intent.hasExtra(Intents.Scan.WIDTH) && intent.hasExtra(Intents.Scan.HEIGHT)) {
                    int width = intent.getIntExtra(Intents.Scan.WIDTH, 0);
                    int height = intent.getIntExtra(Intents.Scan.HEIGHT, 0);
                    if (width > 0 && height > 0) {
                        cameraManager.setManualFramingRect(width, height);
                    }
                }
            }

            characterSet = intent.getStringExtra(Intents.Scan.CHARACTER_SET);

        }
    }

    @Override
    protected void onPause() {

        if (handler != null) {
            handler.quitSynchronously();
            handler = null;
        }
        inactivityTimer.onPause();
        cameraManager.closeDriver();
        if (!hasSurface) {
            SurfaceView surfaceView = findViewById(R.id.preview_view);
            SurfaceHolder surfaceHolder = surfaceView.getHolder();
            surfaceHolder.removeCallback(this);
        }

        // Close scanner when going to background

//        finish();

        super.onPause();
    }

    @Override
    public void onDestroy() {
        inactivityTimer.shutdown();
        super.onDestroy();
    }


    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        switch (keyCode) {
            case KeyEvent.KEYCODE_BACK:
                setResult(RESULT_CANCELED);
                finish();
                break;
            case KeyEvent.KEYCODE_FOCUS:
            case KeyEvent.KEYCODE_CAMERA:
                // Handle these events so they don't launch the Camera app
                return true;
            // Use volume up/down to turn on light
            case KeyEvent.KEYCODE_VOLUME_DOWN:
                cameraManager.setTorch(false);
                return true;
            case KeyEvent.KEYCODE_VOLUME_UP:
                cameraManager.setTorch(true);
                return true;
        }
        return super.onKeyDown(keyCode, event);
    }


    @Override
    public void surfaceCreated(SurfaceHolder surfaceHolder) {
        if (surfaceHolder == null) {
            
        }
        if (!hasSurface) {
            hasSurface = true;
            initCamera(surfaceHolder);
        }
    }

    @Override
    public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2) {

    }

    @Override
    public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
        hasSurface = false;
    }

    @Override
    public int setContentView() {
        return R.layout.activity_scan;
    }


    /**
     * A valid barcode has been found, so give an indication of success and show the results.
     *
     * @param rawResult The contents of the barcode.
     * @param barcode   A greyscale bitmap of the camera data which was decoded.
     */
    public void handleDecode(Result rawResult, Bitmap barcode) {
        inactivityTimer.onActivity();
        boolean fromLiveScan = barcode != null;
        if (fromLiveScan) {
            // Then not from history, so beep/vibrate and we have an image to draw on
            drawResultPoints(barcode, rawResult);
        }

        handleDecodeExternally(rawResult);
    }

    /**
     * Superimpose a line for 1D or dots for 2D to highlight the key features of the barcode.
     *
     * @param barcode   A bitmap of the captured image.
     * @param rawResult The decoded results which contains the points to draw.
     */
    private void drawResultPoints(Bitmap barcode, Result rawResult) {
        ResultPoint[] points = rawResult.getResultPoints();
        if (points != null && points.length > 0) {
            Canvas canvas = new Canvas(barcode);
            Paint paint = new Paint();
            paint.setColor(ContextCompat.getColor(this, R.color.main_blue));
            if (points.length == 2) {
                paint.setStrokeWidth(4.0f);
                drawLine(canvas, paint, points[0], points[1]);
            } else if (points.length == 4 &&
                    (rawResult.getBarcodeFormat() == BarcodeFormat.UPC_A ||
                            rawResult.getBarcodeFormat() == BarcodeFormat.EAN_13)) {
                // Hacky special case -- draw two lines, for the barcode and metadata
                drawLine(canvas, paint, points[0], points[1]);
                drawLine(canvas, paint, points[2], points[3]);
            } else {
                paint.setStrokeWidth(10.0f);
                for (ResultPoint point : points) {
                    canvas.drawPoint(point.getX(), point.getY(), paint);
                }
            }
        }
    }

    private static void drawLine(Canvas canvas, Paint paint, ResultPoint a, ResultPoint b) {
        canvas.drawLine(a.getX(), a.getY(), b.getX(), b.getY(), paint);
    }

    private void handleDecodeExternally(Result rawResult) {
        if(scanIntent==ScanIntentEnum.LOGIN.getValue()){
            getIPInfo(rawResult.toString());
        } else {
            Intent resultIntent = new Intent();
            resultIntent.putExtra(SCAN_RESULT,rawResult.toString());
            setResult(RESULT_OK,resultIntent);
            finish();
        }
    }

    /**
     * get ip address by qrcode and check qrcode is right?
     */
    private void getIPInfo(String qrcode) {
        if("".equals(qrcode)) {
            finish();
            return;
        }
        HttpClient.Companion.getInstance().getPCLoginInfo(qrcode)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Observer<HttpResult<QRInfo>>() {
                    @Override
                    public void onSubscribe(Disposable d) {
                        addDisposable(d);
                    }

                    @Override
                    public void onNext(HttpResult<QRInfo> qrInfoHttpResult) {
                        if(qrInfoHttpResult.isSuccess()){
                            Bundle bundle = new Bundle();
                            bundle.putString(ParamConstant.QRCODE_LOGIN_IP,qrInfoHttpResult.getData().getIpAddress());
                            bundle.putString(ParamConstant.QRCODE_LOGIN_equipment,qrInfoHttpResult.getData().getEquipment());
                            bundle.putString(ParamConstant.QRCODE_MSG,qrcode);
                            ArouterUtil.navigation(RoutePath.QRLoginActivity, bundle);
                        }else{
                            ToastUtils.showToast(CaptureActivity.this,qrInfoHttpResult.getMsg());
                        }
                    }

                    @Override
                    public void onError(Throwable e) {
                        e.printStackTrace();
                    }

                    @Override
                    public void onComplete() {
                        finish();
                    }
                });
    }

    private void initCamera(SurfaceHolder surfaceHolder) {
        if (surfaceHolder == null) {
            throw new IllegalStateException("No SurfaceHolder provided");
        }
        if (cameraManager.isOpen()) {
//            Log.w(TAG, "initCamera() while already open -- late SurfaceView callback?");
            return;
        }
        try {
            cameraManager.openDriver(this, surfaceHolder);
            // Creating the handler starts the preview, which can also throw a RuntimeException.
            if (handler == null) {
                handler = new CaptureActivityHandler(this, decodeFormats, decodeHints, characterSet, cameraManager);
            }
            decodeOrStoreSavedBitmap(null, null);
        } catch (IOException ioe) {
            Log.w(TAG, ioe);
            displayFrameworkBugMessageAndExit();
        } catch (RuntimeException e) {
            // Barcode Scanner has seen crashes in the wild of this variety:
            // java.?lang.?RuntimeException: Fail to connect to camera service
            Log.w(TAG, "Unexpected ic_error initializing camera", e);
            displayFrameworkBugMessageAndExit();
        }
    }

    private void decodeOrStoreSavedBitmap(Bitmap bitmap, Result result) {
        // Bitmap isn't used yet -- will be used soon
        if (handler == null) {
            savedResultToShow = result;
        } else {
            if (result != null) {
                savedResultToShow = result;
            }
            if (savedResultToShow != null) {
                Message message = Message.obtain(handler, R.id.decode_succeeded, savedResultToShow);
                handler.sendMessage(message);
            }
            savedResultToShow = null;
        }
    }

    private void displayFrameworkBugMessageAndExit() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this, R.style.AlertDialogStyle);
        builder.setTitle(getString(R.string.app_name));
        builder.setMessage("There was a camera ic_error.");
        builder.setPositiveButton(android.R.string.ok, new FinishListener(this));
        builder.setOnCancelListener(new FinishListener(this));
        builder.show();
    }

    private void resetStatusView() {
        viewfinderView.setVisibility(View.VISIBLE);
    }

    public void drawViewfinder() {
        viewfinderView.drawViewfinder();
    }

    public static final int REQUEST_CODE = 10110;


    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.layout_pic:
                boolean isHasPermission =
                        ContextCompat.checkSelfPermission(this,Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED &&
                        ContextCompat.checkSelfPermission(this,Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED;
                if(isHasPermission){
                    imageTool.openGallery("");
                    return;
                }
                //Missing permissions
                RxPermissions rxPermissions = new RxPermissions(this);
                rxPermissions.request(Manifest.permission.READ_EXTERNAL_STORAGE,Manifest.permission.WRITE_EXTERNAL_STORAGE)
                        .subscribe(granted -> {
                            if (granted) {
                                imageTool.openGallery("");
                            } else {
                                DialogUtil.showAlertDialog(this, LanguageUtil.getString(this,"no_album_permission_msg_tip"));
                            }
                        });

                break;
            default:
                break;
        }

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @androidx.annotation.Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        imageTool.onAcitvityResult(requestCode, resultCode, data, new ImageTools.OnBitmapCreateListener() {
            @Override
            public void onBitmapCreate(Bitmap bitmap, String path) {
                
                Result result = scanningImage(path);
                if (result != null) {
                    
                    handleDecodeExternally(result);
                } else {
                    Toast.makeText(CaptureActivity.this, R.string.toast_scan_content_empty, Toast.LENGTH_SHORT).show();
                    finish();
                }
            }
        });

    }

    /**
     *Method of scanning QR code images
     *
     * @param path
     * @return
     */
    public Result scanningImage(String path) {
        if (TextUtils.isEmpty(path)) {
            return null;
        }
        Hashtable<DecodeHintType, String> hints = new Hashtable<>();
        hints.put(DecodeHintType.CHARACTER_SET, "UTF8"); //Set encoding for QR code content

        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true; //Get the original size first
        Bitmap scanBitmap = QRCodeUtils.Companion.getDecodeAbleBitmap(path);
        if (scanBitmap == null) {
            return null;
        }
        //Obtain the width, height, and pixel matrix of the bitmap
        int width = scanBitmap.getWidth();
        int height = scanBitmap.getHeight();
        int[] pixels = new int[width * height];
        scanBitmap.getPixels(pixels, 0, width, 0, 0, width, height);
        RGBLuminanceSource source = new RGBLuminanceSource(width, height, pixels);
        BinaryBitmap bitmap1 = new BinaryBitmap(new HybridBinarizer(source));
        QRCodeReader reader = new QRCodeReader();
        try {
            return reader.decode(bitmap1, hints);
        } catch (NotFoundException e) {
            e.printStackTrace();
        } catch (ChecksumException e) {
            e.printStackTrace();
        } catch (FormatException e) {
            e.printStackTrace();
        }
        return null;
    }

}
