package com.example.streak_counter

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class StreakWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val streak = widgetData.getInt("streak_count", 0)
                setTextViewText(R.id.streak_count, streak.toString())
                setTextViewText(R.id.widget_title, "STREAK")
                setTextViewText(R.id.widget_days_label, "DAYS")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
