import os
import hashlib

def gid(name):
    return hashlib.md5(name.encode('utf-8')).hexdigest()[:24].upper()

app_sources = [
    "App/iOSStudioApp.swift",
    "Core/Design/NativeCardStyle.swift",
    "Core/Design/ThemeManager.swift",
    "Core/Models/AppModels.swift",
    "Core/Storage/AppStorageManager.swift",
    "Core/Extensions/DocumentPickers.swift",
    "Features/Home/HomeDashboardView.swift",
    "Features/WallpaperStudio/WallpaperStudioView.swift",
    "Features/WallpaperStudio/WallpaperDetailEditorView.swift",
    "Features/TendiesManager/TendiesManagerView.swift",
    "Features/IconStudio/IconStudioView.swift",
    "Features/WidgetStudio/WidgetStudioView.swift",
    "Features/ThemeStudio/ThemeStudioView.swift",
    "Features/ShortcutsSettings/ShortcutsSettingsView.swift",
    "Features/Settings/SettingsRootView.swift",
    "Services/SystemInspector/SystemInspector.swift",
    "Services/TendiesParser/TendiesParser.swift",
    "Services/LivePhoto/LivePhotoCreator.swift",
    "Services/IconExporter/IconExporter.swift",
]

widget_sources = [
    "iOSStudioWidget.swift"
]

test_sources = [
    "iOSStudioTests.swift"
]

# We will construct a clean valid PBXProject
out = []
out.append('// !$*UTF8*$!')
out.append('{')
out.append('\tarchiveVersion = 1;')
out.append('\tclasses = {')
out.append('\t};')
out.append('\tobjectVersion = 54;')
out.append('\tobjects = {')

# 1. PBXBuildFile
out.append('/* Begin PBXBuildFile section */')
for f in app_sources:
    out.append(f'\t\t{gid("build_"+f)} /* {os.path.basename(f)} in Sources */ = {{isa = PBXBuildFile; fileRef = {gid("ref_"+f)} /* {os.path.basename(f)} */; }};')
out.append(f'\t\t{gid("build_app_assets")} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {gid("ref_app_assets")} /* Assets.xcassets */; }};')

for f in widget_sources:
    out.append(f'\t\t{gid("build_widget_"+f)} /* {os.path.basename(f)} in Sources */ = {{isa = PBXBuildFile; fileRef = {gid("ref_widget_"+f)} /* {os.path.basename(f)} */; }};')
out.append(f'\t\t{gid("build_widget_assets")} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {gid("ref_widget_assets")} /* Assets.xcassets */; }};')

for f in test_sources:
    out.append(f'\t\t{gid("build_test_"+f)} /* {os.path.basename(f)} in Sources */ = {{isa = PBXBuildFile; fileRef = {gid("ref_test_"+f)} /* {os.path.basename(f)} */; }};')

# App embed widget
out.append(f'\t\t{gid("build_embed_widget")} /* iOSStudioWidgetExtension.appex in Embed Foundation Extensions */ = {{isa = PBXBuildFile; fileRef = {gid("product_widget")} /* iOSStudioWidgetExtension.appex */; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};')
out.append('/* End PBXBuildFile section */')

# 2. PBXContainerItemProxy
out.append('/* Begin PBXContainerItemProxy section */')
out.append(f'\t\t{gid("proxy_widget")} /* PBXContainerItemProxy */ = {{')
out.append('\t\t\tisa = PBXContainerItemProxy;')
out.append(f'\t\t\tcontainerPortal = {gid("project")};')
out.append('\t\t\tproxyType = 1;')
out.append(f'\t\t\tremoteGlobalIDString = {gid("target_widget")};')
out.append('\t\t\tremoteInfo = iOSStudioWidgetExtension;')
out.append('\t\t};')
out.append(f'\t\t{gid("proxy_test")} /* PBXContainerItemProxy */ = {{')
out.append('\t\t\tisa = PBXContainerItemProxy;')
out.append(f'\t\t\tcontainerPortal = {gid("project")};')
out.append('\t\t\tproxyType = 1;')
out.append(f'\t\t\tremoteGlobalIDString = {gid("target_app")};')
out.append('\t\t\tremoteInfo = iOSStudio;')
out.append('\t\t};')
out.append('/* End PBXContainerItemProxy section */')

