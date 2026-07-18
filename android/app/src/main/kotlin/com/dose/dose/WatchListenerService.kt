package com.dose.dose

import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.WearableListenerService
import org.json.JSONObject

// Receives /log_caffeine messages from the Pixel Watch and forwards them to
// Flutter via a broadcast. MainActivity picks up the broadcast and pipes it
// through the MethodChannel to Dart.
class WatchListenerService : WearableListenerService() {

    override fun onMessageReceived(event: MessageEvent) {
        if (event.path != PATH_LOG) return
        val json = runCatching { JSONObject(String(event.data)) }.getOrNull() ?: return
        val intent = android.content.Intent(ACTION_LOG_FROM_WATCH).apply {
            putExtra(EXTRA_TYPE, json.optString("type", "custom"))
            putExtra(EXTRA_MG,   json.optInt("mg", 0))
        }
        sendBroadcast(intent)
    }

    companion object {
        const val PATH_LOG           = "/log_caffeine"
        const val ACTION_LOG_FROM_WATCH = "com.dose.dose.LOG_FROM_WATCH"
        const val EXTRA_TYPE         = "type"
        const val EXTRA_MG           = "mg"
    }
}
