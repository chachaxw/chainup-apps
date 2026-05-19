package com.example.viewtest

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.chainup.kit.views.KKSelectRatioViewKit

class SegmentActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_segment)

        ( findViewById<View>(R.id.srv_view) as KKSelectRatioViewKit).apply {
            this.setRadios(arrayOf(0.25f, 0.50f, 0.75f, 1.00f), 3, null)
        }

        ( findViewById<View>(R.id.srv_view_sell) as KKSelectRatioViewKit).apply {
            this.setRadios(arrayOf(0.25f, 0.50f, 0.75f, 1.00f), 2, null,color=R.color.fall_1)
        }

        ( findViewById<View>(R.id.srv_view_buy) as KKSelectRatioViewKit).apply {
            this.setRadios(arrayOf(0.25f, 0.50f, 0.75f, 1.00f), 1, null,color=R.color.rise_1)
        }
    }
}