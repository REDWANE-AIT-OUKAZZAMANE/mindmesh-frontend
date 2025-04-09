# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Gson class
-keep class com.google.gson.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }

# Keep Google Play Core classes
-keep class com.google.android.play.core.** { *; }

# Keep your model classes
-keep class com.example.mindmesh.model.** { *; }

# Keep JWT
-keep class io.jsonwebtoken.** { *; } 