# 3. PBXCopyFilesBuildPhase
out.append('/* Begin PBXCopyFilesBuildPhase section */')
out.append(f'\t\t{gid("phase_embed_widget")} /* Embed Foundation Extensions */ = {{')
out.append('\t\t\tisa = PBXCopyFilesBuildPhase;')
out.append('\t\t\tbuildActionMask = 2147483647;')
out.append('\t\t\tdstPath = "";')
out.append('\t\t\tdstSubfolderSpec = 13;')
out.append('\t\t\tfiles = (')
out.append(f'\t\t\t\t{gid("build_embed_widget")} /* iOSStudioWidgetExtension.appex in Embed Foundation Extensions */,')
out.append('\t\t\t);')
out.append('\t\t\tname = "Embed Foundation Extensions";')
out.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
out.append('\t\t};')
out.append('/* End PBXCopyFilesBuildPhase section */')

# 4. PBXFileReference
out.append('/* Begin PBXFileReference section */')
for f in app_sources:
    out.append(f'\t\t{gid("ref_"+f)} /* {os.path.basename(f)} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{os.path.basename(f)}"; sourceTree = "<group>"; }};')
out.append(f'\t\t{gid("ref_app_assets")} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};')
out.append(f'\t\t{gid("ref_app_plist")} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};')
out.append(f'\t\t{gid("product_app")} /* iOSStudio.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = iOSStudio.app; sourceTree = BUILT_PRODUCTS_DIR; }};')

for f in widget_sources:
    out.append(f'\t\t{gid("ref_widget_"+f)} /* {os.path.basename(f)} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{os.path.basename(f)}"; sourceTree = "<group>"; }};')
out.append(f'\t\t{gid("ref_widget_assets")} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};')
out.append(f'\t\t{gid("ref_widget_plist")} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};')
out.append(f'\t\t{gid("product_widget")} /* iOSStudioWidgetExtension.appex */ = {{isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = iOSStudioWidgetExtension.appex; sourceTree = BUILT_PRODUCTS_DIR; }};')

for f in test_sources:
    out.append(f'\t\t{gid("ref_test_"+f)} /* {os.path.basename(f)} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{os.path.basename(f)}"; sourceTree = "<group>"; }};')
out.append(f'\t\t{gid("product_test")} /* iOSStudioTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = iOSStudioTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};')
out.append('/* End PBXFileReference section */')

# 5. PBXFrameworksBuildPhase
out.append('/* Begin PBXFrameworksBuildPhase section */')
out.append(f'\t\t{gid("frameworks_app")} /* Frameworks */ = {{')
out.append('\t\t\tisa = PBXFrameworksBuildPhase;')
out.append('\t\t\tbuildActionMask = 2147483647;')
out.append('\t\t\tfiles = (')
out.append('\t\t\t);')
out.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
out.append('\t\t};')
out.append(f'\t\t{gid("frameworks_widget")} /* Frameworks */ = {{')
out.append('\t\t\tisa = PBXFrameworksBuildPhase;')
out.append('\t\t\tbuildActionMask = 2147483647;')
out.append('\t\t\tfiles = (')
out.append('\t\t\t);')
out.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
out.append('\t\t};')
out.append(f'\t\t{gid("frameworks_test")} /* Frameworks */ = {{')
out.append('\t\t\tisa = PBXFrameworksBuildPhase;')
out.append('\t\t\tbuildActionMask = 2147483647;')
out.append('\t\t\tfiles = (')
out.append('\t\t\t);')
out.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
out.append('\t\t};')
out.append('/* End PBXFrameworksBuildPhase section */')

# 6. PBXGroup
out.append('/* Begin PBXGroup section */')
# Main Group
out.append(f'\t\t{gid("group_main")} = {{')
out.append('\t\t\tisa = PBXGroup;')
out.append('\t\t\tchildren = (')
out.append(f'\t\t\t\t{gid("group_app")} /* iOSStudio */,')
out.append(f'\t\t\t\t{gid("group_widget")} /* iOSStudioWidget */,')
out.append(f'\t\t\t\t{gid("group_test")} /* iOSStudioTests */,')
out.append(f'\t\t\t\t{gid("group_products")} /* Products */,')
out.append('\t\t\t);')
out.append('\t\t\tsourceTree = "<group>";')
out.append('\t\t};')

