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
3. [Repository Struktur](#-repository-struktur)
4. [Skript erklärungen](#-skript-erklärungen)
5. [Testfälle](#-testfälle)
6. [FAQ](#-faq)
7. [Reflexion](#-reflexion)
 
## ✅ Voraussetzungen
 
Bevor Sie starten, stellen Sie sicher, dass folgende Anforderungen erfüllt sind:
 
- Ein AWS-Account mit administrativen Berechtigungen.
 
- AWS CLI ist installiert und konfiguriert. 
	* Hilfestellung zur Installation und Konfiguration: [GBSSG Gitlab m364](https://gbssg.gitlab.io/m346/iac-aws-cli/)
 
- Git ist installiert.
 
- Ein Webbrowser für den Zugriff auf die WordPress-Seite.
 
## 🚀 Installation
 
### 1. Repository klonen
 
Klonen Sie dieses Repository auf Ihren lokalen Rechner:
 
```bash
git clone https://github.com/JoSi-git/m346.git
 
cd <pfad-zum-repository>
```
 
Ausführberechtigungen anpassen:
 
```bash
chmod +x install.sh
```
das holz
Script ausführen:
```bash
./install.sh
```
## 📂 Repository Struktur  
 
### 🛠️ 1. config_files  
 
Enthält Konfigurationsdateien, die für Dienste und Anwendungen wie WordPress benötigt werden.  
 
Es gibt einen Unterordner **`wordpress_files`**, der spezifische Konfigurations- oder Installationsskripte für WordPress enthält:  
 
- **mysqlinstall.sh:** Skript zur Installation/Konfiguration von MySQL.  
 
- **wpinstall.sh:** Skript zur Installation/Einrichtung von WordPress.  
 
---
 
### ⚙️ 2. Scripts  
 
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
 
## 📜 Skript erklärungen  
 
Unsere Skripts werden hier noch im detail erklärt.
 
### 📝 install.sh  
 
1. Elastic IP Konfiguration Funktion
 
    * Eine Funktion **`configure_elastic_ip`** fragt den Nutzer, ob eine Elastic IP (statische öffentliche IP-Adresse für AWS EC2-Instanzen) konfiguriert werden soll  
 
    * Falls der Nutzer **`j (Ja)`** eingibt, wird das Skript elastic-ip.sh ausgeführt  
 
    * Bei **`n (Nein)`** wird die Konfiguration übersprungen  
 
2. Initialisierung des MySQL-Servers & Webservers
 
    * Das Skript **`initialize-mysql-instance.sh`** & **`initialize-web-instance.sh`**  wird dann ausgeführt, um eine EC2-Instanz als MySQL-Server und auch als Webserver einzurichten  
 
3. Initialisierung Elastic-IP
 
    * Nachdem der Webserver und der MySQL-Server-Konfiguriert wurde, wird bei bedarf eine Elastic IP hinzugefügt
---
 
### 📜 mysqlinstall.sh  
 
1. Update der Paketliste
 
    * Das Skript updated zuerst alle Pakete mit dem **`sudo apt upgrade -y`** Befehl  
 
2. MySQL-Server Installation
 
    * Installiert den MySQL-Server, der das Datenbankmanagementsystem bereitstellt
3. Start des MySQL-Dienstes**
 
    * Startet den MySQL-Dienst, damit die MySQL-Datenbank sofort läuft.
---
### 📝 variables.sh
 
1. Variablen vergabe:  
 
    * SLEEP_DURATION    -> 20
 
    * KEY_NAME          -> djs-key
 
    * SEC_GROUP_NAME    -> djs-sec-group
 
    * CONFIG_STEP       -> 1                       
---
### 📜 wpinstall.sh  
 
1. Aktualisieren der Paketliste
 
    * Installiert die neusten Pakete mit dem **`sudo apt upgrade Befehl`**
 
2. Installation Apache2
 
    * Der Apache dienst wird mit **`sudo systemctl start apache2`** gestartet
 
3. Apache-Dienst beim Booten aktivieren
 
    * Apache wird mit **`sudo systemctl enable apache2`** in den Systemautostart hinzugefügt
 
4. Apache Status überprüfen
 
    * Status abfrage mit **`sudo systemctl status apache2`**
 
---
 
### 📝  del-script.sh
 
1. EC2-Instanzen suchen und beenden
 
    * Findet EC2-Instanzen, die mit der Sicherheitsgruppe **`$SEC_GROUP_NAME`** verknüpft sind
 
    * Beendet und löscht die gefundenen Instanzen
 
2. Sicherheitsgruppe löschen, Key Pair löschen und Elastic IPs freigeben
 
    * Löscht die definierte Sicherheitsgruppe, falls diese existiert
 
    * Löscht das  Key-Pair **`$KEY_NAME`** aus AWS und entfernt die lokale Kopie des zugehörigen **`.pem`** Schlüssels
 
    * Holt alle Elastic IPs und gibt sie wieder frei
 
3. Konfigurationsdatei aktualisieren
 
    * Löscht die alte **`ariables.sh-Datei.`** und erstellt sie wieder neu mit den Standardwerten
 
---
 
### 📜 elastic-ip.sh  
 
1. Automatisierung der Zuweisung von Elastic IPs an AWS EC2-Instanzen
 
2. Verhindert redundante Konfigurationen durch den Status **`CONFIG_STEP`**
 
3. Aktualisiert die Konfigurationsdatei dynamisch, um den Überblick über öffentliche IPs zu behalten
 
---
 
### 📝 initialize-mysql-instance.sh  
 
1. Prüft Verzeichnis und das MySQL-Installationsskript
 
    * Erstellt das Verzeichnis ~/ec2mysqlserver, falls es nicht existiert.
 
    * Prüft und ob mysqlinstall.sh existiert, das später auf der EC2-Instanz ausgeführt wird.
 
2. Startet eine neue EC2-Instanz
 
3. Initialisierung der Instanz abwarten
 
    * Wartet für die Dauer von der **`$SLEEP_DURATION`** dauer die im **`variables.sh`** angegeben ist
 
4. MySQL-Installationsskript übertragen und ausführen
 
    * Kopiert die Dateien **`mysqlinstall.sh`** und **`variables.sh`** via SCP auf die EC2-Instanz.
 
    * Führt das Skript via. SSH auf dem System aus
 
5. Ausgabe der Instanzinformationen und Aktualisieren der Konfigurationsdatei
 
    * Gibt die Instanz-ID und die öffentliche IP-Adresse in einer Tabelle aus.
 
    * Schreibt die ermittelte **`INSTANCE_ID1, PUBLIC_IP1 und MySQL_installation_File`** in die Datei **`variables.sh.`**
 
---
 
### 📜 initialize-web-instance.sh  
 
1. Verzeichnis erstellen und WordPress-Installationsskript prüfen
    * Erstellt das Verzeichnis **`~/ec2webserver`**, falls es nicht existiert.
    * Überprüft, ob die Datei wpinstall.sh im Verzeichnis **`./config_files/`** existiert.  
 
2. EC2-Instanz starten und die IP der Instanz ermitteln
    * Holt die Public IP der gestarteten Instanz.
 
3. Initialisierung der Instanz abwarten
 
    * Wartet für die Dauer von der **`$SLEEP_DURATION`** dauer die im **`variables.sh`** angegeben ist
 
4. Web-Installationsskript übertragen und ausführen
 
    * Kopiert die Dateien **`mysqlinstall.sh`** und **`variables.sh`** via SCP auf die EC2-Instanz.
 
5. Ausgabe der Instanzinformationen und Aktualisieren der Konfigurationsdatei
 
    * Gibt die Instanz-ID und die öffentliche IP-Adresse in einer Tabelle aus.
 
    * Schreibt die ermittelte **`INSTANCE_ID2, PUBLIC_IP2`** und **`Wordpress_installation_File`** in die Datei **`variables.sh.`**
 
---
 
### 📝 sec-key.sh
 
1. Key Pair erstellung und abspeicherung
    * Generiert ein neues Key Pair, falls es nicht existiert, und speichert es lokal für die Nutzung mit EC2-Instanzen.
2. Sicherheitsgruppen konfiguration und erstellung
    * Erstellt eine Sicherheitsgruppe mit HTTP- und SSH-Zugriffsregeln, falls diese nicht vorhanden ist.
 
## 🚀 Testfälle

### Test 1: Installation und Konfiguration der WordPress-Instanz

Testzeitpunkt: 15:15 Freitag 20/12/24

Testperson: Silas

Spezifische Informationen: Die AWS-Instanz wurde mit den Standard-WordPress-Einstellungen konfiguriert.

Testergebnisse: 

Ergebnis: Die WordPress-Instanz wurde erfolgreich installiert.

Screenshots:
    
![alt text](images/image1.png)
    
Fazit: Die Installation verlief wie erwartet, ohne Fehler. 

Empfehlung: Sicherstellen, dass alle Sicherheitsupdates vor der Produktivsetzung angewendet werden.
 
### Test 2: Verbindung zwischen WordPress und MySQL-Server

Testzeitpunkt: 15:39 Freitag 20/12/24

Testperson: Silas

Spezifische Informationen: Die MySQL-Datenbank wurde mit den in der Variablen-Datei angegebenen Werten konfiguriert.

Testergebnisse:

Ergebnis: Die Verbindung zwischen WordPress und MySQL war stabil und konnte ohne probleme eingerichtet werden.

Screenshots:

![alt text](images/image2.png)

Fazit: Die Verbindung funktioniert einwandfrei, es gab keine Verbindungsabbrüche. Links sieht man auch die posts mit mysqlworkbench.
        
Empfehlung: Regelmäßige Backups der MySQL-Datenbank erstellen, um Datenverlust zu vermeiden.

### Test 3: Funktionalität des WordPress-Logins

Testzeitpunkt: 15:54 Freitag 20/12/24

Testperson: Silas

Spezifische Informationen: Test der WordPress-Login-Funktion mit einem Admin-Benutzer, um sicherzustellen, dass der Zugriff korrekt funktioniert.
    
Testergebnisse:

Ergebnis: Der Login war erfolgreich, der Admin-Bereich konnte ohne Probleme aufgerufen werden.

Screenshots: 

![alt text](images/image3.png)

![alt text](images/image4.png)

![alt text](images/image5.png)

Fazit: Die Login-Funktion von WordPress funktioniert wie erwartet.

Empfehlung: Keine weiteren Maßnahmen erforderlich, da der Test erfolgreich war.

## ❓ FAQ
(von Jonas:  
##Bei Problemen: aws zugangskonfiguration überprüfen del-script.sh ausführen  
##Bei Problemen mit dem SSH Key manuel den SSH Key löschen)
 
## 📖 Reflexion
Hier in diesem letzten Teil werden wir noch unsere Reflexionen anbringen.
 
### 💡 [Jonas Sieber](https://github.com/josi-git "Jonas Sieber's GitHub Profile")
 
### 💭 [David Kästli](https://github.com/dka-stat "David Kästli's GitHub Profile")
 
Dieses Projekt war eine sehr bereichernde Erfahrung. Wir hatten die Gelegenheit, uns intensiv mit Themen wie Git und WordPress auseinanderzusetzen und dabei sowohl technische als auch methodische Fähigkeiten zu erweitern. Besonders wertvoll war die Teamarbeit:  
Gemeinsam haben wir neues Wissen aufgebaut, Herausforderungen gemeistert und voneinander gelernt.  
Ich bin sehr zufrieden mit unserem Endprodukt. Es spiegelt die harte Arbeit und den Einsatz wider, den wir investiert haben.
 
### ✨ [Silas Gubler](https://github.com/arkaizn "Silas Gubler's GitHub Profile")
 
 Ich fand es echt spannend, im Projekt mit der zentralen Speicherung von Variablen zu arbeiten. Dadurch war es viel einfacher, einheitliche Werte in allen Scripts zu nutzen, was die ganze Arbeit effizienter gemacht hat. Besonders cool war, dass wir die Instanzen auf AWS so anpassen konnten, dass sie gut miteinander zusammenarbeiteten.
Die Herausforderungen lagen vor allem in der Synchronisation der IaC-Dateien und der Sicherheit. Aber durch gutes Teamwork haben wir das gut hinbekommen. Insgesamt habe ich viel gelernt, vor allem über Cloud-Management und Automatisierung, und bin zufrieden mit dem Ergebnis.