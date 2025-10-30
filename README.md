# 🌸 MiraiTV

![MiraiTV Logo](https://github.com/Saadiq8149/MiraiTV/blob/master/assets/logo.png)

A modern, cross-platform anime streaming application built with **Flutter**. Watch your favorite anime with seamless playback, track your progress on AniList, and discover new shows with an intuitive interface.

## ✨ Features

### 📺 Core Functionality
- **Stream Anime** - Watch anime directly from integrated sources with high-quality playback
- **AniList Integration** - Sync your anime list, track watch progress, and manage your library
- **Continue Watching** - Resume from where you left off with automatic progress tracking
- **Episode Management** - Auto-play next episode, skip intros, and precise episode selection

### 🎨 User Interface
- **Dark Theme** - Beautiful Windows 11-style acrylic blur effect (Windows-exclusive)
- **Responsive Design** - Works seamlessly across desktop and mobile platforms
- **Intuitive Navigation** - Bottom tab bar for easy access to Home and Search
- **Custom AppBar** - MiraiTV branding with red accent styling

### 🔍 Discovery & Search
- **Trending Now** - Discover currently trending anime
- **Top Rated** - Browse highly-rated anime series
- **Latest Releases** - Stay updated with the newest anime episodes
- **Advanced Search** - Find anime by title, genre, and more

### 👤 User Management
- **AniList Authentication** - Secure OAuth login with AniList
- **Watch Status Tracking** - Current, Planning, and Completed status badges
- **Progress Synchronization** - Automatic progress updates at 80% video completion
- **Personal Watchlist** - Manage your anime library in one place

### 🎬 Video Player
- **Cross-Platform Playback** - Powered by media_kit for optimal performance
- **Auto-Progress Update** - Syncs watch progress to AniList automatically
- **Subtitle Support** - Built-in subtitle loading and display
- **Smooth Transitions** - Auto-play next episode with seamless experience

### 🔄 Additional Features
- **Pull-to-Refresh** - Reload all content with a simple pull gesture
- **Persistent Authentication** - Automatic login persistence via SharedPreferences
- **Network Optimization** - Efficient API calls and caching

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter, Dart |
| **Theming** | Google Fonts, Material Design |
| **State Management** | StatefulWidget, Provider |
| **API Integration** | AniList GraphQL API |
| **Video Playback** | media_kit |
| **Authentication** | OAuth 2.0 (url_launcher) |
| **Storage** | SharedPreferences |
| **Windows UI** | bitsdojo_window, flutter_acrylic |
| **WebView** | webviewx_plus |

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^5.0.0
  http: ^1.1.0
  media_kit: ^1.0.0
  media_kit_video: ^1.0.0
  shared_preferences: ^2.0.0
  url_launcher: ^6.2.0
  webviewx_plus: ^0.5.1+1
  bitsdojo_window: ^0.1.0
  flutter_acrylic: ^1.4.0
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart 3.0+
- An AniList API account for authentication

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Saadiq8149/MiraiTV.git
   cd MiraiTV
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure AniList API**
   - Create an app at [AniList Developer Settings](https://anilist.co/settings/developer)
   - Add your `Client ID` and `Redirect URI` to the auth configuration
   - Update the following in `lib/api/anilist.dart`:
     ```dart
     const String _clientId = 'YOUR_CLIENT_ID';
     const String _redirectUri = 'YOUR_REDIRECT_URI';
     ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **Windows** | ✅ Full Support | Acrylic blur effect enabled |
| **macOS** | ✅ Full Support | Native performance |
| **Linux** | ✅ Full Support | Lightweight experience |
| **Android** | ✅ Full Support | Optimized for mobile |
| **iOS** | ✅ Full Support | Optimized for mobile |
| **Web** | ⚠️ Partial | Limited video source support |

## 🎯 Usage

### Starting the App
1. Launch MiraiTV
2. **For first-time users**: Click "Login with AniList" on the home page
3. Authorize the application in your browser
4. Paste the authorization code in the input field
5. Start exploring and watching anime!

### Watching Anime
1. Navigate to Home or Search
2. Select an anime from the list
3. Click the **Play** button to start watching
4. Your progress is automatically synced to AniList

### Managing Your List
- **Continue Watching** section shows anime you're actively watching
- Watch status badges show: Currently Watching, Planning, or Completed
- Progress bars display current episode / total episodes

### Discovering Content
- **Home Page**: Trending, Top Rated, and Latest releases
- **Search**: Find specific anime by title
- **Filters**: Sort by year, rating, and status

## 🔐 Authentication

MiraiTV uses **OAuth 2.0** for secure AniList authentication:

1. Click "Login with AniList"
2. Authorize the application in your browser
3. The authorization code is automatically extracted and exchanged for an access token
4. Your session is stored locally and persists across app launches
5. Log out anytime from your profile settings

**Security Notes:**
- Access tokens are stored securely using SharedPreferences
- No passwords are stored locally
- All API communications are HTTPS encrypted

## 📊 API Integration

### AniList GraphQL
MiraiTV communicates with AniList via GraphQL queries:
- Fetch trending, top-rated, and latest anime
- Get user watchlist and progress
- Update watch status and episode progress
- Search anime by various criteria

### Video Sources
Video streaming is sourced from integrated providers, ensuring quality and reliability.

## 🎨 Customization

### Theme Configuration
Edit `lib/main.dart` to customize:
```dart
darkTheme: ThemeData.dark().copyWith(
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF0D0D0D),
    elevation: 0,
  ),
)
```

### Colors
- **Primary Background**: `#0D0D0D` (Dark Grey/Black)
- **Accent Color**: `Colors.redAccent`
- **Secondary**: `Colors.grey[600]` (Light Grey)