# Products Group
out.append(f'\t\t{gid("group_products")} /* Products */ = {{')
out.append('\t\t\tisa = PBXGroup;')
out.append('\t\t\tchildren = (')
out.append(f'\t\t\t\t{gid("product_app")} /* iOSStudio.app */,')
out.append(f'\t\t\t\t{gid("product_widget")} /* iOSStudioWidgetExtension.appex */,')
out.append(f'\t\t\t\t{gid("product_test")} /* iOSStudioTests.xctest */,')
out.append('\t\t\t);')
out.append('\t\t\tname = Products;')
out.append('\t\t\tsourceTree = "<group>";')
out.append('\t\t};')

# App Subgroups: App, Core, Features, Services
app_children_refs = [f'{gid("ref_"+f)} /* {os.path.basename(f)} */,' for f in app_sources]
app_children_refs.append(f'{gid("ref_app_assets")} /* Assets.xcassets */,')
app_children_refs.append(f'{gid("ref_app_plist")} /* Info.plist */,')

out.append(f'\t\t{gid("group_app")} /* iOSStudio */ = {{')
out.append('\t\t\tisa = PBXGroup;')
out.append('\t\t\tchildren = (')
for c in app_children_refs:
    out.append(f'\t\t\t\t{c}')
out.append('\t\t\t);')
out.append('\t\t\tpath = iOSStudio;')
out.append('\t\t\tsourceTree = "<group>";')
out.append('\t\t};')

# Widget Group
out.append(f'\t\t{gid("group_widget")} /* iOSStudioWidget */ = {{')
out.append('\t\t\tisa = PBXGroup;')
out.append('\t\t\tchildren = (')
out.append(f'\t\t\t\t{gid("ref_widget_iOSStudioWidget.swift")} /* iOSStudioWidget.swift */,')
out.append(f'\t\t\t\t{gid("ref_widget_assets")} /* Assets.xcassets */,')
out.append(f'\t\t\t\t{gid("ref_widget_plist")} /* Info.plist */,')
out.append('\t\t\t);')
out.append('\t\t\tpath = iOSStudioWidget;')
out.append('\t\t\tsourceTree = "<group>";')
out.append('\t\t};')

# Test Group
out.append(f'\t\t{gid("group_test")} /* iOSStudioTests */ = {{')
out.append('\t\t\tisa = PBXGroup;')
out.append('\t\t\tchildren = (')
out.append(f'\t\t\t\t{gid("ref_test_iOSStudioTests.swift")} /* iOSStudioTests.swift */,')
out.append('\t\t\t);')
out.append('\t\t\tpath = iOSStudioTests;')
out.append('\t\t\tsourceTree = "<group>";')
out.append('\t\t};')
out.append('/* End PBXGroup section */')

# 7. PBXNativeTarget
out.append('/* Begin PBXNativeTarget section */')
# App Target
out.append(f'\t\t{gid("target_app")} /* iOSStudio */ = {{')
out.append('\t\t\tisa = PBXNativeTarget;')
out.append(f'\t\t\tbuildConfigurationList = {gid("config_list_app")} /* Build configuration list for PBXNativeTarget "iOSStudio" */;')
out.append('\t\t\tbuildPhases = (')
out.append(f'\t\t\t\t{gid("sources_app")} /* Sources */,')
out.append(f'\t\t\t\t{gid("frameworks_app")} /* Frameworks */,')
out.append(f'\t\t\t\t{gid("resources_app")} /* Resources */,')
out.append(f'\t\t\t\t{gid("phase_embed_widget")} /* Embed Foundation Extensions */,')
out.append('\t\t\t);')
out.append('\t\t\tbuildRules = (')
out.append('\t\t\t);')
out.append('\t\t\tdependencies = (')
out.append(f'\t\t\t\t{gid("dep_widget")} /* PBXTargetDependency */,')
out.append('\t\t\t);')
out.append('\t\t\tname = iOSStudio;')
out.append('\t\t\tproductName = iOSStudio;')
out.append(f'\t\t\tproductReference = {gid("product_app")} /* iOSStudio.app */;')
out.append('\t\t\tproductType = "com.apple.product-type.application";')
out.append('\t\t};')

