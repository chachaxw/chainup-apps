package com.yjkj.chainup.common;

import android.content.Context;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import com.sumsub.sns.core.theme.SNSColorElement;
import com.sumsub.sns.core.theme.SNSMetricElement;
import com.sumsub.sns.core.theme.SNSTheme;
import com.sumsub.sns.core.theme.SNSThemeColor;
import com.sumsub.sns.core.theme.SNSThemeFont;
import com.sumsub.sns.core.theme.SNSTypographyElement;
import com.yjkj.chainup.R;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;

public class KycTheme implements SNSTheme {
    WeakReference<Context> weakContext;
    public KycTheme(Context context){
        weakContext = new WeakReference<>(context);
    }
    @NonNull
    @Override
    public Map<SNSColorElement, SNSThemeColor> getColors() {
        HashMap<SNSColorElement, SNSThemeColor> colorMaps = new HashMap<>();
        colorMaps.put(
            SNSColorElement.BACKGROUND_COMMON,
            new SNSThemeColor(
                    ContextCompat.getColor(weakContext.get(),R.color.main_bg_color),
                    ContextCompat.getColor(weakContext.get(),R.color.main_bg_color)
            )
        );
        colorMaps.put(
                SNSColorElement.BACKGROUND_NEUTRAL,
                new SNSThemeColor(
                        ContextCompat.getColor(weakContext.get(),R.color.card_bg_color_2),
                        ContextCompat.getColor(weakContext.get(),R.color.card_bg_color_2)
                )
        );
        colorMaps.put(
                SNSColorElement.STATUS_BAR_COLOR,
                new SNSThemeColor(
                        ContextCompat.getColor(weakContext.get(),R.color.main_bg_color),
                        ContextCompat.getColor(weakContext.get(),R.color.main_bg_color)
                )
        );
        colorMaps.put(
                SNSColorElement.BOTTOM_SHEET_BACKGROUND,
                new SNSThemeColor(
                        ContextCompat.getColor(weakContext.get(),R.color.main_bg_color),
                        ContextCompat.getColor(weakContext.get(),R.color.main_bg_color)
                )
        );
        colorMaps.put(
                SNSColorElement.CONTENT_LINK,
                new SNSThemeColor(
                        ContextCompat.getColor(weakContext.get(),R.color.main_color),
                        ContextCompat.getColor(weakContext.get(),R.color.main_color)
                )
        );
        colorMaps.put(
                SNSColorElement.PRIMARY_BUTTON_BACKGROUND,
                new SNSThemeColor(
                        ContextCompat.getColor(weakContext.get(),R.color.main_color),
                        ContextCompat.getColor(weakContext.get(),R.color.main_color)
                )
        );
        colorMaps.put(
                SNSColorElement.PRIMARY_BUTTON_BACKGROUND_DISABLED,
                new SNSThemeColor(
                        ContextCompat.getColor(weakContext.get(),R.color.no_enable_color),
                        ContextCompat.getColor(weakContext.get(),R.color.no_enable_color)
                )
        );
        colorMaps.put(
                SNSColorElement.PRIMARY_BUTTON_BACKGROUND_HIGHLIGHTED,
                new SNSThemeColor(
                        ContextCompat.getColor(weakContext.get(),R.color.btn_pressed_color),
                        ContextCompat.getColor(weakContext.get(),R.color.btn_pressed_color)
                )
        );

        colorMaps.put(
                SNSColorElement.BACKGROUND_CRITICAL,
                new SNSThemeColor(
                        ContextCompat.getColor(weakContext.get(),R.color.special_2),
                        ContextCompat.getColor(weakContext.get(),R.color.special_2)
                )
        );
        colorMaps.put(
                SNSColorElement.FIELD_BACKGROUND,
                new SNSThemeColor(
                        ContextCompat.getColor(weakContext.get(),R.color.special_2),
                        ContextCompat.getColor(weakContext.get(),R.color.special_2)
                )
        );
        colorMaps.put(
                SNSColorElement.FIELD_PLACEHOLDER,
                new SNSThemeColor(
                        ContextCompat.getColor(weakContext.get(),R.color.text_3),
                        ContextCompat.getColor(weakContext.get(),R.color.text_3)
                )
        );

        colorMaps.put(
                SNSColorElement.CONTENT_WEAK,
                new SNSThemeColor(
                        ContextCompat.getColor(weakContext.get(),R.color.text_3),
                        ContextCompat.getColor(weakContext.get(),R.color.text_3)
                )
        );
        colorMaps.put(
                SNSColorElement.CONTENT_NEUTRAL,
                new SNSThemeColor(
                        ContextCompat.getColor(weakContext.get(),R.color.text_2),
                        ContextCompat.getColor(weakContext.get(),R.color.text_2)
                )
        );
        colorMaps.put(
                SNSColorElement.CONTENT_STRONG,
                new SNSThemeColor(
                        ContextCompat.getColor(weakContext.get(),R.color.text_1),
                        ContextCompat.getColor(weakContext.get(),R.color.text_1)
                )
        );

        return colorMaps;
    }

    @NonNull
    @Override
    public Map<SNSTypographyElement, SNSThemeFont> getFonts() {
        HashMap<SNSTypographyElement, SNSThemeFont> fontMaps = new HashMap<>();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            fontMaps.put(SNSTypographyElement.BODY,new SNSThemeFont(
                weakContext.get().getResources().getFont(R.font.harmony_regular),10
            ));
            fontMaps.put(SNSTypographyElement.HEADLINE1,new SNSThemeFont(
                weakContext.get().getResources().getFont(R.font.harmony_medium),24
            ));
            fontMaps.put(SNSTypographyElement.HEADLINE2,new SNSThemeFont(
                    weakContext.get().getResources().getFont(R.font.harmony_medium),14
            ));
            fontMaps.put(SNSTypographyElement.SUBTITLE1,new SNSThemeFont(
                weakContext.get().getResources().getFont(R.font.harmony_regular),16
            ));
            fontMaps.put(SNSTypographyElement.SUBTITLE2,new SNSThemeFont(
                    weakContext.get().getResources().getFont(R.font.harmony_regular),14
            ));
            fontMaps.put(SNSTypographyElement.CAPTION,new SNSThemeFont(
                    weakContext.get().getResources().getFont(R.font.harmony_regular),12
            ));


        }
        return fontMaps;
    }

    @NonNull
    @Override
    public Map<SNSMetricElement, Object> getMetrics() {
        HashMap<SNSMetricElement, Object> metricsMaps = new HashMap<>();
        return metricsMaps;
    }
}
