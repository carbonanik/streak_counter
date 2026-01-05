package com.example.streak_counter

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
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
                val state = widgetData.getString("streak_state", "zero")
                
                setTextViewText(R.id.streak_count, streak.toString())
                setTextViewText(R.id.widget_title, "STREAK")
                setTextViewText(R.id.widget_days_label, "DAYS")
                
                // Set background image based on state
                val imageRes = when (state) {
                    "active" -> R.drawable.streak_active
                    "completed" -> R.drawable.streak_completed
                    else -> R.drawable.streak_zero
                }
                setImageViewResource(R.id.widget_background_image, imageRes)
                
                // Add click support to open the app
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
