package com.example.build_up

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class StepWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, android.R.layout.simple_list_item_1).apply {
                val steps = widgetData.getString("_currentSteps", "0") ?: "0"
                setTextViewText(android.R.id.text1, "$steps Steps")
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}