package mingo.strings

import android.Manifest
import android.content.pm.PackageManager.*
import android.os.Bundle
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import be.tarsos.dsp.AudioDispatcher
import be.tarsos.dsp.AudioEvent
import be.tarsos.dsp.io.android.AudioDispatcherFactory
import be.tarsos.dsp.pitch.PitchDetectionHandler
import be.tarsos.dsp.pitch.PitchDetectionResult
import be.tarsos.dsp.pitch.PitchProcessor
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity(), PitchDetectionHandler, EventChannel.StreamHandler {

    val REQUEST_MICROPHONE = 1
    val PITCH_EVENT = "mingo.app_strings.events/patch"

    private var dispatcher: AudioDispatcher? = null

    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, PITCH_EVENT).setStreamHandler(this)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_MICROPHONE) {
            if (grantResults[0] == PERMISSION_GRANTED) {
                startDispatcher()
            } else {

            }
        }
    }

    override fun handlePitch(result: PitchDetectionResult, event: AudioEvent) {
        if (result.pitch != -1F) {
            val pitch = result.pitch
            val probability = result.probability
            val rms = event.rms * 100
            val map = mutableMapOf<String, Float>()
            map["pitch"] = pitch
            map["probability"] = probability
            map["rms"] = rms.toFloat()
            map["timestamp"] = event.timeStamp.toFloat()
            runOnUiThread {
                //                Log.e("Pitch", "%s (%s) rms=%s t=%s".format(pitch, probability, rms, event.timeStamp))
                eventSink?.success(map)
            }
        }
    }

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
        this.eventSink = eventSink
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECORD_AUDIO), REQUEST_MICROPHONE)
        } else {
            startDispatcher()
        }
    }

    override fun onCancel(arguments: Any?) {
        this.eventSink = null
        this.dispatcher?.stop()
        this.dispatcher = null
    }

    private fun startDispatcher() {
        val sampleRate = 44100
        val bufferSize = 7168
        val overlap = 0
        dispatcher?.stop()
        dispatcher = AudioDispatcherFactory.fromDefaultMicrophone(sampleRate, bufferSize, overlap)
        dispatcher?.addAudioProcessor(PitchProcessor(PitchProcessor.PitchEstimationAlgorithm.YIN, sampleRate.toFloat(), bufferSize, this))
//        dispatcher?.addAudioProcessor(PitchProcessor(PitchEstimationAlgorithm.MPM, sampleRate.toFloat(), bufferSize, this))
        Thread(dispatcher).start()
    }
}
