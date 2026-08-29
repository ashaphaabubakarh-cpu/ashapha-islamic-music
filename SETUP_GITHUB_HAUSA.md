# Yadda za a gina APK/AAB ba tare da kwamfuta ba (ta wayar Android)

## Mataki 1: Ka kirkiri GitHub account
1. Bude Chrome, je github.com
2. Danna "Sign up", yi rejista da imel dinka

## Mataki 2: Ka kirkiri sabon repository
1. Bayan ka shiga, danna "+" a sama-dama > "New repository"
2. Sunan repo: ashapha-islamic-music
3. Zaba "Private" (don kariya)
4. Danna "Create repository"

## Mataki 3: Bude Codespace (wannan shine "kwamfuta a cloud" naka)
1. A shafin repo dinka, danna maballin kore "Code"
2. Zaba tab din "Codespaces"
3. Danna "Create codespace on main"
4. Jira ya loda (zai bude VS Code a browser dinka)

## Mataki 4: Loda fayil din project
1. A cikin Codespace, a hagu akwai "Explorer" (jerin fayiloli)
2. Danna dama a kan sararin fayiloli > "Upload..." (ko amfani da icon na upload a sama)
3. Zaba fayil din ashapa_music_full.zip daga wayarka
4. Bude "Terminal" (daga menu ko Ctrl+`) a cikin Codespace
5. Rubuta:
   unzip ashapa_music_full.zip -d .
   mv ashapa_music/* . && mv ashapa_music/.[^.]* . 2>/dev/null; rm -rf ashapa_music ashapa_music_full.zip

## Mataki 5: Aika code din zuwa GitHub (git push)
A cikin Terminal, rubuta daya-daya:
   git add -A
   git commit -m "Ashapha Islamic Music source"
   git push

## Mataki 6: Jira GitHub Actions ya gina APK/AAB
1. Koma shafin repo a github.com (waje da Codespace)
2. Danna tab din "Actions" a sama
3. Za ka ga aikin "Build Ashapha Islamic Music APK & AAB" yana gudana (dot orange = yana aiki, ja alama = kuskure, kore = an gama)
4. Jira minti 5-10
5. Idan kore ne, danna kan aikin, gungura kasa zuwa "Artifacts"
6. Danna "ashapha-islamic-music-apk" don zazzage APK dinka!
