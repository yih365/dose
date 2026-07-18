package com.dose.dose.presentation

import android.content.Context
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.material.*
import com.dose.dose.data.WatchMessenger
import com.dose.dose.presentation.theme.*
import kotlinx.coroutines.launch

data class Preset(val label: String, val type: String, val mg: Int)

val PRESETS = listOf(
    Preset("Espresso", "espresso", 63),
    Preset("Coffee",   "coffee",   96),
    Preset("Tea",      "tea",      28),
    Preset("Energy",   "energy",   160),
)

sealed class Screen {
    object Presets : Screen()
    object Custom : Screen()
    data class Confirmation(val label: String, val mg: Int) : Screen()
}

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val presetFromTile = intent?.getStringExtra("preset")
        setContent { BrewWatchApp(presetFromTile = presetFromTile) }
    }
}

@Composable
fun BrewWatchApp(presetFromTile: String?) {
    val context = LocalContext.current
    val scope   = rememberCoroutineScope()

    val initialScreen: Screen = remember(presetFromTile) {
        PRESETS.find { it.type == presetFromTile }
            ?.let { Screen.Confirmation(it.label, it.mg) }
            ?: Screen.Presets
    }
    var screen by remember { mutableStateOf<Screen>(initialScreen) }

    // If opened from a tile preset tap, fire the log immediately
    LaunchedEffect(presetFromTile) {
        if (presetFromTile != null) {
            val preset = PRESETS.find { it.type == presetFromTile } ?: return@LaunchedEffect
            runCatching { WatchMessenger.sendLog(context, preset.type, preset.mg) }
        }
    }

    Box(
        modifier = Modifier.fillMaxSize().background(WatchBg),
        contentAlignment = Alignment.Center,
    ) {
        when (val s = screen) {
            is Screen.Presets -> PresetsScreen(
                onPreset = { preset ->
                    scope.launch { runCatching { WatchMessenger.sendLog(context, preset.type, preset.mg) } }
                    screen = Screen.Confirmation(preset.label, preset.mg)
                },
                onCustom = { screen = Screen.Custom },
            )
            is Screen.Custom -> CustomScreen(
                onLog = { mg ->
                    scope.launch { runCatching { WatchMessenger.sendLog(context, "custom", mg) } }
                    screen = Screen.Confirmation("Custom", mg)
                },
                onBack = { screen = Screen.Presets },
            )
            is Screen.Confirmation -> ConfirmationScreen(
                label = s.label,
                mg = s.mg,
                onDone = { screen = Screen.Presets },
            )
        }
    }
}

@Composable
fun PresetsScreen(onPreset: (Preset) -> Unit, onCustom: () -> Unit) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
        modifier = Modifier.fillMaxSize().padding(horizontal = 12.dp),
    ) {
        Text("Log caffeine", color = WatchText, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
        Spacer(Modifier.height(10.dp))
        PRESETS.chunked(2).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                row.forEach { preset ->
                    PresetButton(preset = preset, onClick = { onPreset(preset) })
                }
            }
            Spacer(Modifier.height(8.dp))
        }
        Chip(
            onClick = onCustom,
            colors = ChipDefaults.chipColors(backgroundColor = AccentOrange),
            modifier = Modifier.width(158.dp).height(30.dp),
            label = {
                Text(
                    "+ Custom",
                    color = Color.White,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth(),
                )
            },
        )
    }
}

@Composable
fun PresetButton(preset: Preset, onClick: () -> Unit) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
        modifier = Modifier
            .size(75.dp, 52.dp)
            .clip(RoundedCornerShape(18.dp))
            .background(WatchSurface)
            .clickable(onClick = onClick)
            .padding(4.dp),
    ) {
        Text(preset.label, color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Bold)
        Text("${preset.mg} mg", color = WatchSubtext, fontSize = 9.5.sp, fontWeight = FontWeight.SemiBold)
    }
}

@Composable
fun CustomScreen(onLog: (Int) -> Unit, onBack: () -> Unit) {
    var mg by remember { mutableIntStateOf(75) }
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
        modifier = Modifier.fillMaxSize(),
    ) {
        Text("Custom", color = WatchSubtext, fontSize = 11.sp, fontWeight = FontWeight.SemiBold)
        Spacer(Modifier.height(8.dp))
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            StepButton("−") { mg = (mg - 5).coerceAtLeast(5) }
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text("$mg", color = Color.White, fontSize = 38.sp, fontWeight = FontWeight.Light)
                Text("mg", color = WatchSubtext, fontSize = 11.sp, fontWeight = FontWeight.Bold)
            }
            StepButton("+") { mg = (mg + 5).coerceAtMost(999) }
        }
        Spacer(Modifier.height(14.dp))
        Chip(
            onClick = { onLog(mg) },
            colors = ChipDefaults.chipColors(backgroundColor = AccentOrange),
            modifier = Modifier.width(120.dp).height(38.dp),
            label = {
                Text(
                    "✓ Log",
                    color = Color.White,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.ExtraBold,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth(),
                )
            },
        )
    }
}

@Composable
fun StepButton(label: String, onClick: () -> Unit) {
    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier
            .size(44.dp)
            .clip(CircleShape)
            .background(WatchSurface)
            .clickable(onClick = onClick),
    ) {
        Text(label, color = WatchText, fontSize = 20.sp, fontWeight = FontWeight.Light)
    }
}

@Composable
fun ConfirmationScreen(label: String, mg: Int, onDone: () -> Unit) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
        modifier = Modifier.fillMaxSize().clickable(onClick = onDone),
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.size(64.dp).clip(CircleShape).background(Color(0xFF294020)),
        ) {
            Text("✓", color = AccentSage, fontSize = 28.sp)
        }
        Spacer(Modifier.height(10.dp))
        Text("Logged", color = Color.White, fontSize = 22.sp, fontWeight = FontWeight.Light)
        Spacer(Modifier.height(4.dp))
        Text("$label · $mg mg", color = WatchText, fontSize = 14.sp, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(6.dp))
        Text("Tap to dismiss", color = WatchSubtext, fontSize = 10.sp)
    }
}
