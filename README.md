# MiraiTV

![MiraiTV Logo](https://github.com/Saadiq8149/MiraiTV/blob/master/assets/logo.png)

A modern, cross-platform anime streaming application built with **Flutter**. Stream anime, sync with AniList, and track your progress automatically.

## ✨ Features

- **Stream Anime** - High-quality playback with integrated sources
- **AniList Integration** - Sync your watchlist and track progress automatically
- **Continue Watching** - Resume from where you left off
- **Auto-Progress Sync** - Progress updates to AniList at 80% completion
- **Dark Theme** - Beautiful UI with Windows 11 acrylic effects (Windows only)
- **Cross-Platform** - Works on Windows, macOS, Linux, Android, and iOS
- **Pull-to-Refresh** - Reload content with a simple swipe
- **Watch Status Badges** - Track Current, Planning, and Completed anime

## 🛠️ Tech Stack

- **Flutter** & **Dart** - Cross-platform framework
- **AniList GraphQL API** - Anime database & user sync
- **media_kit** - Video playback
- **OAuth 2.0** - Secure authentication
- **SharedPreferences** - Local storage

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (latest stable)
- Dart 3.0+

### Installation

```bash
git clone https://github.com/Saadiq8149/MiraiTV.git
cd MiraiTV
flutter pub get
flutter run
```

### Configure AniList API

1. Create an app at [AniList Developer Settings](https://anilist.co/settings/developer)
2. Update `lib/api/anilist.dart`:
   ```dart
   const String _clientId = 'YOUR_CLIENT_ID';
   const String _redirectUri = 'YOUR_REDIRECT_URI';
   ```

## 📱 Platform Support

| Platform | Status |
|----------|--------|
| Windows | ✅ Full (with Acrylic UI) |
| macOS | ✅ Full |
| Linux | ✅ Full |
| Android | ✅ Full |
| iOS | ✅ Full |

## 🎯 Usage

1. **Login** - Click "Login with AniList" and authorize
2. **Browse** - Explore Trending, Top Rated, and Latest anime
3. **Watch** - Select anime and start streaming
4. **Track** - Progress syncs automatically to AniList

## 📊 Project Structure

```
lib/
├── api/anilist.dart          # AniList API integration
├── pages/                    # Home, Search, Details, Player
├── widgets/                  # Anime cards, sections, auth
├── utils/types.dart          # Data models
└── main.dart                 # Entry point
```

## 🔐 Authentication

MiraiTV uses **OAuth 2.0** for secure AniList login:
- Tokens stored locally via SharedPreferences
- No passwords stored
- All communications HTTPS encrypted

## 🐛 Troubleshooting

**Login not working?**
- Verify Client ID and Redirect URI
- Check AniList developer settings

**Video not playing?**
- Check internet connection
- Ensure media_kit is initialized

**Progress not syncing?**
- Confirm you're logged in
- Watch at least 80% of episode

## 📚 Inspiration

This project is inspired by [ani-cli](https://github.com/pystardust/ani-cli) - a command-line anime streaming tool. MiraiTV brings a similar experience to desktop and mobile with a modern GUI and AniList integration.

## 📄 License

MIT License - see LICENSE file for details

## ⚠️ Legal Notice

MiraiTV is for personal use only. Users are responsible for ensuring they have the right to watch anime from integrated sources.

## 🤝 Contributing

Contributions welcome! Fork, create a feature branch, commit, and open a PR.

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/Saadiq8149/MiraiTV/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Saadiq8149/MiraiTV/discussions)

---

**Made with ❤️ for anime enthusiasts**