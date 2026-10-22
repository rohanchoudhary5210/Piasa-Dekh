package com.salaryquest.salary_quest

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.SmsMessage

class SmsBroadcastReceiver : BroadcastReceiver() {
    companion object {
        var smsListener: ((sender: String, body: String, timestamp: Long) -> Unit)? = null
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages: Array<SmsMessage>? = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            if (messages != null && messages.isNotEmpty()) {
                val fullBody = StringBuilder()
                var sender = ""
                var timestamp = System.currentTimeMillis()

                for (msg in messages) {
                    sender = msg.displayOriginatingAddress ?: ""
                    fullBody.append(msg.displayMessageBody ?: "")
                    timestamp = msg.timestampMillis
                }

                smsListener?.invoke(sender, fullBody.toString(), timestamp)
            }
        }
    }
}
