
package com.bnmovies.app

import android.app.Activity
import android.os.Bundle
import android.graphics.Color
import android.view.Gravity
import android.view.View
import android.widget.*

class MainActivity : Activity() {

    private val bg = Color.rgb(10, 10, 14)
    private val red = Color.rgb(220, 25, 50)
    private val blue = Color.rgb(30, 110, 210)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        window.statusBarColor = bg
        window.navigationBarColor = bg

        val scroll = ScrollView(this)
        scroll.setBackgroundColor(bg)

        val page = LinearLayout(this)
        page.orientation = LinearLayout.VERTICAL
        page.setPadding(20, 25, 20, 25)
        page.layoutDirection = View.LAYOUT_DIRECTION_RTL

        scroll.addView(page)

        val logo = TextView(this)
        logo.text = "BN MOVIES"
        logo.textSize = 32f
        logo.setTextColor(red)
        logo.gravity = Gravity.CENTER
        logo.setTypeface(null, 1)
        page.addView(logo)

        addTitle(page, "عالم الأفلام والمسلسلات والأنمي")

        addSection(page, "القنوات الرياضية", blue)
        addSection(page, "الأكثر مشاهدة", red)
        addSection(page, "أفضل 20", blue)
        addSection(page, "اختيار المشاهدين", red)

        addSection(page, "الأفلام الأجنبية", red)
        addSection(page, "الأفلام الآسيوية", red)
        addSection(page, "الأفلام الهندية", red)

        addSection(page, "المسلسلات الأجنبية", blue)
        addSection(page, "المسلسلات الآسيوية", blue)
        addSection(page, "المسلسلات الهندية", blue)

        addSection(page, "الأنمي الياباني", red)
        addSection(page, "الأنمي الصيني", red)
        addSection(page, "تصنيفات الأنمي", red)

        setContentView(scroll)
    }

    private fun addTitle(page: LinearLayout, title: String) {
        val text = TextView(this)
        text.text = title
        text.textSize = 16f
        text.setTextColor(Color.WHITE)
        text.gravity = Gravity.CENTER
        page.addView(text)
    }

    private fun addSection(
        page: LinearLayout,
        title: String,
        color: Int
    ) {
        val text = TextView(this)
        text.text = title
        text.textSize = 20f
        text.setTextColor(color)
        text.setTypeface(null, 1)
        text.gravity = Gravity.RIGHT
        text.setPadding(8, 25, 8, 12)
        page.addView(text)
    }
}
