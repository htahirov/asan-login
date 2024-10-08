package com.asan_login

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import android.app.Activity

class AsanLoginPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var scheme: String
    private var activity: Activity? = null

    companion object {
        const val CHANNEL = "asan_login"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        // Set up a listener for new intents
        binding.addOnNewIntentListener { intent ->
            handleNewIntent(intent)  // Call your handleNewIntent function
            true // Indicate the listener was handled successfully
        }
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "performLogin") {
            val url = call.argument<String>("url") ?: ""
            val clientId = call.argument<String>("clientId")?: ""
            val redirectUri = call.argument<String>("redirectUri")?: ""
            val scope = call.argument<String>("scope")?: ""
            val sessionId = call.argument<String>("sessionId")?: ""
            val responseType = call.argument<String>("responseType")?: ""
            scheme = call.argument<String>("scheme")?: ""

            performLogin(url, clientId, redirectUri, scope, sessionId, responseType)
            result.success(null)
        } else {
            result.notImplemented()
        }
    }

    private fun performLogin(url: String, clientId: String, redirectUri: String, scope: String, sessionId: String, responseType: String) {
        val intent = Intent(Intent.ACTION_VIEW).apply {
            data = Uri.parse(getAsanUrl(url, clientId, redirectUri, scope, sessionId, responseType))
        }
        activity?.startActivity(intent)
    }

    private fun getAsanUrl(url: String, clientId: String, redirectUri: String, scope: String, sessionId: String, responseType: String): String {
        return "${url}client_id=$clientId&redirect_uri=$redirectUri&response_type=$responseType&state=$sessionId&scope=$scope"
    }

    // Handle the deep link when the app returns from the browser
    private fun handleNewIntent(intent: Intent) {
        val data = intent.data
        if (data != null && data.scheme == scheme) { 
            val code = data.getQueryParameter("code")
            if (code != null) {
                channel.invokeMethod("onCodeReceived", code)
            }
        }
    }
}
