package com.inclusion.cameroon.accessibility_overlay

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.util.Log

class CustomAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        // Throttle parses to avoid performance spikes
        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED,
            AccessibilityEvent.TYPE_VIEW_CLICKED,
            AccessibilityEvent.TYPE_VIEW_FOCUSED -> {
                scrapeCurrentScreen()
            }
        }
    }

    private fun scrapeCurrentScreen() {
        val rootNode = rootInActiveWindow ?: return
        val sb = StringBuilder()
        extractText(rootNode, sb)
        val screenText = sb.toString()
        
        // Log for debugging (in production, send to Flutter via EventChannel or similar)
        Log.d("AccessibilityService", "Scraped Text: $screenText")
        
        // TODO: Implement communication to Flutter Overlay Window
    }

    private fun extractText(node: AccessibilityNodeInfo, sb: StringBuilder) {
        if (node.text != null && node.text.isNotEmpty()) {
            sb.append(node.text).append(" ")
        }
        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (child != null) {
                extractText(child, sb)
                child.recycle()
            }
        }
    }

    override fun onInterrupt() {
        Log.d("AccessibilityService", "Service Interrupted")
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("AccessibilityService", "Service Connected")
    }
}
