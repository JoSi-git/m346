# WordPress auf AWS – Setup-Anleitung
[![Silas Gubler](https://img.shields.io/badge/Silas_Gubler-FF4500?style=for-the-badge)](https://github.com/arkaizn)
[![David Kästli](https://img.shields.io/badge/David_Kästli-32CD32?style=for-the-badge)](https://github.com/dka-stat)
[![Jonas Sieber](https://img.shields.io/badge/Jonas_Sieber-1E90FF?style=for-the-badge)](https://github.com/josi-git)
[![Lizenz](https://img.shields.io/badge/Lizenz-FFD700?style=for-the-badge)](https://github.com/JoSi-git/m346/blob/main/LICENSE)


## 📜 Überblick
Diese Anleitung beschreibt die Schritte, um eine WordPress-Installation in der Amazon Web Services (AWS) Cloud bereitzustellen. Alle notwendigen Konfigurationsdateien und Skripte befinden sich in diesem Repository. Folgen Sie den untenstehenden Schritten, um die Installation nachzustellen.

## 📂 Inhaltsverzeichnis
1. [Voraussetzungen](#-voraussetzungen)
2. [Installation](#-installation)

## ✅ Voraussetzungen
Bevor Sie starten, stellen Sie sicher, dass folgende Anforderungen erfüllt sind:
- Ein AWS-Account mit administrativen Berechtigungen.
- AWS CLI ist installiert und konfiguriert.
- Terraform ist installiert (für Infrastructure as Code).
- Git ist installiert.
- Ein Webbrowser für den Zugriff auf die WordPress-Seite.

## 🚀 Installation
### 1. Repository klonen
Klonen Sie dieses Repository auf Ihren lokalen Rechner:
```bash
git clone https://github.com/JoSi-git/m364.git
cd <repository-name>
```
## 📂 Repository Struktur  

### 🛠️ 1. config_files  
Enthält Konfigurationsdateien, die für Dienste und Anwendungen wie WordPress benötigt werden.  
Es gibt einen Unterordner **`wordpress_files`**, der spezifische Konfigurations- oder Installationsskripte für WordPress enthält:  
- **mysqlinstall.sh:** Skript zur Installation/Konfiguration von MySQL.  
- **wpinstall.sh:** Skript zur Installation/Einrichtung von WordPress.  

---

### ⚙️ 2. scripts  
Beinhaltet verschiedene Shell-Skripte zur Automatisierung von Aufgaben. Beispiele sind:  
- **del-script.sh:** Ein Skript zum Löschen von Dateien und Ressourcen.  
- **elastic-ip.sh:** Bezieht sich auf die Verwaltung einer Elastic IP.  
- **initialize-mysql-instance.sh** & **initialize-web-instance.sh:** Skripte zur Initialisierung von MySQL-Datenbankinstanzen und Webserver-Instanzen.  

---

### 🚀 3. install.sh  
Ein zentrales Installationsskript, das mehrere der oben genannten Skripte zusammenführt und ausführt.  

---

### 🔧 4. Dokumentation und Verwaltungsdateien  
Hier sind die restlichen Standarddateien aufgelistet und Beschrieben:  

#### 🚫 .gitignore  
- Eine Datei zur Angabe von Dateien und Ordnern, die nicht in das Git-Repository aufgenommen werden sollen.  

#### 📜 LICENSE  
- Enthält Informationen zur Lizenzierung des Projekts.  

#### 📝 README.md  
- Eine Markdown-Datei, die normalerweise eine Erklärung des Projekts, der Struktur und der Verwendung enthält.  

---
