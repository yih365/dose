package com.dose.dose.tile

import android.content.SharedPreferences
import androidx.wear.protolayout.ActionBuilders.*
import androidx.wear.protolayout.ColorBuilders.argb
import androidx.wear.protolayout.DimensionBuilders.*
import androidx.wear.protolayout.LayoutElementBuilders.*
import androidx.wear.protolayout.ModifiersBuilders.*
import androidx.wear.protolayout.ResourceBuilders.Resources
import androidx.wear.protolayout.TimelineBuilders.*
import androidx.wear.tiles.RequestBuilders.*
import androidx.wear.tiles.TileBuilders.Tile
import androidx.wear.tiles.TileService
import com.google.common.util.concurrent.Futures
import com.google.common.util.concurrent.ListenableFuture

// Pixel Watch quick-log tile. Tapping a preset opens the watch app with that preset
// pre-selected, which logs it and shows the confirmation screen immediately.
class CaffeineTileService : TileService() {

    private val prefs: SharedPreferences by lazy {
        getSharedPreferences("dose_prefs", MODE_PRIVATE)
    }

    override fun onTileRequest(request: TileRequest): ListenableFuture<Tile> =
        Futures.immediateFuture(buildTile())

    override fun onResourcesRequest(request: ResourcesRequest): ListenableFuture<Resources> =
        Futures.immediateFuture(Resources.Builder().setVersion("1").build())

    private fun buildTile(): Tile = Tile.Builder()
        .setResourcesVersion("1")
        .setTileTimeline(
            Timeline.Builder()
                .addTimelineEntry(
                    TimelineEntry.Builder()
                        .setLayout(Layout.Builder().setRoot(buildRoot()).build())
                        .build()
                )
                .build()
        )
        .build()

    private fun buildRoot(): LayoutElement {
        val totalMg  = prefs.getInt("total_mg",  0)
        val limitMg  = prefs.getInt("limit_mg",  400)

        return Box.Builder()
            .setWidth(expand())
            .setHeight(expand())
            .setModifiers(
                Modifiers.Builder()
                    .setBackground(Background.Builder().setColor(argb(0xFF1C1A17.toInt())).build())
                    .build()
            )
            .addContent(
                Column.Builder()
                    .setWidth(expand())
                    .setHeight(expand())
                    .setHorizontalAlignment(HORIZONTAL_ALIGN_CENTER)
                    .addContent(buildHeader(totalMg, limitMg))
                    .addContent(buildPresetRow("Espresso", "espresso", 63, "Coffee", "coffee", 96))
                    .addContent(buildPresetRow("Tea",      "tea",      28, "Energy", "energy", 160))
                    .addContent(buildCustomButton())
                    .build()
            )
            .build()
    }

    private fun buildHeader(totalMg: Int, limitMg: Int): LayoutElement =
        Column.Builder()
            .setWidth(wrap())
            .setModifiers(Modifiers.Builder().setPadding(
                Padding.Builder().setTop(dp(16f)).setBottom(dp(8f)).build()
            ).build())
            .addContent(
                Text.Builder()
                    .setText("Log caffeine")
                    .setFontStyle(
                        FontStyle.Builder()
                            .setSize(sp(12f))
                            .setWeight(FONT_WEIGHT_BOLD)
                            .setColor(argb(0xFFE7D9C2.toInt()))
                            .build()
                    )
                    .build()
            )
            .addContent(
                Text.Builder()
                    .setText("$totalMg / $limitMg mg today")
                    .setFontStyle(
                        FontStyle.Builder()
                            .setSize(sp(10f))
                            .setColor(argb(0xFFC9B89E.toInt()))
                            .build()
                    )
                    .build()
            )
            .build()

    private fun buildPresetRow(
        label1: String, type1: String, mg1: Int,
        label2: String, type2: String, mg2: Int,
    ): LayoutElement = Row.Builder()
        .setWidth(wrap())
        .setModifiers(Modifiers.Builder().setPadding(
            Padding.Builder().setBottom(dp(6f)).build()
        ).build())
        .addContent(buildPresetChip(label1, type1, mg1))
        .addContent(Spacer.Builder().setWidth(dp(7f)).setHeight(dp(1f)).build())
        .addContent(buildPresetChip(label2, type2, mg2))
        .build()

    private fun buildPresetChip(label: String, type: String, mg: Int): LayoutElement {
        val launchAction = LaunchAction.Builder()
            .setAndroidActivity(
                AndroidActivity.Builder()
                    .setClassName("com.dose.dose.presentation.MainActivity")
                    .setPackageName("com.dose.dose")
                    .addKeyToExtraMapping(
                        "preset",
                        AndroidStringExtra.Builder().setValue(type).build()
                    )
                    .build()
            )
            .build()

        return Box.Builder()
            .setWidth(dp(72f))
            .setHeight(dp(50f))
            .setModifiers(
                Modifiers.Builder()
                    .setBackground(Background.Builder()
                        .setColor(argb(0xFF2C2620.toInt()))
                        .setCorner(Corner.Builder().setRadius(dp(14f)).build())
                        .build())
                    .setClickable(Clickable.Builder().setOnClick(launchAction).build())
                    .build()
            )
            .setHorizontalAlignment(HORIZONTAL_ALIGN_CENTER)
            .setVerticalAlignment(VERTICAL_ALIGN_CENTER)
            .addContent(
                Column.Builder()
                    .setWidth(wrap())
                    .setHorizontalAlignment(HORIZONTAL_ALIGN_CENTER)
                    .addContent(
                        Text.Builder()
                            .setText(label)
                            .setFontStyle(FontStyle.Builder()
                                .setSize(sp(12f))
                                .setWeight(FONT_WEIGHT_BOLD)
                                .setColor(argb(0xFFFFFFFF.toInt()))
                                .build())
                            .build()
                    )
                    .addContent(
                        Text.Builder()
                            .setText("$mg mg")
                            .setFontStyle(FontStyle.Builder()
                                .setSize(sp(9f))
                                .setColor(argb(0xFFC9B89E.toInt()))
                                .build())
                            .build()
                    )
                    .build()
            )
            .build()
    }

    private fun buildCustomButton(): LayoutElement {
        val launchAction = LaunchAction.Builder()
            .setAndroidActivity(
                AndroidActivity.Builder()
                    .setClassName("com.dose.dose.presentation.MainActivity")
                    .setPackageName("com.dose.dose")
                    .build()
            )
            .build()

        return Box.Builder()
            .setWidth(dp(150f))
            .setHeight(dp(28f))
            .setModifiers(
                Modifiers.Builder()
                    .setBackground(Background.Builder()
                        .setColor(argb(0xFFC67139.toInt()))
                        .setCorner(Corner.Builder().setRadius(dp(999f)).build())
                        .build())
                    .setClickable(Clickable.Builder().setOnClick(launchAction).build())
                    .build()
            )
            .setHorizontalAlignment(HORIZONTAL_ALIGN_CENTER)
            .setVerticalAlignment(VERTICAL_ALIGN_CENTER)
            .addContent(
                Text.Builder()
                    .setText("+ Custom")
                    .setFontStyle(FontStyle.Builder()
                        .setSize(sp(11f))
                        .setWeight(FONT_WEIGHT_BOLD)
                        .setColor(argb(0xFF2A1608.toInt()))
                        .build())
                    .build()
            )
            .build()
    }
}
