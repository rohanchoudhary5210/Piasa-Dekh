package com.salaryquest.salary_quest

import android.Manifest
import android.content.pm.PackageManager
import android.database.Cursor
import android.provider.Telephony
import android.view.WindowManager.LayoutParams
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val SMS_CHANNEL = "com.salaryquest.salary_quest/sms"
    private val SMS_EVENT_CHANNEL = "com.salaryquest.salary_quest/sms_stream"
    private val SMS_PERMISSION_REQ_CODE = 2001

    private var pendingPermissionResult: MethodChannel.Result? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Task 7 Security: FLAG_SECURE prevents screen recording and blurs recent-apps task switcher preview
        window.addFlags(LayoutParams.FLAG_SECURE)

        // MethodChannel for SMS Permissions & Inbox Query
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkSmsPermission" -> {
                    val hasReceive = ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED
                    val hasRead = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED
                    result.success(hasReceive && hasRead)
                }
                "requestSmsPermission" -> {
                    val hasReceive = ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED
                    val hasRead = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED
                    if (hasReceive && hasRead) {
                        result.success(true)
                    } else {
                        pendingPermissionResult = result
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS),
                            SMS_PERMISSION_REQ_CODE
                        )
                    }
                }
                "readRecentBankSms" -> {
                    val limit = call.argument<Int>("limit") ?: 50
                    val daysBack = call.argument<Int>("days") ?: 7
                    val sinceTimestamp = call.argument<Long>("sinceTimestamp")
                    val smsList = readRecentBankSmsFromInbox(limit, daysBack, sinceTimestamp)
                    result.success(smsList)
                }
                else -> result.notImplemented()
            }
        }

        // EventChannel for Real-Time Incoming SMS Streams
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    SmsBroadcastReceiver.smsListener = { sender, body, timestamp ->
                        runOnUiThread {
                            eventSink?.success(
                                mapOf(
                                    "sender" to sender,
                                    "body" to body,
                                    "timestamp" to timestamp
                                )
                            )
                        }
                    }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    SmsBroadcastReceiver.smsListener = null
                }
            }
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == SMS_PERMISSION_REQ_CODE) {
            val isGranted = grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            pendingPermissionResult?.success(isGranted)
            pendingPermissionResult = null
        }
    }

    private fun readRecentBankSmsFromInbox(limit: Int, daysBack: Int, sinceTimestamp: Long? = null): List<Map<String, Any>> {
        val results = mutableListOf<Map<String, Any>>()
        val hasRead = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED
        if (!hasRead) return results

        try {
            val cutoff = if (sinceTimestamp != null && sinceTimestamp > 0L) {
                sinceTimestamp
            } else {
                System.currentTimeMillis() - (daysBack.toLong() * 24L * 60L * 60L * 1000L)
            }
            val uri = Telephony.Sms.Inbox.CONTENT_URI
            val projection = arrayOf(
                Telephony.Sms.ADDRESS,
                Telephony.Sms.BODY,
                Telephony.Sms.DATE
            )
            val selection = "${Telephony.Sms.DATE} >= ?"
            val selectionArgs = arrayOf(cutoff.toString())
            val sortOrder = "${Telephony.Sms.DATE} DESC LIMIT $limit"

            val cursor: Cursor? = contentResolver.query(
                uri,
                projection,
                selection,
                selectionArgs,
                sortOrder
            )

            cursor?.use {
                val addressIdx = it.getColumnIndex(Telephony.Sms.ADDRESS)
                val bodyIdx = it.getColumnIndex(Telephony.Sms.BODY)
                val dateIdx = it.getColumnIndex(Telephony.Sms.DATE)

                while (it.moveToNext()) {
                    val address = if (addressIdx != -1) it.getString(addressIdx) ?: "" else ""
                    val body = if (bodyIdx != -1) it.getString(bodyIdx) ?: "" else ""
                    val date = if (dateIdx != -1) it.getLong(dateIdx) else System.currentTimeMillis()

                    if (body.isNotEmpty()) {
                        results.add(
                            mapOf(
                                "sender" to address,
                                "body" to body,
                                "timestamp" to date
                            )
                        )
                    }
                }
            }
        } catch (_: Exception) {
            // Ignore permission or cursor failure gracefully
        }
        return results
    }
}
