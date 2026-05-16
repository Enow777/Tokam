package com.inclusion.cameroon.accessibility_overlay

import android.accessibilityservice.AccessibilityService
import android.content.SharedPreferences
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.util.Log

class CustomAccessibilityService : AccessibilityService() {

    private var lastScrapeTime = 0L
    private val throttleMs = 1500L // Minimum 1.5s between scrapes

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                val now = System.currentTimeMillis()
                if (now - lastScrapeTime >= throttleMs) {
                    lastScrapeTime = now
                    scrapeAndSave()
                }
            }
        }
    }

    private fun scrapeAndSave() {
        val rootNode = rootInActiveWindow ?: return
        val sb = StringBuilder()
        extractText(rootNode, sb)
        val screenText = sb.toString().trim()

        if (screenText.isNotEmpty()) {
            // Save to SharedPreferences so the Flutter overlay can read it instantly
            val prefs: SharedPreferences = applicationContext.getSharedPreferences(
                "FlutterSharedPreferences",
                MODE_PRIVATE
            )
            // Flutter's shared_preferences plugin prefixes keys with "flutter."
            prefs.edit().putString("flutter.tokam_screen_text", screenText).apply()
            Log.d("TokamService", "Saved ${screenText.length} chars from screen")
        }
    }

    private fun extractText(node: AccessibilityNodeInfo, sb: StringBuilder) {
        if (!node.text.isNullOrBlank()) {
            sb.append(node.text).append(" ")
        }
        if (!node.contentDescription.isNullOrBlank()) {
            sb.append(node.contentDescription).append(" ")
        }
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            extractText(child, sb)
            child.recycle()
        }
    }

    override fun onInterrupt() {
        Log.d("TokamService", "Service interrupted")
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("TokamService", "Accessibility service connected — screen scanning active")
    }
}
