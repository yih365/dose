package com.dose.dose.presentation.theme

import androidx.compose.runtime.Composable
import androidx.wear.compose.material.MaterialTheme

val AccentOrange = androidx.compose.ui.graphics.Color(0xFFC67139)
val AccentSage = androidx.compose.ui.graphics.Color(0xFF7A8A5E)
val WatchBg = androidx.compose.ui.graphics.Color(0xFF1C1A17)
val WatchSurface = androidx.compose.ui.graphics.Color(0xFF2C2620)
val WatchText = androidx.compose.ui.graphics.Color(0xFFE7D9C2)
val WatchSubtext = androidx.compose.ui.graphics.Color(0xFFC9B89E)

@Composable
fun BrewTheme(content: @Composable () -> Unit) {
    MaterialTheme(content = content)
}
