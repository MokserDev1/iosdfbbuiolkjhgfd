# iOS Studio — Complete iOS Customization Suite

[![Build & Package iOS Studio IPA](https://github.com/USER/REPO/actions/workflows/build.yml/badge.svg)](https://github.com/USER/REPO/actions/workflows/build.yml)

Полноценное нативное iOS-приложение для персонализации устройств Apple без джейлбрейка (**Deployment Target: iOS 15.0**, оптимизировано под **iOS 15.8.8** и более новые версии iOS).

---

## Архитектура и реализованные модули

1. **Dashboard & System Inspector (`SystemInspector.swift`, `HomeDashboardView.swift`)**:
   - Автоматический сбор аппаратных характеристик через публичные системные API (`uname`, `UIDevice`, `UIScreen`, `volumeTotalCapacityKey`).
   - Аудит доступных возможностей среды: нативная поддержка материалов Apple, статус демона `PosterBoard`, поддержка `setAlternateIconName`.
   - Журнал операций с автосохранением в `UserDefaults`.

2. **Wallpaper Studio (`WallpaperStudioView.swift`, `WallpaperDetailEditorView.swift`, `LivePhotoCreator.swift`)**:
   - Импорт медиа через PhotoKit (`PHPickerViewController`) и Files (`UIDocumentPickerViewController`).
   - Генерация настоящих **Apple Live Photos** с записью метаданных Apple MakerNote (`kCGImagePropertyMakerAppleDictionary` / тег 17) и QuickTime трека `com.apple.quicktime.content.identifier` через `AVFoundation` и `ImageIO`.
   - Экспорт в нативный альбом Photos через `PHAssetCreationRequest` и шеринг файлов через `UIActivityViewController`.

3. **Tendies Manager (`TendiesManagerView.swift`, `TendiesParser.swift`)**:
   - Разбор архивов `.tendies` (форматов `.descriptors` и `.posterboard container`).
   - Проверка сигнатур архива (PK-сигнатуры), выявление повреждённых файлов и архивов без конфигураций.
   - Чтение дескрипторов UUID и `wallpaper.plist` конфигураций с экспортом ассетов в Wallpaper Studio.

4. **Icon Studio (`IconStudioView.swift`, `IconExporter.swift`)**:
   - Инструмент рендеринга и обрезки иконок со сквирклом Apple (`UIGraphicsImageRenderer`).
   - Экспорт наборов иконок всех стандартных разрешений (1024x1024, 180x180, 120x120, 87x87, 60x60).
   - Поддержка нативной смены иконки приложения через `UIApplication.shared.setAlternateIconName`.
   - Встроенное руководство по применению иконок через официальное приложение Apple Shortcuts.

5. **Widget Studio & Extension (`WidgetStudioView.swift`, `iOSStudioWidget.swift`)**:
   - Настоящий `WidgetKit Extension` с `TimelineProvider` и настраиваемой периодичностью обновления.
   - Интерактивный канвас предварительного просмотра всех трёх семейств (`systemSmall`, `systemMedium`, `systemLarge`).
   - Принудительная перезагрузка таймлайнов через `WidgetCenter.shared.reloadAllTimelines()`.
   - Deep Links схема `iosstudio://` для быстрого перехода в разделы приложения.

6. **Theme Studio (`ThemeStudioView.swift`, `ThemeManager.swift`, `NativeCardStyle.swift`)**:
   - Настоящая дизайн-система Apple: на iOS 15.8.8 используются нативные системные материалы (`.regularMaterial`, `secondarySystemGroupedBackground`).
   - Отсутствие самодельного размытия или поддельного стекла.
   - Динамическая поддержка Apple Liquid Glass (`GlassEffectContainer` / `glassEffect`) при запуске на совместимых версиях ОС.

7. **Settings & Privacy (`SettingsRootView.swift`, `ShortcutsSettingsView.swift`)**:
   - 100% локальная обработка данных (Zero Telemetry, Zero Cloud Dependencies).
   - Расчёт занятого места и очистка кэшей.
   - Системный справочник Apple URL Schemes.

---

## Сборка IPA через GitHub Actions (Без платной подписки Apple Developer)

Так как сборка производится из среды Windows без локального Mac, проект оснащён полностью автоматизированным GitHub Actions Workflow: [`.github/workflows/build.yml`](.github/workflows/build.yml).

### Инструкция по сборке:
1. Загрузите репозиторий на GitHub.
2. Перейдите во вкладку **Actions** в вашем репозитории.
3. Выберите workflow **"Build & Package iOS Studio IPA (TrollStore Ready)"**.
4. Нажмите **Run workflow** -> **Run workflow**.
5. По завершении выполнения перейдите в запуск и скачайте готовый файл **`iOSStudio-TrollStore-IPA`** из раздела **Artifacts**.

### Установка через TrollStore:
- Скачанный `iOSStudio.ipa` имеет корректную структуру `Payload/iOSStudio.app` с внедрённым виджетом `PlugIns/iOSStudioWidgetExtension.appex`.
- В TrollStore откройте файл `iOSStudio.ipa` и нажмите **Install**. TrollStore применит CoreTrust обход и зарегистрирует приложение с сохранением всех прав доступа и виджетов.

---

## Матрица совместимости функций

| Возможность | Статус на iOS 15.8.8 | Статус на iOS 16.0 - 17.0 | Статус на новейших ОС (Liquid Glass) |
|---|---|---|---|
| **Интерфейс** | Нативные системные материалы iOS 15 (`.regularMaterial`) | Нативные системные материалы iOS 16/17 | Официальный Liquid Glass (`GlassEffectContainer`) |
| **Wallpaper Studio** | Доступно (импорт, обрезка, экспорт в Photos) | Доступно | Доступно |
| **Live Photo Maker** | Полная поддержка (AVFoundation + MakerNote) | Полная поддержка | Полная поддержка |
| **Tendies Manager** | Полный парсинг, валидация, распаковка, экспорт | Полный парсинг + установка через Nugget/Cowabunga | Полный парсинг |
| **WidgetKit** | Стандартный `WidgetKit` (Small, Medium, Large) | Стандартный `WidgetKit` + Lock Screen виджеты | Интерактивные виджеты |
| **Alternate Icons** | Поддерживается публичным API `setAlternateIconName` | Поддерживается | Поддерживается |
