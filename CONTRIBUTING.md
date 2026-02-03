# Contributing
## Как забить проект?

## Как получить расписания для тестирования?
Репозиторий парсера: https://github.com/MaddoDev/RaspyParser
В README написано как запустить парсер на VPS, следуйте инструкциям.

Если у вас нет HTTPS подключения, то вы не сможете получить расписание из-за защитных механизмов Swift. Вы должны либо сделать https подключение, либо отключить защиту в Xcode. Вот пример Info.plist, чтоб исключить ip или домен на проверку HTTPS:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSExceptionDomains</key>
        <dict>
            <key>your_ip_or_domain</key>
            <dict>
                <key>NSExceptionAllowsInsecureHTTPLoads</key>
                <true/>
                <key>NSIncludesSubdomains</key>
                <true/>
            </dict>
        </dict>
    </dict>
</dict>
</plist> 
```

Также советую прописать данную команду, чтоб не палить ссылку или айпи вашего парсера:
```bash
git update-index --assume-unchanged Raspy/Parser/Config.swift
```
