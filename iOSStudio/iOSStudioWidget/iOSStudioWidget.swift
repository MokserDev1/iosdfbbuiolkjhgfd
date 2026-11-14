//
//  iOSStudioWidget.swift
//  iOSStudioWidget
//

import WidgetKit
import SwiftUI

struct StudioWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let subtitle: String
    let accentHex: String
}

struct StudioTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StudioWidgetEntry {
        StudioWidgetEntry(
            date: Date(),
            title: "iOS Studio",
            subtitle: "Personalization Center",
            accentHex: "#007AFF"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (StudioWidgetEntry) -> Void) {
        let entry = StudioWidgetEntry(
            date: Date(),
            title: "iOS Studio",
            subtitle: "Lock & Home Suite Active",
            accentHex: "#007AFF"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StudioWidgetEntry>) -> Void) {
        let currentDate = Date()
        let entry = StudioWidgetEntry(
            date: currentDate,
            title: "iOS Studio",
            subtitle: "All Presets Synchronized",
            accentHex: "#007AFF"
        )
        
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct iOSStudioWidgetEntryView: View {
    var entry: StudioTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.blue)
                        Spacer()
                        Text(entry.date, style: .time)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(entry.title)
                        .font(.system(size: 15, weight: .bold))
                    Text(entry.subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                
            case .systemLarge:
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label(entry.title, systemImage: "slider.horizontal.3")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Spacer()
                        Text(entry.date, style: .time)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                    }
                    Divider()
                    Text(entry.subtitle)
                        .font(.subheadline)
                    Spacer()
                    HStack(spacing: 8) {
                        Text("Wallpapers")
                            .font(.caption2)
                            .padding(6)
                            .background(Color.secondary.opacity(0.15))
                            .cornerRadius(6)
                        Text("Icons")
                            .font(.caption2)
                            .padding(6)
                            .background(Color.secondary.opacity(0.15))
                            .cornerRadius(6)
                        Text("Tendies")
                            .font(.caption2)
                            .padding(6)
                            .background(Color.secondary.opacity(0.15))
                            .cornerRadius(6)
                    }
                }
                .padding(16)
                
            default: // systemMedium
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.blue)
                            Text(entry.title)
                                .font(.system(size: 16, weight: .bold))
                        }
                        Text(entry.subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Spacer()
                        Label("System Compliant", systemImage: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(entry.date, style: .time)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        Text("STUDIO")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)
            }
        }
        .widgetURL(URL(string: "iosstudio://home"))
    }
}

@main
struct iOSStudioWidget: Widget {
    let kind: String = "iOSStudioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StudioTimelineProvider()) { entry in
            iOSStudioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("iOS Studio Suite")
        .description("Quick information, clock, and deep link access for iOS Studio.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