# Widget Target
out.append(f'\t\t{gid("target_widget")} /* iOSStudioWidgetExtension */ = {{')
out.append('\t\t\tisa = PBXNativeTarget;')
out.append(f'\t\t\tbuildConfigurationList = {gid("config_list_widget")} /* Build configuration list for PBXNativeTarget "iOSStudioWidgetExtension" */;')
out.append('\t\t\tbuildPhases = (')
out.append(f'\t\t\t\t{gid("sources_widget")} /* Sources */,')
out.append(f'\t\t\t\t{gid("frameworks_widget")} /* Frameworks */,')
out.append(f'\t\t\t\t{gid("resources_widget")} /* Resources */,')
out.append('\t\t\t);')
out.append('\t\t\tbuildRules = (')
out.append('\t\t\t);')
out.append('\t\t\tdependencies = (')
out.append('\t\t\t);')
out.append('\t\t\tname = iOSStudioWidgetExtension;')
out.append('\t\t\tproductName = iOSStudioWidgetExtension;')
out.append(f'\t\t\tproductReference = {gid("product_widget")} /* iOSStudioWidgetExtension.appex */;')
out.append('\t\t\tproductType = "com.apple.product-type.app-extension";')
out.append('\t\t};')

# Test Target
out.append(f'\t\t{gid("target_test")} /* iOSStudioTests */ = {{')
out.append('\t\t\tisa = PBXNativeTarget;')
out.append(f'\t\t\tbuildConfigurationList = {gid("config_list_test")} /* Build configuration list for PBXNativeTarget "iOSStudioTests" */;')
out.append('\t\t\tbuildPhases = (')
out.append(f'\t\t\t\t{gid("sources_test")} /* Sources */,')
out.append(f'\t\t\t\t{gid("frameworks_test")} /* Frameworks */,')
out.append(f'\t\t\t\t{gid("resources_test")} /* Resources */,')
out.append('\t\t\t);')
out.append('\t\t\tbuildRules = (')
out.append('\t\t\t);')
out.append('\t\t\tdependencies = (')
out.append(f'\t\t\t\t{gid("dep_test")} /* PBXTargetDependency */,')
out.append('\t\t\t);')
out.append('\t\t\tname = iOSStudioTests;')
out.append('\t\t\tproductName = iOSStudioTests;')
out.append(f'\t\t\tproductReference = {gid("product_test")} /* iOSStudioTests.xctest */;')
out.append('\t\t\tproductType = "com.apple.product-type.bundle.unit-test";')
out.append('\t\t};')
out.append('/* End PBXNativeTarget section */')

# 8. PBXProject
out.append('/* Begin PBXProject section */')
out.append(f'\t\t{gid("project")} /* Project object */ = {{')
out.append('\t\t\tisa = PBXProject;')
out.append('\t\t\tattributes = {')
out.append('\t\t\t\tBuildIndependentTargetsInParallel = 1;')
out.append('\t\t\t\tLastUpgradeCheck = 1500;')
out.append('\t\t\t\tTargetAttributes = {')
out.append(f'\t\t\t\t\t{gid("target_app")} = {{')
out.append('\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;')
out.append('\t\t\t\t\t};')
out.append(f'\t\t\t\t\t{gid("target_widget")} = {{')
out.append('\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;')
out.append('\t\t\t\t\t};')
out.append(f'\t\t\t\t\t{gid("target_test")} = {{')
out.append('\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;')
out.append(f'\t\t\t\t\t\tTestTargetID = {gid("target_app")};')
out.append('\t\t\t\t\t};')
out.append('\t\t\t\t};')
out.append('\t\t\t};')
out.append(f'\t\t\tbuildConfigurationList = {gid("config_list_project")} /* Build configuration list for PBXProject "iOSStudio" */;')
out.append('\t\t\tcompatibilityVersion = "Xcode 14.0";')
out.append('\t\t\tdevelopmentRegion = en;')
out.append('\t\t\thasScannedForEncodings = 0;')
out.append('\t\t\tknownRegions = (')
out.append('\t\t\t\ten,')
out.append('\t\t\t\tBase,')
out.append('\t\t\t);')
out.append(f'\t\t\tmainGroup = {gid("group_main")};')
out.append(f'\t\t\tproductRefGroup = {gid("group_products")} /* Products */;')
out.append('\t\t\tprojectDirPath = "";')
out.append('\t\t\tprojectRoot = "";')
out.append('\t\t\ttargets = (')
out.append(f'\t\t\t\t{gid("target_app")} /* iOSStudio */,')
out.append(f'\t\t\t\t{gid("target_widget")} /* iOSStudioWidgetExtension */,')
out.append(f'\t\t\t\t{gid("target_test")} /* iOSStudioTests */,')
out.append('\t\t\t);')
out.append('\t\t};')
out.append('/* End PBXProject section */')

