package com.dose.dose

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import com.google.android.gms.wearable.DataClient
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {

    private val methodChannel = "com.dose.dose/watch"
    private val eventChannel  = "com.dose.dose/watch_events"

    private var eventSink: EventChannel.EventSink? = null
    private lateinit var dataClient: DataClient

    private val watchReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action != WatchListenerService.ACTION_LOG_FROM_WATCH) return
            val type = intent.getStringExtra(WatchListenerService.EXTRA_TYPE) ?: return
            val mg   = intent.getIntExtra(WatchListenerService.EXTRA_MG, 0)
            eventSink?.success(mapOf("type" to type, "mg" to mg))
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        dataClient = Wearable.getDataClient(this)

        // Phone → Watch: push daily total so the tile and watch app can display it
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pushDailyTotal" -> {
                        val totalMg = call.argument<Int>("total_mg") ?: 0
                        val limitMg = call.argument<Int>("limit_mg") ?: 400
                        pushDailyTotal(totalMg, limitMg)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // Watch → Phone: stream log events to Dart
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannel)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, sink: EventChannel.EventSink) {
                    eventSink = sink
                    val filter = IntentFilter(WatchListenerService.ACTION_LOG_FROM_WATCH)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        registerReceiver(watchReceiver, filter, RECEIVER_NOT_EXPORTED)
                    } else {
                        registerReceiver(watchReceiver, filter)
                    }
                }
                override fun onCancel(args: Any?) {
                    eventSink = null
                    runCatching { unregisterReceiver(watchReceiver) }
                }
            })
    }

    private fun pushDailyTotal(totalMg: Int, limitMg: Int) {
        val request = PutDataMapRequest.create("/daily_total").apply {
            dataMap.putInt("total_mg", totalMg)
            dataMap.putInt("limit_mg", limitMg)
            dataMap.putLong("ts", System.currentTimeMillis()) // force update
        }
        dataClient.putDataItem(request.asPutDataRequest().setUrgent())
    }
}
