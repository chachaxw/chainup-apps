package com.example.viewtest

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.chainup.kit.views.KKTagKit
import com.coorchice.library.SuperTextView

class TagActivity : AppCompatActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_tag)

        findViewById<KKTagKit>(R.id.tk_convention_disable).isEnabled = false
    }
}