## 🐛 Troubleshooting

### "WebView platform not initialized" Error
**Solution**: The app automatically initializes platform-specific WebView implementations. If you encounter this on startup:
```bash
flutter clean
flutter pub get
flutter run
```

### AniList Login Not Working
**Solution**: 
- Verify your Client ID and Redirect URI are correct
- Ensure your AniList app is authorized in developer settings
- Clear app cache and try again

### Video Playback Issues
**Solution**:
- Check your internet connection
- Ensure media_kit is properly initialized
- Try clearing the app cache

### Progress Not Syncing
**Solution**:
- Ensure you're logged in with AniList
- Watch at least 80% of the episode
- Check your internet connection

## 📝 Project Structure

```
lib/
├── api/
│   └── anilist.dart          # AniList API integration
├── pages/
│   ├── home.dart             # Home page with sections
│   ├── search.dart           # Search functionality
│   ├── anime_details.dart    # Anime detail view
│   └── video_player.dart     # Video player page
├── widgets/
│   ├── anime_card.dart       # Anime card widget
│   ├── anime_section.dart    # Section container
│   └── auth_handler.dart     # Authentication UI
├── utils/
│   └── types.dart            # Data models
└── main.dart                 # Entry point
```

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Legal Notice

MiraiTV is for personal use only. Users are responsible for ensuring they have the right to watch anime from integrated sources. This application is not affiliated with or endorsed by AniList or anime production studios.

## 🙏 Credits

- **AniList** - For the comprehensive anime database and API
- **Flutter Team** - For the amazing cross-platform framework
- **media_kit** - For reliable video playback
- **Community Contributors** - For feedback and improvements

## 📞 Support

For issues, feature requests, or questions:
- **GitHub Issues**: [MiraiTV Issues](https://github.com/Saadiq8149/MiraiTV/issues)
- **Discussions**: [MiraiTV Discussions](https://github.com/Saadiq8149/MiraiTV/discussions)

## 🌟 Show Your Support

If you find MiraiTV useful, please consider:
- ⭐ Starring the repository
- 🐛 Reporting bugs and suggesting features
- 📢 Sharing with the community
- 🤝 Contributing to the project

---

**Made with ❤️ for anime enthusiasts**

*Last Updated: October 30, 2025*