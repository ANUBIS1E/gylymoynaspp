# Инструкция по сборке Windows приложения с macOS

## Способ 1: GitHub Actions (РЕКОМЕНДУЕТСЯ)

Это самый простой способ собрать Windows приложение не имея Windows компьютера.

### Шаг 1: Создайте репозиторий на GitHub

```bash
cd /Users/andrewewps/Downloads/projects/gylymoynaspp

# Инициализируйте git (если еще не сделано)
git init

# Добавьте все файлы
git add .
git commit -m "Initial commit with training mode and AI hints"

# Создайте репозиторий на GitHub через веб-интерфейс
# Затем привяжите локальный репозиторий:
git remote add origin https://github.com/ВАШЕ_ИМЯ/gylymoynaspp.git
git branch -M main
git push -u origin main
```

### Шаг 2: Автоматическая сборка запустится

После push в репозиторий, GitHub Actions автоматически:
1. Создаст Windows виртуальную машину
2. Установит Flutter
3. Соберет приложение для Windows
4. Создаст ZIP архив

### Шаг 3: Скачайте готовое приложение

1. Откройте ваш репозиторий на GitHub
2. Перейдите во вкладку **Actions**
3. Выберите последний успешный workflow
4. Скачайте артефакт **windows-release**
5. Разархивируйте `gylymoynaspp-windows.zip`

### Шаг 4: Запуск вручную (опционально)

Если хотите пересобрать без нового commit:
1. GitHub → Actions → Build Windows Release
2. Нажмите **Run workflow** → **Run workflow**
3. Дождитесь завершения (~5-10 минут)
4. Скачайте артефакт

## Способ 2: Виртуальная машина (альтернатива)

### Использование Parallels Desktop (macOS)

1. Установите Parallels Desktop ($99/год, есть trial)
2. Скачайте Windows 11 ARM Insider Preview
3. Создайте виртуальную машину
4. Внутри Windows:
   ```bash
   # Установите Flutter
   # Склонируйте проект
   cd gylymoynaspp
   flutter pub get
   flutter build windows --release
   ```

### Использование UTM (бесплатно для macOS)

1. Установите UTM (бесплатно из App Store)
2. Создайте Windows VM
3. Аналогично Parallels - установите Flutter внутри Windows

## Способ 3: Удаленная Windows машина

### Аренда облачного Windows сервера

1. **AWS EC2 Windows Instance** (pay-as-you-go)
2. **Azure Windows VM** (бесплатные кредиты для новых пользователей)
3. **DigitalOcean Windows Droplet**

Подключитесь через Remote Desktop и соберите приложение.

## Способ 4: Сборка для macOS (если нужно локально)

Если вам нужно протестировать приложение локально на Mac:

```bash
cd /Users/andrewewps/Downloads/projects/gylymoynaspp

# Включите macOS desktop
flutter config --enable-macos-desktop

# Соберите для macOS
flutter build macos --release

# Приложение будет в:
# build/macos/Build/Products/Release/gylymoynaspp.app
```

## Рекомендация

**Используйте GitHub Actions (Способ 1)** - это:
- ✅ Бесплатно (2000 минут/месяц для публичных репозиториев)
- ✅ Не требует Windows компьютера
- ✅ Автоматическая сборка при каждом commit
- ✅ Можно скачать готовый EXE файл
- ✅ Работает из macOS

## Создание Release версии

Когда готовы выпустить версию:

```bash
# Создайте тег версии
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions автоматически создаст Release с прикрепленным Windows приложением!

## Проверка статуса сборки

После push на GitHub:
1. Откройте: https://github.com/ВАШЕ_ИМЯ/gylymoynaspp/actions
2. Увидите зеленую галочку ✅ (успех) или красный крестик ❌ (ошибка)
3. Кликните на workflow чтобы увидеть логи
4. Скачайте артефакт из секции **Artifacts**

## Структура собранного приложения

После разархивации `gylymoynaspp-windows.zip` вы получите:

```
gylymoynaspp.exe           # Основной исполняемый файл
flutter_windows.dll        # Flutter runtime
data/                      # Ресурсы приложения
  icudtl.dat
  flutter_assets/
    ...
```

**Важно**: Для распространения нужно передавать всю папку, не только `.exe` файл!

## Минимальные требования для Windows приложения

- Windows 10 или выше (64-bit)
- 100 MB свободного места
- 4 GB RAM рекомендуется

## Troubleshooting

### "Workflow не запускается"
- Проверьте что файл находится в `.github/workflows/build-windows.yml`
- Убедитесь что сделали `git push` (не только commit)

### "Build failed"
- Откройте логи workflow в GitHub Actions
- Частая проблема: зависимости в `pubspec.yaml` - убедитесь что все пакеты совместимы с Windows

### "Приложение не запускается на Windows"
- Передайте всю папку Release, не только EXE
- Проверьте что у пользователя Windows 10+
- Установите Visual C++ Redistributable если требуется

## Готово!

Теперь у вас есть полная настройка для сборки Windows приложения с macOS. Просто делайте `git push` и через 5-10 минут получайте готовое Windows приложение в артефактах GitHub Actions!