# 9. PBXResourcesBuildPhase
out.append('/* Begin PBXResourcesBuildPhase section */')
out.append(f'\t\t{gid("resources_app")} /* Resources */ = {{')
out.append('\t\t\tisa = PBXResourcesBuildPhase;')
out.append('\t\t\tbuildActionMask = 2147483647;')
out.append('\t\t\tfiles = (')
out.append(f'\t\t\t\t{gid("build_app_assets")} /* Assets.xcassets in Resources */,')
out.append('\t\t\t);')
out.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
out.append('\t\t};')
out.append(f'\t\t{gid("resources_widget")} /* Resources */ = {{')
out.append('\t\t\tisa = PBXResourcesBuildPhase;')
out.append('\t\t\tbuildActionMask = 2147483647;')
out.append('\t\t\tfiles = (')
out.append(f'\t\t\t\t{gid("build_widget_assets")} /* Assets.xcassets in Resources */,')
out.append('\t\t\t);')
out.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
out.append('\t\t};')
out.append(f'\t\t{gid("resources_test")} /* Resources */ = {{')
out.append('\t\t\tisa = PBXResourcesBuildPhase;')
out.append('\t\t\tbuildActionMask = 2147483647;')
out.append('\t\t\tfiles = (')
out.append('\t\t\t);')
out.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
out.append('\t\t};')
out.append('/* End PBXResourcesBuildPhase section */')

# 10. PBXSourcesBuildPhase
out.append('/* Begin PBXSourcesBuildPhase section */')
out.append(f'\t\t{gid("sources_app")} /* Sources */ = {{')
out.append('\t\t\tisa = PBXSourcesBuildPhase;')
out.append('\t\t\tbuildActionMask = 2147483647;')
out.append('\t\t\tfiles = (')
for f in app_sources:
    out.append(f'\t\t\t\t{gid("build_"+f)} /* {os.path.basename(f)} in Sources */,')
out.append('\t\t\t);')
out.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
out.append('\t\t};')

out.append(f'\t\t{gid("sources_widget")} /* Sources */ = {{')
out.append('\t\t\tisa = PBXSourcesBuildPhase;')
out.append('\t\t\tbuildActionMask = 2147483647;')
out.append('\t\t\tfiles = (')
for f in widget_sources:
    out.append(f'\t\t\t\t{gid("build_widget_"+f)} /* {os.path.basename(f)} in Sources */,')
out.append('\t\t\t);')
out.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
out.append('\t\t};')

out.append(f'\t\t{gid("sources_test")} /* Sources */ = {{')
out.append('\t\t\tisa = PBXSourcesBuildPhase;')
out.append('\t\t\tbuildActionMask = 2147483647;')
out.append('\t\t\tfiles = (')
for f in test_sources:
    out.append(f'\t\t\t\t{gid("build_test_"+f)} /* {os.path.basename(f)} in Sources */,')
out.append('\t\t\t);')
out.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
out.append('\t\t};')
out.append('/* End PBXSourcesBuildPhase section */')

# 11. PBXTargetDependency
out.append('/* Begin PBXTargetDependency section */')
out.append(f'\t\t{gid("dep_widget")} /* PBXTargetDependency */ = {{')
out.append('\t\t\tisa = PBXTargetDependency;')
out.append(f'\t\t\ttarget = {gid("target_widget")} /* iOSStudioWidgetExtension */;')
out.append(f'\t\t\ttargetProxy = {gid("proxy_widget")} /* PBXContainerItemProxy */;')
out.append('\t\t};')
out.append(f'\t\t{gid("dep_test")} /* PBXTargetDependency */ = {{')
out.append('\t\t\tisa = PBXTargetDependency;')
out.append(f'\t\t\ttarget = {gid("target_app")} /* iOSStudio */;')
out.append(f'\t\t\ttargetProxy = {gid("proxy_test")} /* PBXContainerItemProxy */;')
out.append('\t\t};')
out.append('/* End PBXTargetDependency section */')

