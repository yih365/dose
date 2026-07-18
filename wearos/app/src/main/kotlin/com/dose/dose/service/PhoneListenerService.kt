package com.dose.dose.service

import android.content.Intent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.WearableListenerService
import org.json.JSONObject

// Receives /daily_total DataItem updates pushed by the phone app.
// Broadcasts the new totals locally so the tile and watch app can refresh.
class PhoneListenerService : WearableListenerService() {

    override fun onDataChanged(events: DataEventBuffer) {
        events.forEach { event ->
            if (event.dataItem.uri.path == "/daily_total") {
                val raw = event.dataItem.data ?: return@forEach
                val json = JSONObject(String(raw))
                val intent = Intent(ACTION_TOTAL_UPDATED).apply {
                    putExtra(EXTRA_TOTAL_MG, json.getInt("total_mg"))
                    putExtra(EXTRA_LIMIT_MG, json.getInt("limit_mg"))
                }
                sendBroadcast(intent)
            }
        }
    }

    companion object {
        const val ACTION_TOTAL_UPDATED = "com.dose.dose.TOTAL_UPDATED"
        const val EXTRA_TOTAL_MG = "total_mg"
        const val EXTRA_LIMIT_MG = "limit_mg"
    }
}
