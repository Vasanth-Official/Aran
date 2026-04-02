package io.flutter.plugin.common;

import androidx.annotation.NonNull;

/**
 * Compatibility stub for legacy Flutter plugins that still reference the V1
 * Embedding.
 * Flutter 3.41.x has officially removed these symbols, causing compilation
 * failures
 * in legacy plugin branches that are not actually executed at runtime.
 */
public interface PluginRegistry {
    public interface Registrar {
        // This is a stub to satisfy the compiler.
    }
}
