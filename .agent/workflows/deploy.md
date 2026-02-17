---
description: Deploy Flutter web app to GitHub Pages
---

// turbo-all

1. Build the Flutter web app for release:
```
flutter build web --release --base-href "/ev-taxi-web/"
```

2. Stage all changes and commit to main:
```
git add .
git commit -m "Update: <describe recent changes>"
git push origin main
```

3. Force-push the build/web folder to gh-pages branch:
```powershell
git push origin $(git subtree split --prefix build/web):gh-pages --force
```

4. Notify the user that the site is live at https://alkazim.github.io/ev-taxi-web/