# 12. XCBuildConfiguration
out.append('/* Begin XCBuildConfiguration section */')
# Project Debug
out.append(f'\t\t{gid("proj_debug")} /* Debug */ = {{')
out.append('\t\t\tisa = XCBuildConfiguration;')
out.append('\t\t\tbuildSettings = {')
out.append('\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
out.append('\t\t\t\tCLANG_ANALYZER_NONNULL = YES;')
out.append('\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";')
out.append('\t\t\t\tCLANG_ENABLE_MODULES = YES;')
out.append('\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
out.append('\t\t\t\tCOPY_PHASE_STRIP = NO;')
out.append('\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;')
out.append('\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
out.append('\t\t\t\tENABLE_TESTABILITY = YES;')
out.append('\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;')
out.append('\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;')
out.append('\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = ("DEBUG=1", "$(inherited)", );')
out.append('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;')
out.append('\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;')
out.append('\t\t\t\tONLY_ACTIVE_ARCH = YES;')
out.append('\t\t\t\tSDKROOT = iphoneos;')
out.append('\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;')
out.append('\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";')
out.append('\t\t\t};')
out.append('\t\t\tname = Debug;')
out.append('\t\t};')

# Project Release
out.append(f'\t\t{gid("proj_release")} /* Release */ = {{')
out.append('\t\t\tisa = XCBuildConfiguration;')
out.append('\t\t\tbuildSettings = {')
out.append('\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
out.append('\t\t\t\tCLANG_ANALYZER_NONNULL = YES;')
out.append('\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";')
out.append('\t\t\t\tCLANG_ENABLE_MODULES = YES;')
out.append('\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
out.append('\t\t\t\tCOPY_PHASE_STRIP = NO;')
out.append('\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
out.append('\t\t\t\tENABLE_NS_ASSERTIONS = NO;')
out.append('\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
out.append('\t\t\t\tGCC_OPTIMIZATION_LEVEL = s;')
out.append('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;')
out.append('\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;')
out.append('\t\t\t\tSDKROOT = iphoneos;')
out.append('\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;')
out.append('\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";')
out.append('\t\t\t\tVALIDATE_PRODUCT = YES;')
out.append('\t\t\t};')
out.append('\t\t\tname = Release;')
out.append('\t\t};')

# Target App Debug & Release
for cname, is_debug in [("Debug", True), ("Release", False)]:
    out.append(f'\t\t{gid("app_"+cname)} /* {cname} */ = {{')
    out.append('\t\t\tisa = XCBuildConfiguration;')
    out.append('\t\t\tbuildSettings = {')
    out.append('\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
    out.append('\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;')
    out.append('\t\t\t\tCODE_SIGNING_ALLOWED = NO;')
    out.append('\t\t\t\tCODE_SIGNING_REQUIRED = NO;')
    out.append('\t\t\t\tCODE_SIGN_IDENTITY = "";')
    out.append('\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
    out.append('\t\t\t\tGENERATE_INFOPLIST_FILE = NO;')
    out.append('\t\t\t\tINFOPLIST_FILE = iOSStudio/Info.plist;')
    out.append('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;')
    out.append('\t\t\t\tLD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks");')
    out.append('\t\t\t\tMARKETING_VERSION = 1.0.0;')
    out.append('\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.iosstudio.app;')
    out.append('\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
    out.append('\t\t\t\tSWIFT_VERSION = 5.0;')
    out.append('\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";')
    out.append('\t\t\t};')
    out.append(f'\t\t\tname = {cname};')
    out.append('\t\t};')

# Target Widget Debug & Release
for cname, is_debug in [("Debug", True), ("Release", False)]:
    out.append(f'\t\t{gid("widget_"+cname)} /* {cname} */ = {{')
    out.append('\t\t\tisa = XCBuildConfiguration;')
    out.append('\t\t\tbuildSettings = {')
    out.append('\t\t\t\tCODE_SIGNING_ALLOWED = NO;')
    out.append('\t\t\t\tCODE_SIGNING_REQUIRED = NO;')
    out.append('\t\t\t\tCODE_SIGN_IDENTITY = "";')
    out.append('\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
    out.append('\t\t\t\tGENERATE_INFOPLIST_FILE = NO;')
    out.append('\t\t\t\tINFOPLIST_FILE = iOSStudioWidget/Info.plist;')
    out.append('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;')
    out.append('\t\t\t\tLD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks", "@executable_path/../../Frameworks");')
    out.append('\t\t\t\tMARKETING_VERSION = 1.0.0;')
    out.append('\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.iosstudio.app.widget;')
    out.append('\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
    out.append('\t\t\t\tSKIP_INSTALL = YES;')
    out.append('\t\t\t\tSWIFT_VERSION = 5.0;')
    out.append('\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";')
    out.append('\t\t\t};')
    out.append(f'\t\t\tname = {cname};')
    out.append('\t\t};')

# Target Test Debug & Release
for cname, is_debug in [("Debug", True), ("Release", False)]:
    out.append(f'\t\t{gid("test_"+cname)} /* {cname} */ = {{')
    out.append('\t\t\tisa = XCBuildConfiguration;')
    out.append('\t\t\tbuildSettings = {')
    out.append('\t\t\t\tBUNDLE_LOADER = "$(TEST_HOST)";')
    out.append('\t\t\t\tCODE_SIGNING_ALLOWED = NO;')
    out.append('\t\t\t\tCODE_SIGNING_REQUIRED = NO;')
    out.append('\t\t\t\tCODE_SIGN_IDENTITY = "";')
    out.append('\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
    out.append('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;')
    out.append('\t\t\t\tMARKETING_VERSION = 1.0.0;')
    out.append('\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.iosstudio.app.tests;')
    out.append('\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
    out.append('\t\t\t\tSWIFT_VERSION = 5.0;')
    out.append('\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";')
    out.append('\t\t\t\tTEST_HOST = "$(BUILT_PRODUCTS_DIR)/iOSStudio.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/iOSStudio";')
    out.append('\t\t\t};')
    out.append(f'\t\t\tname = {cname};')
    out.append('\t\t};')
out.append('/* End XCBuildConfiguration section */')

# 13. XCConfigurationList
out.append('/* Begin XCConfigurationList section */')
out.append(f'\t\t{gid("config_list_project")} /* Build configuration list for PBXProject "iOSStudio" */ = {{')
out.append('\t\t\tisa = XCConfigurationList;')
out.append('\t\t\tbuildConfigurations = (')
out.append(f'\t\t\t\t{gid("proj_debug")} /* Debug */,')
out.append(f'\t\t\t\t{gid("proj_release")} /* Release */,')
out.append('\t\t\t);')
out.append('\t\t\tdefaultConfigurationIsVisible = 0;')
out.append('\t\t\tdefaultConfigurationName = Release;')
out.append('\t\t};')

out.append(f'\t\t{gid("config_list_app")} /* Build configuration list for PBXNativeTarget "iOSStudio" */ = {{')
out.append('\t\t\tisa = XCConfigurationList;')
out.append('\t\t\tbuildConfigurations = (')
out.append(f'\t\t\t\t{gid("app_Debug")} /* Debug */,')
out.append(f'\t\t\t\t{gid("app_Release")} /* Release */,')
out.append('\t\t\t);')
out.append('\t\t\tdefaultConfigurationIsVisible = 0;')
out.append('\t\t\tdefaultConfigurationName = Release;')
out.append('\t\t};')

out.append(f'\t\t{gid("config_list_widget")} /* Build configuration list for PBXNativeTarget "iOSStudioWidgetExtension" */ = {{')
out.append('\t\t\tisa = XCConfigurationList;')
out.append('\t\t\tbuildConfigurations = (')
out.append(f'\t\t\t\t{gid("widget_Debug")} /* Debug */,')
out.append(f'\t\t\t\t{gid("widget_Release")} /* Release */,')
out.append('\t\t\t);')
out.append('\t\t\tdefaultConfigurationIsVisible = 0;')
out.append('\t\t\tdefaultConfigurationName = Release;')
out.append('\t\t};')

out.append(f'\t\t{gid("config_list_test")} /* Build configuration list for PBXNativeTarget "iOSStudioTests" */ = {{')
out.append('\t\t\tisa = XCConfigurationList;')
out.append('\t\t\tbuildConfigurations = (')
out.append(f'\t\t\t\t{gid("test_Debug")} /* Debug */,')
out.append(f'\t\t\t\t{gid("test_Release")} /* Release */,')
out.append('\t\t\t);')
out.append('\t\t\tdefaultConfigurationIsVisible = 0;')
out.append('\t\t\tdefaultConfigurationName = Release;')
out.append('\t\t};')
out.append('/* End XCConfigurationList section */')

out.append('\t};')
out.append(f'\trootObject = {gid("project")} /* Project object */;')
out.append('}')

os.makedirs('iOSStudio/iOSStudio.xcodeproj', exist_ok=True)
with open('iOSStudio/iOSStudio.xcodeproj/project.pbxproj', 'w', encoding='utf-8') as f:
    f.write('\n'.join(out))
print('project.pbxproj generated successfully!')
