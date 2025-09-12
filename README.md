![TLP](src/lib/config/logo_black_background.png)

# ToDo-List Prior (TLP) [English Version](#todo-list-prior-tlp-deutsche-version)

**ToDo-List Prior (TLP)** ist eine intelligente ToDo-App mit Fokus auf *automatischer Priorisierung*. Sie richtet sich an alle, die ihre Aufgaben strukturiert, effizient und fokussiert erledigen wollen – ohne sich mühsam durch endlose ToDo-Listen zu klicken.  

**Die .apk-Datei zur direkten Installation liegt hier im Stammverzeichnis bereit!**  
Einfach installieren, loslegen – alle Funktionen sind sofort nutzbar.

**TLP wurde im Rahmen einer Vorlesung der Hochschule Aalen entwickelt.**  
Entwicklerteam: Tobias Pöhle, Luzia Weinberger, Paul Frischeisen. 

---

## App-Beschreibung

Die App bietet:
- Klassische ToDo-Verwaltung mit Aufgaben, Deadlines, Prioritäten
- **Automatische Sortierung** nach unterschiedlichen Methoden
- **5 integrierte Priorisierungsprinzipien**:
  - Earliest Due Day  
  - Duration & Deadline  
  - Eisenhower Matrix  
  - Value vs Effort  
  - Individuelles, gewichtetes Scoring-Modell
- **Eigenes Regelwerk definieren:** Nutze deine individuelle Gewichtung aus *Priorität*, *Dauer* und *Deadline* – flexibel, aber strukturiert!

---

## Installation & Setup

### APK-Datei
Die `TLP_release.apk` befindet sich direkt im Stammverzeichnis folder.  
**Installation auf einem Android-Gerät genügt, um die App in vollem Funktionsumfang zu nutzen**.

### Projekt selbst clonen?
Falls du das Projekt clonen und lokal ausführen willst:
- Ein gültiger **Magenta Cloud Token** ist erforderlich, um QR-basierte Datenübertragung zu nutzen (bspw. für Geräte-Sync).
- Ohne Token läuft die App, aber die QR-Funktionalität ist **deaktiviert**.
- Lege dafür eine **magenta_cloud_token** Datei im Unterverzeichnis **src/lib/config/** an und schreibe dein Individuelles Token rein.
- Lege außerdem eine DB.csv Datei innerhalb deiner Magentacloud an.

---

## Projektstruktur & Architektur

Die App folgt dem **MVC-Pattern** (Model-View-Controller), um Wartbarkeit, Erweiterbarkeit und Trennung von Logik und UI sicherzustellen.

![MVC Pattern](architecture/MVC_Pattern.png)

## Lines of Code (LoC)

Analyse via 'cloc'

| Language | Files | Blank | Comment | Code |
|----------|-------|-------|---------|------|
| Dart     | 46    | 597   | 246     | 4599 |
| JSON     | 1     | 0     | 0       | 1298 |
| **SUM:** | 47    | 597   | 246     | 5897 |


# ToDo-List Prior (TLP) [Deutsche Version](#todo-list-prior-tlp-english-version)

**ToDo-List Prior (TLP)** is an intelligent ToDo app focused on *automatic prioritization*.  
It is designed for everyone who wants to manage tasks in a structured, efficient, and focused way – without tediously clicking through endless ToDo lists.  

**The .apk file for direct installation is available in the root directory!**  
Simply install and start – all features are immediately ready to use.

**TLP was developed as part of a lecture at Aalen University.**  
Development team: Tobias Pöhle, Luzia Weinberger, Paul Frischeisen. 

---

## App Description

The app offers:
- Classic ToDo management with tasks, deadlines, priorities
- **Automatic sorting** based on different methods
- **5 integrated prioritization principles**:
  - Earliest Due Day  
  - Duration & Deadline  
  - Eisenhower Matrix  
  - Value vs Effort  
  - Custom weighted scoring model
- **Define your own ruleset:** Use your individual weighting of *priority*, *duration*, and *deadline* – flexible yet structured!

---

## Installation & Setup

### APK File
The `TLP_release.apk` is located directly in the root directory.  
**Installing it on an Android device is sufficient to use the app with full functionality.**

### Want to clone the project yourself?
If you want to clone the project and run it locally:
- A valid **Magenta Cloud Token** is required to use QR-based data transfer (e.g., for device sync).
- Without a token, the app still works, but the QR functionality will be **disabled**.
- To enable it, create a **magenta_cloud_token** file inside **src/lib/config/** and paste your individual token into it.
- Also, create a DB.csv file within your Magenta Cloud storage.

---

## Project Structure & Architecture

The app follows the **MVC pattern** (Model-View-Controller) to ensure maintainability, scalability, and separation of logic and UI.

![MVC Pattern](architecture/MVC_Pattern.png)

---

## Lines of Code (LoC)

Analysis via 'cloc'

| Language | Files | Blank | Comment | Code |
|----------|-------|-------|---------|------|
| Dart     | 46    | 597   | 246     | 4599 |
| JSON     | 1     | 0     | 0       | 1298 |
| **SUM:** | 47    | 597   | 246     | 5897 |
