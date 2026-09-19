package com.krfbrothers.dua

import io.flutter.embedding.android.FlutterActivity
import java.io.FileDescriptor
import java.io.PrintWriter

class MainActivity : FlutterActivity() {
    override fun dump(
        prefix: String,
        fd: FileDescriptor?,
        writer: PrintWriter,
        args: Array<out String>?
    ) {
        try {
            super.dump(prefix, fd, writer, args)
        } catch (e: Exception) {
            // Ignore EPIPE broken pipe errors
        }
    }
}
