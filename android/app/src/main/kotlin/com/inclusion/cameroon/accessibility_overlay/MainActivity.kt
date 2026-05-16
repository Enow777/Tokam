package com.inclusion.cameroon.accessibility_overlay

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val RUNTIME_CHANNEL = "com.inclusion.overlay/shortcut_manager"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RUNTIME_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "executePinRequest") {
                val executionOutcome = executePinRequest()
                if (executionOutcome) result.success(true) else result.error("API_UNSUPPORTED", "Shortcut Pin Mechanism Rejected by Platform Engine", null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun executePinRequest(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val systemShortcutManager = getSystemService(ShortcutManager::class.java)
            if (systemShortcutManager != null && systemShortcutManager.isRequestPinShortcutSupported) {
                val targetLaunchIntent = Intent(context, MainActivity::class.java).apply {
                    action = Intent.ACTION_RUN
                    putExtra("execution_mode", "direct_overlay_boot")
                }
                
                val pinShortcutData = ShortcutInfo.Builder(context, "dynamic_overlay_shortcut")
                    .setShortLabel("Start Voice Guide")
                    .setLongLabel("Launch Cameroon Linguistic Voice Assistant")
                    .setIcon(Icon.createWithResource(context, R.mipmap.ic_launcher))
                    .setIntent(targetLaunchIntent)
                    .build()

                val intentSuccessCallback = systemShortcutManager.createShortcutResultIntent(pinShortcutData)
                val statusPendingIntent = PendingIntent.getBroadcast(context, 0, intentSuccessCallback, PendingIntent.FLAG_IMMUTABLE)
                return systemShortcutManager.requestPinShortcut(pinShortcutData, statusPendingIntent.intentSender)
            }
        }
        return false
    }
}
