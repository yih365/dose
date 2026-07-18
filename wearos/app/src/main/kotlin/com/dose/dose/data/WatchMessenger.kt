package com.dose.dose.data

import android.content.Context
import com.google.android.gms.wearable.Wearable
import kotlinx.coroutines.tasks.await
import org.json.JSONObject

object WatchMessenger {

    private const val PATH_LOG = "/log_caffeine"

    suspend fun sendLog(context: Context, type: String, mg: Int) {
        val payload = JSONObject()
            .put("type", type)
            .put("mg", mg)
            .toString()
            .toByteArray()

        val nodeClient = Wearable.getNodeClient(context)
        val nodes = nodeClient.connectedNodes.await()
        val messageClient = Wearable.getMessageClient(context)
        nodes.forEach { node ->
            messageClient.sendMessage(node.id, PATH_LOG, payload).await()
        }
    }
}
